import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

import "api.dart";
import "models.dart";

// Jiji-style brand colors (green, like reference)
const Color _jijiGreen = Color(0xFF2E7D32);
const Color _jijiGreenDark = Color(0xFF1B5E20);
const Color _jijiBg = Color(0xFFF5F5F5);
const Color _jijiCard = Color(0xFFFFFFFF);
const Color _jijiText = Color(0xFF1A1A1A);
const Color _jijiTextGray = Color(0xFF757575);
const Color _jijiSectionBg = Color(0xFFE8EEF0);

void main() {
  runApp(const InterHungaryApp());
}

class InterHungaryApp extends StatelessWidget {
  const InterHungaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "InterHungary",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _jijiGreen,
          brightness: Brightness.light,
          primary: _jijiGreen,
          secondary: _jijiGreenDark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
        scaffoldBackgroundColor: _jijiBg,
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _jijiText,
          ),
          backgroundColor: _jijiCard,
          foregroundColor: _jijiText,
          iconTheme: const IconThemeData(color: _jijiText),
        ),
        cardTheme: CardThemeData(
          color: _jijiCard,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.08),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFEEEEEE),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _jijiGreen, width: 2),
          ),
          labelStyle: GoogleFonts.poppins(color: _jijiTextGray),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _jijiGreen,
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _jijiGreen,
            side: const BorderSide(color: _jijiGreen, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFEEEEEE),
          selectedColor: _jijiGreen,
          labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
          secondaryLabelStyle: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: _jijiGreen,
          unselectedItemColor: _jijiTextGray,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          backgroundColor: Colors.white,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF1F2937),
          contentTextStyle: GoogleFonts.poppins(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      routes: {
        "/": (_) => const AppRoot(),
        "/listing": (_) => const ListingDetailsScreen(),
        "/chat": (_) => const ChatScreen()
      },
      initialRoute: "/",
    );
  }
}

enum UserRole { customer, seller, agent, landlord }

String roleLabel(UserRole role) {
  switch (role) {
    case UserRole.customer:
      return "Customer";
    case UserRole.seller:
      return "Seller";
    case UserRole.agent:
      return "Agent";
    case UserRole.landlord:
      return "Landlord";
  }
}

String roleId(UserRole role) {
  switch (role) {
    case UserRole.customer:
      return "customer";
    case UserRole.seller:
      return "seller";
    case UserRole.agent:
      return "agent";
    case UserRole.landlord:
      return "landlord";
  }
}

UserRole roleFromId(String role) {
  switch (role) {
    case "seller":
      return UserRole.seller;
    case "agent":
      return UserRole.agent;
    case "landlord":
      return UserRole.landlord;
    default:
      return UserRole.customer;
  }
}

class ListingDetailsArgs {
  final Listing listing;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onReport;
  final VoidCallback onBlock;
  final VoidCallback onStartChat;

  const ListingDetailsArgs({
    required this.listing,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onReport,
    required this.onBlock,
    required this.onStartChat
  });
}

class ChatArgs {
  final String conversationId;
  final String currentUserId;
  final String peerId;
  final String listingId;

  const ChatArgs({
    required this.conversationId,
    required this.currentUserId,
    required this.peerId,
    required this.listingId
  });
}

class AppData {
  final List<Category> categories;
  final List<Listing> listings;
  final bool isFallback;

  const AppData({
    required this.categories,
    required this.listings,
    this.isFallback = false
  });
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  final ApiService _api = const ApiService();
  UserRole? _role;
  UserProfile? _user;

  Future<void> _signIn(
    String name,
    String? contact,
    String? otp
  ) async {
    final trimmedContact = contact?.trim();
    final isEmail = trimmedContact != null && trimmedContact.contains("@");
    // Jiji-style: single account; backend gets default "customer" role (user can buy & sell)
    final profile = await _api.login(
      name: name,
      role: "customer",
      email: isEmail ? trimmedContact : null,
      phone: !isEmail ? trimmedContact : null,
      otp: otp?.trim().isEmpty == true ? null : otp?.trim(),
    );
    setState(() {
      _role = roleFromId(profile.role);
      _user = profile;
    });
  }

  void _signOut() {
    setState(() {
      _role = null;
      _user = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_role == null || _user == null) {
      return SignInScreen(onSignIn: _signIn);
    }
    return MainShell(
      role: _role!,
      user: _user!,
      api: _api,
      onSignOut: _signOut
    );
  }
}

const categories = [
  Category(id: "rentals", name: "Rentals"),
  Category(id: "jobs", name: "Jobs"),
  Category(id: "clothes", name: "Clothes"),
  Category(id: "services", name: "Services"),
  Category(id: "electronics", name: "Electronics"),
  Category(id: "vehicles", name: "Vehicles"),
  Category(id: "real-estate", name: "Real estate")
];

const sampleListings = [
  Listing(
    id: "l1",
    title: "City center studio",
    description: "Bright studio near tram line. Utilities included.",
    categoryId: "rentals",
    location: "Budapest",
    price: 450,
    currency: "EUR",
    priceLabel: "EUR 450 / month",
    condition: "good",
    sellerId: "u1",
    sellerName: "Anna Nagy",
    categoryFields: {
      "type": "Studio",
      "bedrooms": "1",
      "bathrooms": "1",
      "area": "28 sqm",
      "furnished": "Yes",
      "lease": "Long-term"
    },
    status: "approved"
  ),
  Listing(
    id: "l2",
    title: "Part-time barista",
    description: "Weekend shift, English speaking.",
    categoryId: "jobs",
    location: "Debrecen",
    price: null,
    currency: "HUF",
    priceLabel: "HUF 2000 / hour",
    condition: "new",
    sellerId: "u2",
    sellerName: "David Smith",
    categoryFields: {
      "role": "Barista",
      "contract": "Part-time",
      "experience": "1+ year"
    },
    status: "approved"
  ),
  Listing(
    id: "l3",
    title: "Winter coat",
    description: "Warm and clean, size M.",
    categoryId: "clothes",
    location: "Szeged",
    price: 12000,
    currency: "HUF",
    priceLabel: "HUF 12000",
    condition: "good",
    sellerId: "u3",
    sellerName: "Eszter Horvath",
    categoryFields: {"size": "M", "brand": "Local"},
    status: "approved",
  ),
  Listing(
    id: "l4",
    title: "Toyota Corolla 2016",
    description: "Reliable, single owner, serviced regularly.",
    categoryId: "vehicles",
    location: "Szeged",
    price: 4100000,
    currency: "HUF",
    priceLabel: "HUF 4 100 000",
    condition: "used",
    sellerId: "u4",
    sellerName: "Mate Kovacs",
    categoryFields: {
      "make": "Toyota",
      "model": "Corolla",
      "year": "2016",
      "mileage": "98 000 km",
      "fuel": "Gasoline"
    },
    status: "approved",
  ),
  Listing(
    id: "l5",
    title: "iPhone 12 128GB",
    description: "Blue, battery 88%, includes charger.",
    categoryId: "electronics",
    location: "Budapest",
    price: 165000,
    currency: "HUF",
    priceLabel: "HUF 165 000",
    condition: "good",
    sellerId: "u2",
    sellerName: "David Smith",
    categoryFields: {
      "brand": "Apple",
      "storage": "128GB",
      "warranty": "No"
    },
    status: "approved",
  )
];

void openListingDetails({
  required BuildContext context,
  required Listing listing,
  required bool isFavorite,
  required VoidCallback onToggleFavorite,
  required VoidCallback onReport,
  required VoidCallback onBlock,
  required VoidCallback onStartChat
}) {
  Navigator.pushNamed(
    context,
    "/listing",
    arguments: ListingDetailsArgs(
      listing: listing,
      isFavorite: isFavorite,
      onToggleFavorite: onToggleFavorite,
      onReport: onReport,
      onBlock: onBlock,
      onStartChat: onStartChat
    )
  );
}

void showNotice(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

class MainShell extends StatefulWidget {
  final UserRole role;
  final UserProfile user;
  final ApiService api;
  final VoidCallback onSignOut;

  const MainShell({
    super.key,
    required this.role,
    required this.user,
    required this.api,
    required this.onSignOut
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  Set<String> _favoriteIds = {};
  List<SavedSearch> _savedSearches = [];
  Set<String> _blockedUsers = {};

  @override
  void initState() {
    super.initState();
    _hydrateUserData();
  }

  Future<void> _hydrateUserData() async {
    try {
      final results = await Future.wait([
        widget.api.fetchFavorites(widget.user.id),
        widget.api.fetchSavedSearches(widget.user.id),
        widget.api.fetchBlocks(widget.user.id)
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _favoriteIds = (results[0] as List<String>).toSet();
        _savedSearches = results[1] as List<SavedSearch>;
        _blockedUsers = (results[2] as List<String>).toSet();
      });
    } catch (_) {}
  }

  Future<void> _toggleFavorite(String listingId) async {
    final isFavorite = _favoriteIds.contains(listingId);
    setState(() {
      if (isFavorite) {
        _favoriteIds.remove(listingId);
      } else {
        _favoriteIds.add(listingId);
      }
    });
    try {
      if (isFavorite) {
        await widget.api.removeFavorite(
          userId: widget.user.id,
          listingId: listingId
        );
      } else {
        await widget.api.addFavorite(
          userId: widget.user.id,
          listingId: listingId
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (isFavorite) {
          _favoriteIds.add(listingId);
        } else {
          _favoriteIds.remove(listingId);
        }
      });
      showNotice(context, "Could not update favorites.");
    }
  }

  Future<void> _saveSearch(SavedSearch search) async {
    try {
      final saved = await widget.api.saveSearch(
        userId: widget.user.id,
        search: search
      );
      if (!mounted) {
        return;
      }
      setState(() => _savedSearches.add(saved));
      showNotice(context, "Saved search added.");
    } catch (_) {
      showNotice(context, "Could not save the search.");
    }
  }

  Future<void> _blockUser(String userId) async {
    if (_blockedUsers.contains(userId)) {
      showNotice(context, "User already blocked.");
      return;
    }
    setState(() => _blockedUsers.add(userId));
    try {
      await widget.api.blockUser(blockerId: widget.user.id, blockedId: userId);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _blockedUsers.remove(userId));
      showNotice(context, "Could not block this user.");
    }
  }

  Future<void> _reportListing(Listing listing) async {
    final reason = await _promptForReason();
    if (reason == null || reason.trim().isEmpty) {
      return;
    }
    try {
      await widget.api.createReport(
        type: "listing",
        targetId: listing.id,
        reason: reason.trim(),
        reporterId: widget.user.id
      );
      if (mounted) {
        showNotice(context, "Report submitted. Thank you.");
      }
    } catch (_) {
      if (mounted) {
        showNotice(context, "Could not submit report.");
      }
    }
  }

  Future<void> _startChat(Listing listing) async {
    try {
      final conversation = await widget.api.createConversation(
        listingId: listing.id,
        buyerId: widget.user.id,
        sellerId: listing.sellerId
      );
      if (!mounted) {
        return;
      }
      Navigator.pushNamed(
        context,
        "/chat",
        arguments: ChatArgs(
          conversationId: conversation.id,
          currentUserId: widget.user.id,
          peerId: listing.sellerId,
          listingId: listing.id
        )
      );
    } catch (_) {
      showNotice(context, "Could not start the chat.");
    }
  }

  void _openConversation(Conversation conversation) {
    final peerId =
        conversation.buyerId == widget.user.id ? conversation.sellerId : conversation.buyerId;
    Navigator.pushNamed(
      context,
      "/chat",
      arguments: ChatArgs(
        conversationId: conversation.id,
        currentUserId: widget.user.id,
        peerId: peerId,
        listingId: conversation.listingId
      )
    );
  }

  Future<String?> _promptForReason() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Report listing"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(hintText: "Tell us what happened"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text("Submit"),
          )
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  // Jiji-style: 5 tabs - Home, Saved, Sell, Messages, Profile
  List<Widget> get _pages {
    final role = widget.role;
    return [
      HomeLoader(
        api: widget.api,
        role: role,
        viewerId: widget.user.id,
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
        onSaveSearch: _saveSearch,
        onBlockUser: _blockUser,
        onReportListing: _reportListing,
        onStartChat: _startChat,
      ),
      FavoritesScreen(
        favoriteIds: _favoriteIds,
        savedSearches: _savedSearches,
        api: widget.api,
        viewerId: widget.user.id,
        onToggleFavorite: _toggleFavorite,
        onReportListing: _reportListing,
        onBlockUser: _blockUser,
        onStartChat: _startChat,
      ),
      PostListingScreen(
        role: role,
        user: widget.user,
        api: widget.api,
      ),
      InboxScreen(
        api: widget.api,
        userId: widget.user.id,
        onOpenConversation: _openConversation
      ),
      ProfileScreen(
        role: role,
        user: widget.user,
        api: widget.api,
        onSignOut: widget.onSignOut,
        favoriteIds: _favoriteIds,
        savedSearches: _savedSearches,
      )
    ];
  }

  List<BottomNavigationBarItem> get _items => const [
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "Home"),
    BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), activeIcon: Icon(Icons.bookmark), label: "Saved"),
    BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: "Sell"),
    BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: "Messages"),
    BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profile"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
        items: _items,
        backgroundColor: _jijiCard,
      ),
    );
  }
}

class SignInScreen extends StatefulWidget {
  final Future<void> Function(
    String name,
    String? contact,
    String? otp
  ) onSignIn;

  const SignInScreen({super.key, required this.onSignIn});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final contact = _contactController.text.trim();
    final otp = _otpController.text.trim();
    if (name.isEmpty) {
      showNotice(context, "Please enter your name.");
      return;
    }
    if (contact.isEmpty) {
      showNotice(context, "Please add an email or phone number.");
      return;
    }
    if (otp.isEmpty) {
      showNotice(context, "Please enter the OTP code.");
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await widget.onSignIn(name, contact, otp);
    } catch (error) {
      showNotice(context, "Sign in failed. Please try again.");
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _jijiBg,
      appBar: AppBar(
        backgroundColor: _jijiCard,
        elevation: 0,
        title: Text(
          "InterHungary",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _jijiGreen,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            Text(
              "Sign in to buy and sell",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: _jijiTextGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Your name",
                prefixIcon: Icon(Icons.person_outline, color: _jijiTextGray),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _contactController,
              decoration: const InputDecoration(
                labelText: "Phone or email",
                prefixIcon: Icon(Icons.phone_android, color: _jijiTextGray),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(
                labelText: "OTP code",
                prefixIcon: Icon(Icons.lock_outline, color: _jijiTextGray),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 28),
            if (_isSubmitting)
              const Center(child: CircularProgressIndicator()),
            if (!_isSubmitting)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: _jijiGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    "Continue",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class HomeLoader extends StatefulWidget {
  final ApiService api;
  final UserRole role;
  final String viewerId;
  final Set<String> favoriteIds;
  final Future<void> Function(String listingId) onToggleFavorite;
  final Future<void> Function(SavedSearch search) onSaveSearch;
  final Future<void> Function(String userId) onBlockUser;
  final Future<void> Function(Listing listing) onReportListing;
  final Future<void> Function(Listing listing) onStartChat;
  final bool isSearchTab;

  const HomeLoader({
    super.key,
    required this.api,
    required this.role,
    required this.viewerId,
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.onSaveSearch,
    required this.onBlockUser,
    required this.onReportListing,
    required this.onStartChat,
    this.isSearchTab = false,
  });

  @override
  State<HomeLoader> createState() => _HomeLoaderState();
}

class _HomeLoaderState extends State<HomeLoader> {
  late Future<AppData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<AppData> _load() async {
    try {
      final results = await Future.wait([
        widget.api.fetchCategories(),
        widget.api.fetchListings(viewerId: widget.viewerId)
      ]);
      return AppData(
        categories: results[0] as List<Category>,
        listings: results[1] as List<Listing>
      );
    } catch (_) {
      return const AppData(
        categories: categories,
        listings: sampleListings,
        isFallback: true
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return Center(
            child: TextButton(
              onPressed: () => setState(() => _future = _load()),
              child: const Text("Retry loading listings")
            ),
          );
        }
        final data = snapshot.data!;
        return Column(
          children: [
            if (data.isFallback)
              MaterialBanner(
                content: const Text("Showing offline sample data."),
                actions: [
                  TextButton(
                    onPressed: () => setState(() => _future = _load()),
                    child: const Text("Retry")
                  )
                ],
              ),
            Expanded(
              child: RoleHomeScreen(
                role: widget.role,
                listings: data.listings,
                categories: data.categories,
                favoriteIds: widget.favoriteIds,
                onToggleFavorite: widget.onToggleFavorite,
                onSaveSearch: widget.onSaveSearch,
                onBlockUser: widget.onBlockUser,
                onReportListing: widget.onReportListing,
                onStartChat: widget.onStartChat,
                isSearchTab: widget.isSearchTab,
              ),
            )
          ],
        );
      },
    );
  }
}

class RoleHomeScreen extends StatelessWidget {
  final UserRole role;
  final List<Listing> listings;
  final List<Category> categories;
  final Set<String> favoriteIds;
  final Future<void> Function(String listingId) onToggleFavorite;
  final Future<void> Function(SavedSearch search) onSaveSearch;
  final Future<void> Function(String userId) onBlockUser;
  final Future<void> Function(Listing listing) onReportListing;
  final Future<void> Function(Listing listing) onStartChat;
  final bool isSearchTab;

  const RoleHomeScreen({
    super.key,
    required this.role,
    required this.listings,
    required this.categories,
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.onSaveSearch,
    required this.onBlockUser,
    required this.onReportListing,
    required this.onStartChat,
    this.isSearchTab = false,
  });

  @override
  Widget build(BuildContext context) {
    if (role == UserRole.agent) {
      return RoleDashboardScreen(
        title: "Agent dashboard",
        subtitle: "Rental leads waiting for you.",
        listings: listings
            .where((listing) => listing.categoryId == "rentals")
            .toList(),
        onReportListing: onReportListing,
        onStartChat: onStartChat,
        onBlockUser: onBlockUser
      );
    }
    if (role == UserRole.landlord) {
      return RoleDashboardScreen(
        title: "Landlord dashboard",
        subtitle: "Manage your properties.",
        listings: listings
            .where((listing) => listing.categoryId == "rentals")
            .toList(),
        onReportListing: onReportListing,
        onStartChat: onStartChat,
        onBlockUser: onBlockUser
      );
    }
    if (role == UserRole.seller) {
      return RoleDashboardScreen(
        title: "Seller dashboard",
        subtitle: "Track sales and new requests.",
        listings: listings,
        onReportListing: onReportListing,
        onStartChat: onStartChat,
        onBlockUser: onBlockUser
      );
    }
    return CustomerBrowseScreen(
      listings: listings,
      categories: categories,
      favoriteIds: favoriteIds,
      onToggleFavorite: onToggleFavorite,
      onSaveSearch: onSaveSearch,
      onBlockUser: onBlockUser,
      onReportListing: onReportListing,
      onStartChat: onStartChat,
      isSearchTab: isSearchTab,
    );
  }
}

class CustomerBrowseScreen extends StatefulWidget {
  final List<Listing> listings;
  final List<Category> categories;
  final Set<String> favoriteIds;
  final Future<void> Function(String listingId) onToggleFavorite;
  final Future<void> Function(SavedSearch search) onSaveSearch;
  final Future<void> Function(String userId) onBlockUser;
  final Future<void> Function(Listing listing) onReportListing;
  final Future<void> Function(Listing listing) onStartChat;
  final bool isSearchTab;

  const CustomerBrowseScreen({
    super.key,
    required this.listings,
    required this.categories,
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.onSaveSearch,
    required this.onBlockUser,
    required this.onReportListing,
    required this.onStartChat,
    this.isSearchTab = false,
  });

  @override
  State<CustomerBrowseScreen> createState() => _CustomerBrowseScreenState();
}

class _CustomerBrowseScreenState extends State<CustomerBrowseScreen> {
  String _query = "";
  String? _categoryId;
  String _location = "";
  bool _trendingGridView = false; // false = list view, true = grid view

  List<Listing> get _filtered {
    return widget.listings.where((listing) {
      if (_categoryId != null && listing.categoryId != _categoryId) {
        return false;
      }
      if (_location.isNotEmpty &&
          !listing.location.toLowerCase().contains(_location.toLowerCase())) {
        return false;
      }
      if (_query.isNotEmpty) {
        final text =
            "${listing.title} ${listing.description}".toLowerCase();
        if (!text.contains(_query.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Future<void> _saveSearch() async {
    final search = SavedSearch(
      query: _query,
      categoryId: _categoryId,
      location: _location.isEmpty ? null : _location
    );
    await widget.onSaveSearch(search);
  }

  IconData _categoryIcon(String categoryId) {
    switch (categoryId) {
      case "vehicles": return Icons.directions_car;
      case "electronics": return Icons.phone_android;
      case "clothes": return Icons.checkroom;
      case "rentals": case "real-estate": return Icons.home;
      case "jobs": return Icons.work;
      case "services": return Icons.build;
      default: return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return SafeArea(
      top: false,
      child: CustomScrollView(
        slivers: [
          // Green header: "What are you looking for?" + location + search
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
              color: _jijiGreen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "What are you looking for?",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Location dropdown (white oval)
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _location.isEmpty ? "All Hungary" : _location,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: _jijiText,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_down, color: _jijiTextGray, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Search (white oval)
                      Expanded(
                        flex: 2,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "I am looking for...",
                            hintStyle: GoogleFonts.poppins(color: _jijiTextGray, fontSize: 14),
                            prefixIcon: const Icon(Icons.search, color: _jijiTextGray, size: 22),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          onChanged: (value) => setState(() => _query = value),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Action buttons: Apply for job, How to sell, How to buy
          SliverToBoxAdapter(
            child: Container(
              color: _jijiCard,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      icon: Icons.work_outline,
                      label: "Apply for job",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _actionButton(
                      icon: Icons.payments_outlined,
                      label: "How to sell",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _actionButton(
                      icon: Icons.shopping_basket_outlined,
                      label: "How to buy",
                      accentBg: const Color(0xFFF3E5F5), // light purple like reference
                    ),
                  ),
                ],
              ),
            ),
          ),
          // "Recommended for you" horizontal list
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                "Recommended for you",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _jijiText,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: widget.categories.take(6).map((c) => _recommendedCard(c)).toList(),
              ),
            ),
          ),
          // Category grid (4 columns)
          SliverToBoxAdapter(
            child: Container(
              color: _jijiCard,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: [
                  _buildCategoryChip(null, "All", Icons.apps),
                  ...widget.categories.map(
                    (c) => _buildCategoryChip(c.id, c.name, _categoryIcon(c.id)),
                  ),
                ],
              ),
            ),
          ),
          // "Trending" / listings section
          SliverToBoxAdapter(
            child: Container(
              color: _jijiSectionBg,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Trending",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _jijiText,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.grid_view,
                          color: _trendingGridView ? _jijiGreen : _jijiTextGray,
                          size: 22,
                        ),
                        onPressed: () => setState(() => _trendingGridView = true),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: Icon(
                          Icons.view_list,
                          color: _trendingGridView ? _jijiTextGray : _jijiGreen,
                          size: 22,
                        ),
                        onPressed: () => setState(() => _trendingGridView = false),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (filtered.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text("No listings match your filters.")),
              ),
            ),
          if (filtered.isNotEmpty && !_trendingGridView)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final listing = filtered[index];
                  return _jijiListingCard(context, listing);
                },
                childCount: filtered.length,
              ),
            ),
          if (filtered.isNotEmpty && _trendingGridView)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final listing = filtered[index];
                    return _jijiListingCardGrid(context, listing);
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label, Color? accentBg}) {
    final bg = accentBg ?? _jijiCard;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: _jijiGreen, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _jijiText,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recommendedCard(Category c) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: _jijiCard,
        borderRadius: BorderRadius.circular(8),
        elevation: 1,
        child: InkWell(
          onTap: () => setState(() => _categoryId = c.id),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 90,
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_categoryIcon(c.id), color: _jijiGreen, size: 24),
                ),
                const SizedBox(height: 6),
                Text(
                  c.name,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _jijiText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String? id, String label, IconData icon) {
    final selected = _categoryId == id;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _categoryId = id),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: selected ? _jijiGreen : const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: selected ? Colors.white : _jijiTextGray, size: 24),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: selected ? _jijiGreen : _jijiTextGray,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _jijiListingCard(BuildContext context, Listing listing) {
    return Container(
      color: _jijiCard,
      margin: const EdgeInsets.only(bottom: 1),
      child: Material(
        color: _jijiCard,
        child: InkWell(
          onTap: () => openListingDetails(
            context: context,
            listing: listing,
            isFavorite: widget.favoriteIds.contains(listing.id),
            onToggleFavorite: () => widget.onToggleFavorite(listing.id),
            onReport: () => widget.onReportListing(listing),
            onBlock: () => widget.onBlockUser(listing.sellerId),
            onStartChat: () => widget.onStartChat(listing),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.image, color: _jijiTextGray, size: 36),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: _jijiText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        listing.priceLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _jijiGreen,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        listing.location,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _jijiTextGray,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    widget.favoriteIds.contains(listing.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.favoriteIds.contains(listing.id)
                        ? Colors.red
                        : _jijiTextGray,
                    size: 22,
                  ),
                  onPressed: () => widget.onToggleFavorite(listing.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _jijiListingCardGrid(BuildContext context, Listing listing) {
    return Container(
      decoration: BoxDecoration(
        color: _jijiCard,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => openListingDetails(
            context: context,
            listing: listing,
            isFavorite: widget.favoriteIds.contains(listing.id),
            onToggleFavorite: () => widget.onToggleFavorite(listing.id),
            onReport: () => widget.onReportListing(listing),
            onBlock: () => widget.onBlockUser(listing.sellerId),
            onStartChat: () => widget.onStartChat(listing),
          ),
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                    child: const Center(
                      child: Icon(Icons.image, color: _jijiTextGray, size: 36),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: IconButton(
                      icon: Icon(
                        widget.favoriteIds.contains(listing.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: widget.favoriteIds.contains(listing.id)
                            ? Colors.red
                            : _jijiTextGray,
                        size: 20,
                      ),
                      onPressed: () => widget.onToggleFavorite(listing.id),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        listing.priceLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _jijiGreen,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        listing.title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: _jijiText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        listing.location,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: _jijiTextGray,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleDashboardScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Listing> listings;
  final Future<void> Function(Listing listing) onReportListing;
  final Future<void> Function(Listing listing) onStartChat;
  final Future<void> Function(String userId) onBlockUser;

  const RoleDashboardScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.listings,
    required this.onReportListing,
    required this.onStartChat,
    required this.onBlockUser
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(subtitle),
          const SizedBox(height: 16),
          Text("Listings", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...listings.map(
            (listing) => Card(
              child: ListTile(
                title: Text(listing.title),
                subtitle: Text("${listing.location} • ${listing.priceLabel}"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openListingDetails(
                  context: context,
                  listing: listing,
                  isFavorite: false,
                  onToggleFavorite: () {},
                  onReport: () => onReportListing(listing),
                  onBlock: () => onBlockUser(listing.sellerId),
                  onStartChat: () => onStartChat(listing),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ListingDetailsScreen extends StatefulWidget {
  const ListingDetailsScreen({super.key});

  @override
  State<ListingDetailsScreen> createState() => _ListingDetailsScreenState();
}

class _ListingDetailsScreenState extends State<ListingDetailsScreen> {
  bool? _isFavorite;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as ListingDetailsArgs?;
    final data = args?.listing ?? sampleListings.first;
    final isFavorite = _isFavorite ?? args?.isFavorite ?? false;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listing"),
        backgroundColor: _jijiCard,
        foregroundColor: _jijiText,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              data.title,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${data.location} • ${data.priceLabel}",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: _jijiTextGray,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              data.description,
              style: GoogleFonts.poppins(
                fontSize: 15,
                height: 1.5,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Seller: ${data.sellerName}",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.verified_rounded, size: 18, color: _jijiGreen),
                  label: Text("Verified seller", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
                Chip(
                  avatar: const Icon(Icons.lock_outline_rounded, size: 18, color: _jijiGreen),
                  label: Text("Secure chat", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
                Chip(
                  avatar: const Icon(Icons.access_time_rounded, size: 18, color: _jijiGreen),
                  label: Text("Fast responder", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text("Condition: ${data.condition}", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                ),
                ...data.categoryFields.entries.map(
                  (entry) => Chip(
                    label: Text("${entry.key}: ${entry.value}", style: GoogleFonts.poppins(fontSize: 12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _jijiGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.shield_rounded, color: _jijiGreen, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        "Use secure chat and meet in public for safe transactions.",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    args?.onToggleFavorite();
                    setState(() => _isFavorite = !isFavorite);
                  },
                  icon: Icon(
                    isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFavorite ? Colors.redAccent : const Color(0xFF94A3B8),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: args?.onReport,
                  child: const Text("Report"),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: args?.onBlock,
                  child: const Text("Block"),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: args?.onStartChat,
                icon: const Icon(Icons.chat_bubble_outline, size: 22),
                label: const Text("Chat with seller"),
                style: FilledButton.styleFrom(
                  backgroundColor: _jijiGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostListingScreen extends StatefulWidget {
  final UserRole role;
  final UserProfile user;
  final ApiService api;

  const PostListingScreen({
    super.key,
    required this.role,
    required this.user,
    required this.api
  });

  @override
  State<PostListingScreen> createState() => _PostListingScreenState();
}

class _PostListingScreenState extends State<PostListingScreen> {
  String _categoryId = "rentals";
  String _condition = "good";
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final Map<String, TextEditingController> _fieldControllers = {};
  final List<String> _images = [];
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    for (final controller in _fieldControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  List<_FieldSpec> get _fieldSpecs {
    switch (_categoryId) {
      case "vehicles":
        return const [
          _FieldSpec(keyName: "make", label: "Make"),
          _FieldSpec(keyName: "model", label: "Model"),
          _FieldSpec(keyName: "year", label: "Year"),
          _FieldSpec(keyName: "mileage", label: "Mileage"),
          _FieldSpec(keyName: "transmission", label: "Transmission"),
          _FieldSpec(keyName: "fuel", label: "Fuel"),
        ];
      case "real-estate":
      case "rentals":
        return const [
          _FieldSpec(keyName: "type", label: "Property type"),
          _FieldSpec(keyName: "bedrooms", label: "Bedrooms"),
          _FieldSpec(keyName: "bathrooms", label: "Bathrooms"),
          _FieldSpec(keyName: "area", label: "Area (sqm)"),
          _FieldSpec(keyName: "furnished", label: "Furnished"),
          _FieldSpec(keyName: "lease", label: "Lease type"),
        ];
      case "electronics":
        return const [
          _FieldSpec(keyName: "brand", label: "Brand"),
          _FieldSpec(keyName: "model", label: "Model"),
          _FieldSpec(keyName: "storage", label: "Storage"),
          _FieldSpec(keyName: "warranty", label: "Warranty"),
        ];
      case "jobs":
        return const [
          _FieldSpec(keyName: "role", label: "Role"),
          _FieldSpec(keyName: "contractType", label: "Contract type"),
          _FieldSpec(keyName: "salaryRange", label: "Salary range"),
          _FieldSpec(keyName: "experience", label: "Experience"),
        ];
      case "services":
        return const [
          _FieldSpec(keyName: "serviceType", label: "Service type"),
          _FieldSpec(keyName: "availability", label: "Availability"),
          _FieldSpec(keyName: "serviceArea", label: "Service area"),
        ];
      default:
        return const [];
    }
  }

  TextEditingController _controllerFor(String key) {
    return _fieldControllers.putIfAbsent(
      key,
      () => TextEditingController(),
    );
  }

  Widget _buildCategoryFields() {
    final specs = _fieldSpecs;
    if (specs.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: specs
          .map(
            (spec) => TextField(
              controller: _controllerFor(spec.keyName),
              decoration: InputDecoration(labelText: spec.label),
            ),
          )
          .toList(),
    );
  }

  List<String> _requiredFieldsForCategory() {
    switch (_categoryId) {
      case "vehicles":
        return ["make", "model", "year"];
      case "real-estate":
      case "rentals":
        return ["type", "bedrooms", "bathrooms", "area"];
      case "electronics":
        return ["brand", "model"];
      case "jobs":
        return ["role", "contractType"];
      case "services":
        return ["serviceType"];
      default:
        return [];
    }
  }

  Map<String, String> _categoryFields() {
    final fields = <String, String>{};
    for (final spec in _fieldSpecs) {
      final value = _controllerFor(spec.keyName).text.trim();
      if (value.isNotEmpty) {
        fields[spec.keyName] = value;
      }
    }
    return fields;
  }

  Future<void> _submitListing() async {
    if (_submitting) {
      return;
    }
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    if (title.length < 5) {
      showNotice(context, "Title must be at least 5 characters.");
      return;
    }
    if (description.length < 20) {
      showNotice(context, "Description must be at least 20 characters.");
      return;
    }
    final requiredFields = _requiredFieldsForCategory();
    final categoryFields = _categoryFields();
    final missing = requiredFields.where((key) => !categoryFields.containsKey(key));
    if (missing.isNotEmpty) {
      showNotice(context, "Please fill in ${missing.join(", ")}.");
      return;
    }
    final priceValue = num.tryParse(_priceController.text.trim());
    final location = _locationController.text.trim();
    final images = _images.isEmpty
        ? ["https://images.example.com/listings/placeholder.jpg"]
        : _images;
    setState(() => _submitting = true);
    try {
      await widget.api.createListing(
        title: title,
        description: description,
        categoryId: _categoryId,
        price: priceValue,
        currency: "HUF",
        location: location.isEmpty ? "Unknown" : location,
        images: images,
        condition: _condition,
        categoryFields: categoryFields,
        userId: widget.user.id
      );
      if (!mounted) {
        return;
      }
      showNotice(context, "Listing submitted for moderation.");
      _titleController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _locationController.clear();
      for (final controller in _fieldControllers.values) {
        controller.clear();
      }
      setState(() {
        _images.clear();
        _submitting = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _submitting = false);
        showNotice(context, "Could not submit listing.");
      }
    }
  }

  void _addPlaceholderImage() {
    setState(() {
      _images.add("https://images.example.com/listings/placeholder-${DateTime.now().millisecondsSinceEpoch}.jpg");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Green header: Cancel | New Advert | Clear
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 14),
          color: _jijiGreen,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.maybePop(context),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                "New Advert",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              TextButton(
                onPressed: () {
                  _titleController.clear();
                  _descriptionController.clear();
                  _priceController.clear();
                  _locationController.clear();
                  setState(() => _images.clear());
                },
                child: Text(
                  "Clear",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: "Title*",
                  suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.transparent),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _categoryId,
                decoration: const InputDecoration(
                  hintText: "Category*",
                  suffixIcon: Icon(Icons.arrow_drop_down, color: _jijiTextGray),
                ),
                items: categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _categoryId = value);
                },
              ),
              const SizedBox(height: 16),
              Text(
                "Images",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: _jijiText,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    color: _jijiGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: _addPlaceholderImage,
                      borderRadius: BorderRadius.circular(8),
                      child: const SizedBox(
                        width: 80,
                        height: 80,
                        child: Icon(Icons.add, color: _jijiGreen, size: 36),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "First picture is the title picture.",
                          style: GoogleFonts.poppins(fontSize: 12, color: _jijiTextGray),
                        ),
                        Text(
                          "Grab & drag photos to change the order",
                          style: GoogleFonts.poppins(fontSize: 12, color: _jijiTextGray),
                        ),
                        Text(
                          "Supported formats are .jpg, .gif and .png",
                          style: GoogleFonts.poppins(fontSize: 12, color: _jijiTextGray),
                        ),
                        Text(
                          "Each picture must not exceed 5 Mb",
                          style: GoogleFonts.poppins(fontSize: 12, color: _jijiTextGray),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                value: _locationController.text.isEmpty ? null : _locationController.text,
                decoration: const InputDecoration(
                  hintText: "Region",
                  suffixIcon: Icon(Icons.arrow_drop_down, color: _jijiTextGray),
                ),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text("Region")),
                  ...["Budapest", "Debrecen", "Szeged", "Other"]
                      .map((s) => DropdownMenuItem<String?>(value: s, child: Text(s))),
                ],
                onChanged: (value) {
                  _locationController.text = value ?? "";
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: "Description",
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              Text(
                "-Name-",
                style: GoogleFonts.poppins(fontSize: 12, color: _jijiTextGray),
              ),
              const SizedBox(height: 4),
              TextField(
                decoration: InputDecoration(
                  hintText: widget.user.name,
                  suffixIcon: const Icon(Icons.check_circle, color: _jijiGreen, size: 22),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "-Phone number*-",
                style: GoogleFonts.poppins(fontSize: 12, color: _jijiTextGray),
              ),
              const SizedBox(height: 4),
              TextField(
                decoration: InputDecoration(
                  hintText: widget.user.phone ?? "Phone",
                  suffixIcon: const Icon(Icons.check_circle, color: _jijiGreen, size: 22),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _submitting ? null : _submitListing,
                  style: FilledButton.styleFrom(
                    backgroundColor: _jijiGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    _submitting ? "Submitting..." : "Post ad",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(fontSize: 12, color: _jijiTextGray),
                    children: [
                      const TextSpan(
                        text: "By clicking on Post Ad, you accept the ",
                      ),
                      TextSpan(
                        text: "Terms of Use",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _jijiGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(
                        text: ", confirm that you will abide by the ",
                      ),
                      TextSpan(
                        text: "Safety Tips",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _jijiGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(
                        text: ", and declare that this posting does not include any Prohibited Items.",
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

class _FieldSpec {
  final String keyName;
  final String label;

  const _FieldSpec({required this.keyName, required this.label});
}

class InboxScreen extends StatefulWidget {
  final ApiService api;
  final String userId;
  final void Function(Conversation conversation) onOpenConversation;

  const InboxScreen({
    super.key,
    required this.api,
    required this.userId,
    required this.onOpenConversation
  });

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  late Future<List<Conversation>> _future;
  int _tabIndex = 0; // 0 = All, 1 = Unread, 2 = Spam

  @override
  void initState() {
    super.initState();
    _future = widget.api.fetchConversations(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          // Green header with search
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
            color: _jijiGreen,
            child: TextField(
            decoration: InputDecoration(
              hintText: "Search in Messages",
              hintStyle: GoogleFonts.poppins(color: _jijiTextGray, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: _jijiTextGray, size: 22),
              filled: true,
              fillColor: const Color(0xFFE8F5E9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        // Tabs: All | Unread | Spam
        Container(
          color: _jijiCard,
          child: Row(
            children: [
              _tab("All", 0),
              _tab("Unread", 1),
              _tab("Spam", 2),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Conversation>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final conversations = snapshot.data ?? [];
              if (conversations.isEmpty) {
                return Center(
                  child: Text(
                    "No conversations yet.",
                    style: GoogleFonts.poppins(color: _jijiTextGray),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  final peerId = conversation.buyerId == widget.userId
                      ? conversation.sellerId
                      : conversation.buyerId;
                  return Container(
                    color: _jijiCard,
                    margin: const EdgeInsets.only(bottom: 1),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      leading: const CircleAvatar(
                        backgroundColor: _jijiSectionBg,
                        child: Icon(Icons.person, color: _jijiTextGray),
                      ),
                      title: Text(
                        "User $peerId",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: _jijiText,
                        ),
                      ),
                      subtitle: Text(
                        "Listing ${conversation.listingId}",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _jijiTextGray,
                        ),
                      ),
                      trailing: Text(
                        "24 Jan",
                        style: GoogleFonts.poppins(fontSize: 12, color: _jijiTextGray),
                      ),
                      onTap: () => widget.onOpenConversation(conversation),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
      ),
    );
  }

  Widget _tab(String label, int index) {
    final selected = _tabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? _jijiGreen : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: selected ? _jijiGreen : _jijiTextGray,
            ),
          ),
        ),
      ),
    );
  }
}

class FavoritesScreen extends StatefulWidget {
  final Set<String> favoriteIds;
  final List<SavedSearch> savedSearches;
  final ApiService api;
  final String viewerId;
  final Future<void> Function(String listingId) onToggleFavorite;
  final Future<void> Function(Listing listing) onReportListing;
  final Future<void> Function(String userId) onBlockUser;
  final Future<void> Function(Listing listing) onStartChat;

  const FavoritesScreen({
    super.key,
    required this.favoriteIds,
    required this.savedSearches,
    required this.api,
    required this.viewerId,
    required this.onToggleFavorite,
    required this.onReportListing,
    required this.onBlockUser,
    required this.onStartChat,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _tabIndex = 0; // 0 = Ads, 1 = Searches
  late Future<List<Listing>> _listingsFuture;

  @override
  void initState() {
    super.initState();
    _listingsFuture = _loadListings();
  }

  Future<List<Listing>> _loadListings() async {
    try {
      final list = await widget.api.fetchListings(viewerId: widget.viewerId);
      return list.where((l) => widget.favoriteIds.contains(l.id)).toList();
    } catch (_) {
      return sampleListings
          .where((l) => widget.favoriteIds.contains(l.id))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          // Green header: My Favorites
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(0, 48, 0, 16),
            color: _jijiGreen,
            child: Center(
              child: Text(
                "My Favorites",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Tabs: Ads | Searches
          Container(
          color: _jijiCard,
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _tabIndex = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _tabIndex == 0 ? _jijiGreen : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      "Ads",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _tabIndex == 0 ? _jijiGreen : _jijiTextGray,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _tabIndex = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _tabIndex == 1 ? _jijiGreen : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      "Searches",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _tabIndex == 1 ? _jijiGreen : _jijiTextGray,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          ),
          Expanded(
            child: Container(
              color: _jijiSectionBg,
              child: _tabIndex == 0 ? _buildAdsTab() : _buildSearchesTab(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdsTab() {
    return FutureBuilder<List<Listing>>(
      future: _listingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final listings = snapshot.data ?? [];
        if (listings.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.phone_android_outlined,
                    size: 80,
                    color: _jijiTextGray.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "You don't have favorite ads yet",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _jijiText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "'My Favorites' can help you to save ads you are interested in so that you can check them again later.",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _jijiTextGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: listings.length,
          itemBuilder: (context, index) {
            final listing = listings[index];
            return _favoriteListingTile(listing);
          },
        );
      },
    );
  }

  Widget _favoriteListingTile(Listing listing) {
    return Container(
      color: _jijiCard,
      margin: const EdgeInsets.only(bottom: 1),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.image, color: _jijiTextGray, size: 28),
        ),
        title: Text(
          listing.title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: _jijiText,
          ),
        ),
        subtitle: Text(
          listing.priceLabel,
          style: GoogleFonts.poppins(fontSize: 13, color: _jijiGreen),
        ),
        trailing: const Icon(Icons.chevron_right, color: _jijiTextGray),
        onTap: () => openListingDetails(
          context: context,
          listing: listing,
          isFavorite: true,
          onToggleFavorite: () => widget.onToggleFavorite(listing.id),
          onReport: () => widget.onReportListing(listing),
          onBlock: () => widget.onBlockUser(listing.sellerId),
          onStartChat: () => widget.onStartChat(listing),
        ),
      ),
    );
  }

  Widget _buildSearchesTab() {
    if (widget.savedSearches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 80,
                color: _jijiTextGray.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                "No saved searches yet",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _jijiText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: widget.savedSearches.length,
      itemBuilder: (context, index) {
        final search = widget.savedSearches[index];
        return Container(
          color: _jijiCard,
          margin: const EdgeInsets.only(bottom: 1),
          child: ListTile(
            title: Text(
              search.query.isEmpty ? "All listings" : search.query,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: _jijiText),
            ),
            subtitle: Text(
              [
                if (search.categoryId != null) search.categoryId!,
                if (search.location != null) search.location!,
              ].whereType<String>().join(" • "),
              style: GoogleFonts.poppins(fontSize: 12, color: _jijiTextGray),
            ),
            trailing: const Icon(Icons.chevron_right, color: _jijiTextGray),
          ),
        );
      },
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _api = const ApiService();
  final TextEditingController _messageController = TextEditingController();
  ChatArgs? _args;
  late Future<List<Message>> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _args ??= ModalRoute.of(context)?.settings.arguments as ChatArgs?;
    if (_args != null) {
      _future = _loadMessages();
    }
  }

  Future<List<Message>> _loadMessages() async {
    final args = _args;
    if (args == null) {
      return [];
    }
    final messages = await _api.fetchMessages(args.conversationId);
    await _api.markConversationRead(
      conversationId: args.conversationId,
      userId: args.currentUserId
    );
    return messages;
  }

  Future<void> _sendMessage() async {
    final args = _args;
    final text = _messageController.text.trim();
    if (args == null || text.isEmpty) {
      return;
    }
    try {
      await _api.sendMessage(
        conversationId: args.conversationId,
        senderId: args.currentUserId,
        text: text
      );
      _messageController.clear();
      setState(() => _future = _loadMessages());
    } catch (_) {
      showNotice(context, "Could not send message.");
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = _args;
    if (args == null) {
      return const Scaffold(body: Center(child: Text("No conversation.")));
    }
    return Scaffold(
      appBar: AppBar(title: Text("Listing ${args.listingId}")),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Message>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const Center(child: Text("No messages yet."));
                }
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: messages
                      .map(
                        (message) => Align(
                          alignment: message.senderId == args.currentUserId
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: ChatBubble(text: message.text),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: "Type a message")
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send))
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;

  const ChatBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12)
      ),
      child: Text(text),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final UserRole role;
  final UserProfile user;
  final ApiService api;
  final VoidCallback onSignOut;
  final Set<String> favoriteIds;
  final List<SavedSearch> savedSearches;

  const ProfileScreen({
    super.key,
    required this.role,
    required this.user,
    required this.api,
    required this.onSignOut,
    required this.favoriteIds,
    required this.savedSearches
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // White header: avatar, name, settings
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.of(context).padding.top + 16,
                16,
                16,
              ),
              color: _jijiCard,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: _jijiSectionBg,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _jijiGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      user.name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _jijiText,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SettingsScreen(
                          user: user,
                          onSignOut: onSignOut,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.settings, color: _jijiTextGray, size: 26),
                  ),
                ],
              ),
            ),
            // Main content: action cards grid
            Expanded(
              child: Container(
                color: _jijiSectionBg,
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                _profileCard(
                                  icon: Icons.list_alt,
                                  label: "My ads",
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MyListingsScreen(
                                        api: api,
                                        userId: user.id,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _profileCard(
                                  icon: Icons.local_shipping_outlined,
                                  label: "Jiji delivery",
                                  onTap: () {},
                                ),
                                const SizedBox(height: 12),
                                _profileCard(
                                  icon: Icons.sentiment_satisfied_alt_outlined,
                                  label: "Feedback",
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              children: [
                                _profileCard(
                                  icon: Icons.notifications_outlined,
                                  label: "Notifications",
                                  onTap: () {},
                                ),
                                const SizedBox(height: 12),
                                _profileCard(
                                  icon: Icons.people_outline,
                                  label: "Followers",
                                  onTap: () {},
                                ),
                                const SizedBox(height: 12),
                                _profileCard(
                                  icon: Icons.help_outline,
                                  label: "FAQ",
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        // Support FAB
        Positioned(
          right: 16,
          bottom: 16,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            color: _jijiGreen,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.help_outline, color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      "Support",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileCard({
    required IconData icon,
    required String label,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _jijiCard,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (badge != null)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(icon, color: _jijiTextGray, size: 24),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badge,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Icon(icon, color: _jijiTextGray, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: _jijiText,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: _jijiTextGray, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onSignOut;

  const SettingsScreen({
    super.key,
    required this.user,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _jijiCard,
      appBar: AppBar(
        backgroundColor: _jijiSectionBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _jijiText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _jijiText,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _settingsTile(
            icon: Icons.person_outline,
            iconBg: _jijiSectionBg,
            label: "Personal info",
            onTap: () {},
          ),
          _divider(),
          _settingsTile(
            icon: Icons.business_center_outlined,
            iconBg: const Color(0xFFFF6B00),
            label: "Business info",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BusinessDetailsScreen(),
              ),
            ),
          ),
          _divider(),
          _settingsTile(
            icon: Icons.description_outlined,
            iconBg: _jijiGreen,
            label: "Verify your details",
            onTap: () {},
          ),
          _divider(),
          _settingsTile(
            icon: Icons.language,
            iconBg: const Color(0xFFFF6B00),
            label: "Change language",
            trailing: "English",
            onTap: () {},
          ),
          _divider(),
          _settingsTile(
            icon: Icons.phone_outlined,
            iconBg: _jijiGreen,
            label: "Change phone number",
            trailing: user.phone ?? "—",
            onTap: () {},
          ),
          _divider(),
          _settingsTile(
            icon: Icons.alternate_email,
            iconBg: const Color(0xFFFF6B00),
            label: "Change e-mail",
            trailing: user.email ?? "—",
            onTap: () {},
          ),
          _divider(),
          _settingsTile(
            icon: Icons.chat_bubble_outline,
            iconBg: _jijiGreen,
            label: "Disable chats",
            trailing: "Enabled",
            onTap: () {},
          ),
          _divider(),
          _settingsTile(
            icon: Icons.sentiment_satisfied_alt_outlined,
            iconBg: const Color(0xFFFF6B00),
            label: "Disable feedback",
            trailing: "Enabled",
            onTap: () {},
          ),
          _divider(),
          _settingsTile(
            icon: Icons.local_shipping_outlined,
            iconBg: const Color(0xFF2196F3),
            label: "Jiji delivery",
            trailing: "Activate",
            onTap: () {},
          ),
          _divider(),
          _settingsTile(
            icon: Icons.notifications_active_outlined,
            iconBg: const Color(0xFFE53935),
            label: "Manage notifications",
            onTap: () {},
          ),
          _divider(),
          _settingsTile(
            icon: Icons.info_outline,
            iconBg: const Color(0xFF424242),
            label: "About InterHungary",
            onTap: () {},
          ),
          _divider(),
          _settingsTile(
            icon: Icons.star_outline,
            iconBg: const Color(0xFF424242),
            label: "Rate us",
            onTap: () {},
          ),
          _divider(),
          _settingsTile(
            icon: Icons.lock_outline,
            iconBg: const Color(0xFF90A4AE),
            label: "Change password",
            onTap: () {},
          ),
          _divider(),
          _settingsTile(
            icon: Icons.delete_outline,
            iconBg: const Color(0xFF90A4AE),
            label: "Delete my account permanently",
            onTap: () {},
          ),
          _divider(),
          _settingsTile(
            icon: Icons.logout,
            iconBg: const Color(0xFF90A4AE),
            label: "Log out",
            onTap: () {
              Navigator.popUntil(context, (route) => route.isFirst);
              onSignOut();
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required Color iconBg,
    required String label,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _jijiCard,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _jijiText,
                  ),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: _jijiTextGray,
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: _jijiTextGray, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade200);
}

class BusinessDetailsScreen extends StatelessWidget {
  const BusinessDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _jijiCard,
      appBar: AppBar(
        backgroundColor: _jijiCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _jijiGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Business details",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _jijiText,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _businessTile("Company name, description & links", () {}),
          _divider(),
          _businessTile("Store address and business hours", () {}),
          _divider(),
          _businessTile("My own delivery", () {}),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _businessTile(String label, VoidCallback onTap) {
    return Material(
      color: _jijiCard,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _jijiText,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: _jijiTextGray, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade200);
}

class MyListingsScreen extends StatefulWidget {
  final ApiService api;
  final String userId;

  const MyListingsScreen({super.key, required this.api, required this.userId});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  late Future<List<Listing>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.api.fetchListings(userId: widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Listings")),
      body: FutureBuilder<List<Listing>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final listings = snapshot.data ?? [];
          if (listings.isEmpty) {
            return const Center(child: Text("No listings yet."));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: listings
                .map(
                  (listing) => Card(
                    child: ListTile(
                      title: Text(listing.title),
                      subtitle: Text(
                        "${listing.priceLabel} • ${listing.status.toUpperCase()}",
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
