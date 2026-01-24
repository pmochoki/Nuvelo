import "package:flutter/material.dart";

import "api.dart";
import "models.dart";

void main() {
  runApp(const InterHungaryApp());
}

class InterHungaryApp extends StatelessWidget {
  const InterHungaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF16A34A);
    return MaterialApp(
      title: "InterHungary",
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: "Inter",
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1,
          shadowColor: Colors.black.withOpacity(0.08),
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryGreen, width: 1.5),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryGreen,
            side: const BorderSide(color: primaryGreen),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFF1F5F9),
          selectedColor: primaryGreen,
          labelStyle: const TextStyle(color: Colors.black),
          secondaryLabelStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: primaryGreen,
          unselectedItemColor: Color(0xFF64748B),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.black,
          contentTextStyle: TextStyle(color: Colors.white),
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
    UserRole role,
    String? contact,
    String? otp
  ) async {
    final trimmedContact = contact?.trim();
    final isEmail = trimmedContact != null && trimmedContact.contains("@");
    final profile = await _api.login(
      name: name,
      role: roleId(role),
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

  List<Widget> get _pages {
    final role = widget.role;
    final pages = <Widget>[
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
    if (role != UserRole.customer) {
      pages.insert(
        1,
        PostListingScreen(
          role: role,
          user: widget.user,
          api: widget.api,
        )
      );
    }
    return pages;
  }

  List<BottomNavigationBarItem> get _items {
    final role = widget.role;
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      const BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile")
    ];
    if (role != UserRole.customer) {
      items.insert(
        1,
        const BottomNavigationBarItem(icon: Icon(Icons.add_box), label: "Post")
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
        items: _items,
      ),
    );
  }
}

class SignInScreen extends StatefulWidget {
  final Future<void> Function(
    String name,
    UserRole role,
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

  Future<void> _submit(UserRole role) async {
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
      await widget.onSignIn(name, role, contact, otp);
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
    final roles = UserRole.values;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text("Sign in",
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text(
              "Choose how you want to use the app. Admin access is managed separately."
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Your name"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contactController,
              decoration: const InputDecoration(
                labelText: "Email or phone",
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(labelText: "OTP code"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            if (_isSubmitting)
              const Center(child: CircularProgressIndicator()),
            if (!_isSubmitting)
              ...roles.map(
                (role) => Card(
                  child: ListTile(
                    title: Text(roleLabel(role)),
                    subtitle: Text(_roleDescription(role)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _submit(role),
                  ),
                ),
              )
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
    required this.onStartChat
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
                onStartChat: widget.onStartChat
              ),
            )
          ],
        );
      },
    );
  }
}

String _roleDescription(UserRole role) {
  switch (role) {
    case UserRole.agent:
      return "Agenting houses or apartments for clients.";
    case UserRole.landlord:
      return "Manage and list your own properties.";
    case UserRole.customer:
      return "Browse and buy, rent, or apply.";
    case UserRole.seller:
      return "Sell items and track your sales rate.";
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
    required this.onStartChat
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
      onStartChat: onStartChat
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

  const CustomerBrowseScreen({
    super.key,
    required this.listings,
    required this.categories,
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.onSaveSearch,
    required this.onBlockUser,
    required this.onReportListing,
    required this.onStartChat
  });

  @override
  State<CustomerBrowseScreen> createState() => _CustomerBrowseScreenState();
}

class _CustomerBrowseScreenState extends State<CustomerBrowseScreen> {
  String _query = "";
  String? _categoryId;
  String _location = "";

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

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Discover", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          const Text(
            "Trusted listings from verified sellers. Browse with confidence.",
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Search",
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(labelText: "Location"),
                    onChanged: (value) => setState(() => _location = value),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Popular categories",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text("All"),
                        selected: _categoryId == null,
                        onSelected: (_) => setState(() => _categoryId = null),
                      ),
                      ...widget.categories.map(
                        (category) => ChoiceChip(
                          label: Text(category.name),
                          selected: _categoryId == category.id,
                          onSelected: (_) =>
                              setState(() => _categoryId = category.id),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: _saveSearch,
                      icon: const Icon(Icons.bookmark_add),
                      label: const Text("Save search"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.verified, color: Color(0xFF16A34A)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Verified sellers, secure chat, and clear pricing.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text("Listings", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (filtered.isEmpty)
            const Text("No listings match your filters."),
          ...filtered.map(
            (listing) => Card(
              child: ListTile(
                isThreeLine: true,
                title: Text(listing.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${listing.location} • ${listing.priceLabel}"),
                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        Icon(Icons.verified,
                            size: 16, color: Color(0xFF16A34A)),
                        SizedBox(width: 6),
                        Text("Verified seller"),
                        SizedBox(width: 12),
                        Icon(Icons.lock_outline,
                            size: 16, color: Color(0xFF16A34A)),
                        SizedBox(width: 6),
                        Text("Secure chat"),
                      ],
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(
                    widget.favoriteIds.contains(listing.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.favoriteIds.contains(listing.id)
                        ? Colors.redAccent
                        : null,
                  ),
                  onPressed: () => widget.onToggleFavorite(listing.id),
                ),
                onTap: () => openListingDetails(
                  context: context,
                  listing: listing,
                  isFavorite: widget.favoriteIds.contains(listing.id),
                  onToggleFavorite: () => widget.onToggleFavorite(listing.id),
                  onReport: () => widget.onReportListing(listing),
                  onBlock: () => widget.onBlockUser(listing.sellerId),
                  onStartChat: () => widget.onStartChat(listing),
                ),
              ),
            ),
          ),
        ],
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
      appBar: AppBar(title: const Text("Listing")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text("${data.location} • ${data.priceLabel}"),
            const SizedBox(height: 12),
            Text(data.description),
            const SizedBox(height: 12),
            Text("Seller: ${data.sellerName}"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                Chip(
                  avatar: Icon(Icons.verified,
                      size: 18, color: Color(0xFF16A34A)),
                  label: Text("Verified seller"),
                ),
                Chip(
                  avatar: Icon(Icons.lock_outline,
                      size: 18, color: Color(0xFF16A34A)),
                  label: Text("Secure chat"),
                ),
                Chip(
                  avatar: Icon(Icons.access_time,
                      size: 18, color: Color(0xFF16A34A)),
                  label: Text("Fast responder"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text("Condition: ${data.condition}")),
                ...data.categoryFields.entries.map(
                  (entry) => Chip(label: Text("${entry.key}: ${entry.value}")),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: const [
                    Icon(Icons.shield_outlined, color: Color(0xFF16A34A)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Use secure chat and meet in public for safe transactions.",
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    args?.onToggleFavorite();
                    setState(() => _isFavorite = !isFavorite);
                  },
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.redAccent : null,
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
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: args?.onStartChat,
                child: const Text("Chat with seller")
              ),
            )
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
    final title = widget.role == UserRole.agent || widget.role == UserRole.landlord
        ? "Add a property"
        : "Post a listing";
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: "Title"),
          ),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: "Description"),
            maxLines: 4
          ),
          DropdownButtonFormField<String>(
            value: _categoryId,
            decoration: const InputDecoration(labelText: "Category"),
            items: categories
                .map(
                  (category) => DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() => _categoryId = value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _condition,
            decoration: const InputDecoration(labelText: "Condition"),
            items: const [
              DropdownMenuItem(value: "new", child: Text("New")),
              DropdownMenuItem(value: "good", child: Text("Good")),
              DropdownMenuItem(value: "used", child: Text("Used"))
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() => _condition = value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceController,
            decoration: const InputDecoration(labelText: "Price"),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(labelText: "Location"),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _addPlaceholderImage,
            icon: const Icon(Icons.photo_library_outlined),
            label: Text("Add photos (${_images.length}/8)"),
          ),
          const SizedBox(height: 12),
          _buildCategoryFields(),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submitting ? null : _submitListing,
            child: Text(_submitting ? "Submitting..." : "Submit for review")
          )
        ],
      ),
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

  @override
  void initState() {
    super.initState();
    _future = widget.api.fetchConversations(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<Conversation>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final conversations = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text("Chats", style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              if (conversations.isEmpty) const Text("No conversations yet."),
              ...conversations.map((conversation) {
                final peerId = conversation.buyerId == widget.userId
                    ? conversation.sellerId
                    : conversation.buyerId;
                return Card(
                  child: ListTile(
                    title: Text("Listing ${conversation.listingId}"),
                    subtitle: Text("With $peerId"),
                    onTap: () => widget.onOpenConversation(conversation),
                  ),
                );
              })
            ],
          );
        },
      ),
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
    final memberSince =
        user.memberSince.isEmpty ? "Unknown" : user.memberSince.split("T").first;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Profile", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(user.name),
            subtitle: Text(user.email ?? "No email on file")
          ),
          const SizedBox(height: 8),
          Chip(label: Text(roleLabel(role))),
          const SizedBox(height: 8),
          Text(
            "Member since $memberSince",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              Chip(
                label: Text(
                  user.emailVerified ? "Email verified" : "Email unverified"
                ),
              ),
              Chip(
                label: Text(
                  user.phoneVerified ? "Phone verified" : "Phone unverified"
                ),
              ),
              if (user.banned) const Chip(label: Text("Account restricted")),
            ],
          ),
          if (role == UserRole.seller) ...[
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text("Seller performance"),
                subtitle: const Text("Sales rate: 82% • 24 responses"),
                trailing: const Icon(Icons.trending_up)
              ),
            )
          ],
          const SizedBox(height: 12),
          Text("Favorites", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (favoriteIds.isEmpty) const Text("No favorites yet."),
          ...sampleListings
              .where((listing) => favoriteIds.contains(listing.id))
              .map(
                (listing) => Card(
                  child: ListTile(
                    title: Text(listing.title),
                    subtitle: Text(listing.priceLabel),
                  ),
                ),
              ),
          const SizedBox(height: 12),
          Text("Saved searches", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (savedSearches.isEmpty) const Text("No saved searches yet."),
          ...savedSearches.map(
            (search) => Card(
              child: ListTile(
                title: Text(search.query.isEmpty
                    ? "All listings"
                    : search.query),
                subtitle: Text([
                  if (search.categoryId != null) search.categoryId,
                  if (search.location != null) search.location,
                ].whereType<String>().join(" • ")),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MyListingsScreen(
                  api: api,
                  userId: user.id,
                )
              ),
            ),
            child: const Text("My Listings")
          ),
          TextButton(onPressed: onSignOut, child: const Text("Switch role"))
        ],
      ),
    );
  }
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
