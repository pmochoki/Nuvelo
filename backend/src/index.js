const express = require("express");
const cors = require("cors");
const path = require("path");
const {
  categories,
  users,
  listings,
  conversations,
  messages,
  reports,
  favorites,
  savedSearches,
  blocks
} = require("./data");
const { validateListing, validateMessage } = require("./validation");

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, "../../admin-ui")));

const generateId = (prefix) =>
  `${prefix}_${Math.random().toString(36).slice(2, 10)}`;

const findUser = (userId) => users.find((user) => user.id === userId);
const findListing = (listingId) =>
  listings.find((listing) => listing.id === listingId);
const allowedRoles = ["customer", "seller", "agent", "landlord"];
const isValidRole = (role) => allowedRoles.includes(role);
const allowedReportTypes = ["listing", "user", "message"];

const toUserProfile = (user) => {
  const userListings = listings.filter((listing) => listing.userId === user.id);
  const approvedListings = userListings.filter(
    (listing) => listing.status === "approved"
  );
  return {
    id: user.id,
    name: user.name,
    role: user.role,
    email: user.email,
    phone: user.phone,
    emailVerified: user.emailVerified,
    phoneVerified: user.phoneVerified,
    banned: user.banned,
    memberSince: user.createdAt,
    listingCount: userListings.length,
    approvedListings: approvedListings.length
  };
};

const rateLimits = {
  listings: { windowMs: 60 * 60 * 1000, max: 5 },
  messages: { windowMs: 60 * 1000, max: 30 }
};
const activityLog = {
  listings: new Map(),
  messages: new Map()
};

const isRateLimited = (userId, type) => {
  if (!userId || !rateLimits[type]) {
    return { limited: false };
  }
  const { windowMs, max } = rateLimits[type];
  const now = Date.now();
  const entries = activityLog[type].get(userId) || [];
  const recent = entries.filter((timestamp) => now - timestamp < windowMs);
  if (recent.length >= max) {
    return {
      limited: true,
      retryAfterMs: windowMs - (now - recent[0])
    };
  }
  recent.push(now);
  activityLog[type].set(userId, recent);
  return { limited: false };
};

const isBlocked = (blockerId, blockedId) =>
  blocks.some(
    (entry) => entry.blockerId === blockerId && entry.blockedId === blockedId
  );

app.get("/health", (req, res) => {
  res.json({ status: "ok" });
});

app.get("/categories", (req, res) => {
  res.json(categories);
});

app.post("/auth/login", (req, res) => {
  const { name, role } = req.body || {};
  if (!name || !role) {
    return res.status(400).json({ error: "name and role are required." });
  }
  if (!isValidRole(role)) {
    return res.status(400).json({ error: "Invalid role." });
  }
  let user = users.find(
    (candidate) =>
      candidate.name.toLowerCase() === name.toLowerCase() &&
      candidate.role === role
  );
  if (!user) {
    user = {
      id: generateId("user"),
      name,
      role,
      email: null,
      phone: null,
      emailVerified: false,
      phoneVerified: false,
      banned: false,
      createdAt: new Date().toISOString()
    };
    users.push(user);
  }
  res.json(toUserProfile(user));
});

app.get("/users/:id", (req, res) => {
  const user = findUser(req.params.id);
  if (!user) {
    return res.status(404).json({ error: "User not found." });
  }
  res.json(toUserProfile(user));
});

app.put("/users/:id/verification", (req, res) => {
  const { emailVerified, phoneVerified } = req.body || {};
  const user = findUser(req.params.id);
  if (!user) {
    return res.status(404).json({ error: "User not found." });
  }
  if (typeof emailVerified === "boolean") {
    user.emailVerified = emailVerified;
  }
  if (typeof phoneVerified === "boolean") {
    user.phoneVerified = phoneVerified;
  }
  res.json(toUserProfile(user));
});

app.get("/listings", (req, res) => {
  const {
    query,
    categoryId,
    location,
    minPrice,
    maxPrice,
    status,
    userId,
    viewerId
  } = req.query;
  const filtered = listings.filter((listing) => {
    if (userId) {
      if (listing.userId !== userId) {
        return false;
      }
    } else if (listing.status !== "approved") {
      return false;
    }
    if (
      viewerId &&
      (isBlocked(viewerId, listing.userId) ||
        isBlocked(listing.userId, viewerId))
    ) {
      return false;
    }
    if (status && listing.status !== status) {
      return false;
    }
    if (categoryId && listing.categoryId !== categoryId) {
      return false;
    }
    if (
      location &&
      !listing.location.toLowerCase().includes(location.toLowerCase())
    ) {
      return false;
    }
    if (query) {
      const text = `${listing.title} ${listing.description}`.toLowerCase();
      if (!text.includes(query.toLowerCase())) {
        return false;
      }
    }
    if (minPrice && listing.price !== null && listing.price < Number(minPrice)) {
      return false;
    }
    if (maxPrice && listing.price !== null && listing.price > Number(maxPrice)) {
      return false;
    }
    return true;
  });
  res.json(filtered);
});

app.get("/listings/:id", (req, res) => {
  const listing = listings.find((item) => item.id === req.params.id);
  if (!listing) {
    return res.status(404).json({ error: "Listing not found" });
  }
  const { viewerId } = req.query;
  if (
    viewerId &&
    (isBlocked(viewerId, listing.userId) || isBlocked(listing.userId, viewerId))
  ) {
    return res.status(403).json({ error: "Listing is not available." });
  }
  res.json(listing);
});

app.post("/listings", (req, res) => {
  const payload = req.body || {};
  const limit = isRateLimited(payload.userId, "listings");
  if (limit.limited) {
    return res.status(429).json({
      error: "Listing rate limit exceeded.",
      retryAfterMs: limit.retryAfterMs
    });
  }
  const author = findUser(payload.userId);
  if (author && author.banned) {
    return res.status(403).json({ error: "User is banned." });
  }
  const errors = validateListing(payload);
  if (errors.length > 0) {
    return res.status(400).json({ errors });
  }
  const newListing = {
    id: generateId("listing"),
    title: payload.title,
    description: payload.description,
    categoryId: payload.categoryId,
    price: payload.price ?? null,
    currency: payload.currency || "HUF",
    location: payload.location || "Unknown",
    images: payload.images || [],
    condition: payload.condition || "good",
    categoryFields: payload.categoryFields || {},
    userId: payload.userId || "u1",
    status: "pending",
    createdAt: new Date().toISOString()
  };
  listings.push(newListing);
  res.status(201).json(newListing);
});

app.put("/listings/:id", (req, res) => {
  const listing = listings.find((item) => item.id === req.params.id);
  if (!listing) {
    return res.status(404).json({ error: "Listing not found" });
  }
  const next = { ...listing, ...req.body };
  const errors = validateListing(next);
  if (errors.length > 0) {
    return res.status(400).json({ errors });
  }
  Object.assign(listing, next);
  res.json(listing);
});

app.delete("/listings/:id", (req, res) => {
  const index = listings.findIndex((item) => item.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ error: "Listing not found" });
  }
  listings.splice(index, 1);
  res.status(204).end();
});

app.post("/conversations", (req, res) => {
  const { listingId, buyerId, sellerId } = req.body || {};
  if (!listingId || !buyerId || !sellerId) {
    return res.status(400).json({ error: "Missing conversation fields." });
  }
  if (isBlocked(sellerId, buyerId)) {
    return res.status(403).json({ error: "You are blocked by this seller." });
  }
  const conversation = {
    id: generateId("conv"),
    listingId,
    buyerId,
    sellerId,
    createdAt: new Date().toISOString()
  };
  conversations.push(conversation);
  res.status(201).json(conversation);
});

app.get("/conversations", (req, res) => {
  const { userId } = req.query;
  if (!userId) {
    return res.status(400).json({ error: "userId is required." });
  }
  const result = conversations.filter(
    (conv) => conv.buyerId === userId || conv.sellerId === userId
  );
  res.json(result);
});

app.get("/conversations/:id/messages", (req, res) => {
  const result = messages.filter((msg) => msg.conversationId === req.params.id);
  res.json(result);
});

app.post("/conversations/:id/messages", (req, res) => {
  const { senderId, text } = req.body || {};
  if (!senderId || !text) {
    return res.status(400).json({ error: "senderId and text are required." });
  }
  const messageErrors = validateMessage(text);
  if (messageErrors.length > 0) {
    return res.status(400).json({ errors: messageErrors });
  }
  const limit = isRateLimited(senderId, "messages");
  if (limit.limited) {
    return res.status(429).json({
      error: "Message rate limit exceeded.",
      retryAfterMs: limit.retryAfterMs
    });
  }
  const sender = findUser(senderId);
  if (sender && sender.banned) {
    return res.status(403).json({ error: "User is banned." });
  }
  const conversation = conversations.find((conv) => conv.id === req.params.id);
  if (!conversation) {
    return res.status(404).json({ error: "Conversation not found." });
  }
  const recipientId =
    conversation.buyerId === senderId
      ? conversation.sellerId
      : conversation.buyerId;
  if (isBlocked(recipientId, senderId)) {
    return res.status(403).json({ error: "Recipient has blocked you." });
  }
  const message = {
    id: generateId("msg"),
    conversationId: req.params.id,
    senderId,
    text,
    createdAt: new Date().toISOString(),
    readAt: null
  };
  messages.push(message);
  res.status(201).json(message);
});

app.post("/conversations/:id/mark-read", (req, res) => {
  const { userId } = req.body || {};
  if (!userId) {
    return res.status(400).json({ error: "userId is required." });
  }
  const conversation = conversations.find((conv) => conv.id === req.params.id);
  if (!conversation) {
    return res.status(404).json({ error: "Conversation not found." });
  }
  const updated = messages
    .filter(
      (msg) =>
        msg.conversationId === conversation.id &&
        msg.senderId !== userId &&
        !msg.readAt
    )
    .map((msg) => {
      msg.readAt = new Date().toISOString();
      return msg;
    });
  res.json({ updatedCount: updated.length });
});

app.post("/reports", (req, res) => {
  const { type, targetId, reason, reporterId } = req.body || {};
  if (!type || !targetId || !reason || !reporterId) {
    return res.status(400).json({ error: "Missing report fields." });
  }
  if (!allowedReportTypes.includes(type)) {
    return res.status(400).json({ error: "Invalid report type." });
  }
  if (type === "listing" && !findListing(targetId)) {
    return res.status(404).json({ error: "Listing not found." });
  }
  if (type === "user" && !findUser(targetId)) {
    return res.status(404).json({ error: "User not found." });
  }
  if (
    type === "message" &&
    !messages.some((message) => message.id === targetId)
  ) {
    return res.status(404).json({ error: "Message not found." });
  }
  const report = {
    id: generateId("report"),
    type,
    targetId,
    reason,
    reporterId,
    status: "open",
    createdAt: new Date().toISOString()
  };
  reports.push(report);
  res.status(201).json(report);
});

app.post("/blocks", (req, res) => {
  const { blockerId, blockedId } = req.body || {};
  if (!blockerId || !blockedId) {
    return res.status(400).json({ error: "Missing block fields." });
  }
  if (isBlocked(blockerId, blockedId)) {
    return res.status(200).json({ status: "already-blocked" });
  }
  const block = {
    id: generateId("block"),
    blockerId,
    blockedId,
    createdAt: new Date().toISOString()
  };
  blocks.push(block);
  res.status(201).json(block);
});

app.get("/blocks", (req, res) => {
  const { userId } = req.query;
  if (!userId) {
    return res.status(400).json({ error: "userId is required." });
  }
  res.json(blocks.filter((block) => block.blockerId === userId));
});

app.post("/favorites", (req, res) => {
  const { userId, listingId } = req.body || {};
  if (!userId || !listingId) {
    return res.status(400).json({ error: "Missing favorite fields." });
  }
  const exists = favorites.some(
    (fav) => fav.userId === userId && fav.listingId === listingId
  );
  if (exists) {
    return res.status(200).json({ status: "already-favorited" });
  }
  const favorite = {
    id: generateId("fav"),
    userId,
    listingId,
    createdAt: new Date().toISOString()
  };
  favorites.push(favorite);
  res.status(201).json(favorite);
});

app.delete("/favorites", (req, res) => {
  const { userId, listingId } = req.body || {};
  if (!userId || !listingId) {
    return res.status(400).json({ error: "Missing favorite fields." });
  }
  const index = favorites.findIndex(
    (fav) => fav.userId === userId && fav.listingId === listingId
  );
  if (index === -1) {
    return res.status(404).json({ error: "Favorite not found." });
  }
  favorites.splice(index, 1);
  res.status(204).end();
});

app.get("/favorites", (req, res) => {
  const { userId } = req.query;
  if (!userId) {
    return res.status(400).json({ error: "userId is required." });
  }
  res.json(favorites.filter((fav) => fav.userId === userId));
});

app.post("/saved-searches", (req, res) => {
  const { userId, query, categoryId, location, minPrice, maxPrice } =
    req.body || {};
  if (!userId) {
    return res.status(400).json({ error: "userId is required." });
  }
  const saved = {
    id: generateId("search"),
    userId,
    query: query || "",
    categoryId: categoryId || null,
    location: location || null,
    minPrice: minPrice ?? null,
    maxPrice: maxPrice ?? null,
    createdAt: new Date().toISOString()
  };
  savedSearches.push(saved);
  res.status(201).json(saved);
});

app.get("/saved-searches", (req, res) => {
  const { userId } = req.query;
  if (!userId) {
    return res.status(400).json({ error: "userId is required." });
  }
  res.json(savedSearches.filter((search) => search.userId === userId));
});

app.delete("/saved-searches/:id", (req, res) => {
  const index = savedSearches.findIndex((item) => item.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ error: "Saved search not found." });
  }
  savedSearches.splice(index, 1);
  res.status(204).end();
});

app.get("/admin/reports", (req, res) => {
  res.json(reports);
});

app.post("/admin/reports/:id/resolve", (req, res) => {
  const report = reports.find((item) => item.id === req.params.id);
  if (!report) {
    return res.status(404).json({ error: "Report not found." });
  }
  report.status = "resolved";
  res.json(report);
});

app.get("/admin/listings", (req, res) => {
  const { status } = req.query;
  const result = status
    ? listings.filter((listing) => listing.status === status)
    : listings;
  res.json(result);
});

app.post("/admin/listings/:id/status", (req, res) => {
  const { status } = req.body || {};
  const listing = listings.find((item) => item.id === req.params.id);
  if (!listing) {
    return res.status(404).json({ error: "Listing not found" });
  }
  listing.status = status || "approved";
  res.json(listing);
});

app.post("/admin/ban-user", (req, res) => {
  const { userId, banned } = req.body || {};
  const user = findUser(userId);
  if (!user) {
    return res.status(404).json({ error: "User not found" });
  }
  user.banned = Boolean(banned);
  res.json(user);
});

app.get("/admin/categories", (req, res) => {
  res.json(categories);
});

app.post("/admin/categories", (req, res) => {
  const { id, name } = req.body || {};
  if (!id || !name) {
    return res.status(400).json({ error: "id and name are required." });
  }
  if (categories.some((category) => category.id === id)) {
    return res.status(400).json({ error: "Category already exists." });
  }
  const category = { id, name };
  categories.push(category);
  res.status(201).json(category);
});

app.put("/admin/categories/:id", (req, res) => {
  const { name } = req.body || {};
  const category = categories.find((item) => item.id === req.params.id);
  if (!category) {
    return res.status(404).json({ error: "Category not found." });
  }
  if (!name) {
    return res.status(400).json({ error: "name is required." });
  }
  category.name = name;
  res.json(category);
});

app.get("/admin/metrics", (req, res) => {
  const since = Date.now() - 24 * 60 * 60 * 1000;
  const openReports = reports.filter((report) => report.status === "open").length;
  const pendingListings = listings.filter(
    (listing) => listing.status === "pending"
  ).length;
  const bannedUsers = users.filter((user) => user.banned).length;
  const newListingsLast24h = listings.filter(
    (listing) => new Date(listing.createdAt).getTime() >= since
  ).length;
  const newReportsLast24h = reports.filter(
    (report) => new Date(report.createdAt).getTime() >= since
  ).length;
  res.json({
    openReports,
    pendingListings,
    bannedUsers,
    newListingsLast24h,
    newReportsLast24h,
    totalListings: listings.length,
    totalUsers: users.length
  });
});

const port = process.env.PORT || 4000;
app.listen(port, () => {
  console.log(`API server listening on ${port}`);
});
