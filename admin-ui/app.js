const API_BASE = "http://localhost:4000";

const pendingContainer = document.getElementById("pending-listings");
const reportsContainer = document.getElementById("reports");
const metricsContainer = document.getElementById("metrics");
const categoriesContainer = document.getElementById("categories");
const categoryForm = document.getElementById("category-form");
const categoryIdInput = document.getElementById("category-id");
const categoryNameInput = document.getElementById("category-name");

const renderEmpty = (container, message) => {
  container.innerHTML = `<div class="card muted">${message}</div>`;
};

const renderListing = (listing) => {
  const card = document.createElement("div");
  card.className = "card";
  card.innerHTML = `
    <strong>${listing.title}</strong>
    <p class="muted">${listing.location} • ${listing.categoryId}</p>
    <p>${listing.description}</p>
    <div class="button-row">
      <button data-action="approve">Approve listing</button>
      <button data-action="reject">Reject listing</button>
    </div>
  `;
  card.querySelectorAll("button").forEach((button) => {
    button.addEventListener("click", async () => {
      const status =
        button.dataset.action === "reject" ? "rejected" : "approved";
      await fetch(`${API_BASE}/admin/listings/${listing.id}/status`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ status })
      });
      loadPendingListings();
    });
  });
  return card;
};

const renderMetric = (metric) => {
  const card = document.createElement("div");
  card.className = "card";
  card.innerHTML = `
    <strong>${metric.label}</strong>
    <p>${metric.value}</p>
  `;
  return card;
};

const renderCategory = (category) => {
  const card = document.createElement("div");
  card.className = "card";
  card.innerHTML = `
    <strong>${category.name}</strong>
    <p class="muted">ID: ${category.id}</p>
    <div class="button-row">
      <button data-action="rename">Rename</button>
    </div>
  `;
  card.querySelector("button").addEventListener("click", async () => {
    const name = window.prompt("New category name", category.name);
    if (!name) {
      return;
    }
    await fetch(`${API_BASE}/admin/categories/${category.id}`, {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name })
    });
    loadCategories();
  });
  return card;
};

const renderReport = (report) => {
  const card = document.createElement("div");
  card.className = "card";
  card.innerHTML = `
    <strong>${report.type.toUpperCase()} report</strong>
    <p class="muted">Target: ${report.targetId}</p>
    <p>${report.reason}</p>
    <div class="button-row">
      <button data-action="resolve">Resolve</button>
      <button data-action="ban">Ban user</button>
    </div>
  `;
  card.querySelectorAll("button").forEach((button) => {
    button.addEventListener("click", async () => {
      if (button.dataset.action === "resolve") {
        await fetch(`${API_BASE}/admin/reports/${report.id}/resolve`, {
          method: "POST"
        });
        loadReports();
        loadMetrics();
        return;
      }
      const userId = window.prompt("User ID to ban");
      if (!userId) {
        return;
      }
      await fetch(`${API_BASE}/admin/ban-user`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ userId, banned: true })
      });
      loadMetrics();
    });
  });
  return card;
};

const loadMetrics = async () => {
  const response = await fetch(`${API_BASE}/admin/metrics`);
  const metrics = await response.json();
  const items = [
    { label: "Open reports", value: metrics.openReports },
    { label: "Pending listings", value: metrics.pendingListings },
    { label: "Banned users", value: metrics.bannedUsers },
    { label: "Total listings", value: metrics.totalListings }
  ];
  metricsContainer.innerHTML = "";
  items.forEach((metric) => metricsContainer.appendChild(renderMetric(metric)));
};

const loadPendingListings = async () => {
  const response = await fetch(`${API_BASE}/admin/listings?status=pending`);
  const listings = await response.json();
  if (!Array.isArray(listings) || listings.length === 0) {
    return renderEmpty(pendingContainer, "No pending listings.");
  }
  pendingContainer.innerHTML = "";
  listings.forEach((listing) =>
    pendingContainer.appendChild(renderListing(listing))
  );
};

const loadReports = async () => {
  const response = await fetch(`${API_BASE}/admin/reports`);
  const reports = await response.json();
  if (!Array.isArray(reports) || reports.length === 0) {
    return renderEmpty(reportsContainer, "No reports submitted.");
  }
  reportsContainer.innerHTML = "";
  reports.forEach((report) =>
    reportsContainer.appendChild(renderReport(report))
  );
};

const loadCategories = async () => {
  const response = await fetch(`${API_BASE}/admin/categories`);
  const categories = await response.json();
  if (!Array.isArray(categories) || categories.length === 0) {
    return renderEmpty(categoriesContainer, "No categories.");
  }
  categoriesContainer.innerHTML = "";
  categories.forEach((category) =>
    categoriesContainer.appendChild(renderCategory(category))
  );
};

const init = async () => {
  categoryForm.addEventListener("submit", async (event) => {
    event.preventDefault();
    const id = categoryIdInput.value.trim();
    const name = categoryNameInput.value.trim();
    if (!id || !name) {
      return;
    }
    await fetch(`${API_BASE}/admin/categories`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ id, name })
    });
    categoryIdInput.value = "";
    categoryNameInput.value = "";
    loadCategories();
  });
  await loadMetrics();
  await loadPendingListings();
  await loadReports();
  await loadCategories();
};

init();
