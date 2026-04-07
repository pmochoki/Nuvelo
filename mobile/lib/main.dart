import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:flutter/services.dart";

import "api.dart";
import "models.dart";

const Color _green = Color(0xFF1DB954);
const Color _greenLight = Color(0xFF2ECC71);
const Color _navy = Color(0xFF0A0F1E);
const Color _navyCard = Color(0xFF111827);
const Color _navyLight = Color(0xFF1E2A3A);
const Color _navyBorder = Color(0xFF2D3748);
const Color _gold = Color(0xFFF59E0B);
const Color _textPrimary = Color(0xFFF9FAFB);
const Color _textSecondary = Color(0xFF9CA3AF);
const Color _textMuted = Color(0xFF4B5563);

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF111827),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const NuveloApp());
}

class NuveloApp extends StatelessWidget {
  const NuveloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Nuvelo",
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _navy,
        colorScheme: const ColorScheme.dark(
          primary: _green,
          secondary: _gold,
          surface: _navyCard,
          background: _navy,
          onPrimary: Colors.white,
          onSurface: _textPrimary,
        ),
        textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: _navy,
          elevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(color: _textPrimary),
          titleTextStyle: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        cardTheme: CardThemeData(
          color: _navyCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _navyBorder),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _navyLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _navyBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _navyBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _green, width: 1.5),
          ),
          hintStyle: GoogleFonts.dmSans(
            color: _textMuted,
            fontSize: 14,
          ),
          labelStyle: GoogleFonts.dmSans(
            color: _textMuted,
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 24,
            ),
            textStyle: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _green,
            side: const BorderSide(color: _green, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: _navyLight,
          selectedColor: _green,
          side: const BorderSide(color: _navyBorder),
          labelStyle: GoogleFonts.dmSans(
            fontSize: 13,
            color: _textSecondary,
          ),
          secondaryLabelStyle: GoogleFonts.dmSans(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: _navyCard,
          selectedItemColor: _green,
          unselectedItemColor: _textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: _navyLight,
          contentTextStyle: GoogleFonts.dmSans(color: _textPrimary),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: _navyBorder,
          thickness: 1,
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

// Gradient button used across Sign In, Listing Detail, Post Listing
Widget _gradientButton(String label, IconData icon, VoidCallback onPressed) {
  return Container(
    width: double.infinity,
    height: 54,
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [_green, _greenLight]),
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: _green.withOpacity(0.35),
          blurRadius: 16,
          offset: const Offset(0, 6),
        )
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: Colors.white, size: 18),
          ],
        ),
      ),
    ),
  );
}

// Category gradient backgrounds used in listing cards and detail hero
List<Color> _catGradient(String cat) {
  switch (cat) {
    case "rentals":
    case "real-estate":
      return [const Color(0xFF1E3A5F), const Color(0xFF0F2027)];
    case "vehicles":
      return [const Color(0xFF2D1B69), const Color(0xFF11998E)];
    case "electronics":
      return [const Color(0xFF1A1A2E), const Color(0xFF16213E)];
    case "clothes":
      return [const Color(0xFF4A0E8F), const Color(0xFF2D1B69)];
    case "jobs":
      return [const Color(0xFF0F3443), const Color(0xFF34E89E)];
    default:
      return [const Color(0xFF141E30), const Color(0xFF243B55)];
  }
}

// Category icon lookup used in listing cards and detail hero
IconData _catIcon(String cat) {
  switch (cat) {
    case "vehicles":
      return Icons.directions_car_rounded;
    case "electronics":
      return Icons.phone_android_rounded;
    case "clothes":
      return Icons.checkroom_rounded;
    case "rentals":
    case "real-estate":
      return Icons.apartment_rounded;
    case "jobs":
      return Icons.work_outline_rounded;
    case "services":
      return Icons.build_outlined;
    default:
      return Icons.sell_outlined;
  }
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

  Widget _navItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isActive = _index == index;
    return GestureDetector(
      onTap: () => setState(() => _index = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? _green.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? _green : _textMuted,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isActive ? _green : _textMuted,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sellFab() {
    return GestureDetector(
      onTap: () => setState(() => _index = 2),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_green, _greenLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _green.withOpacity(0.4),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: _navyCard,
          border: Border(top: BorderSide(color: _navyBorder)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home_rounded, Icons.home_outlined, "Home"),
                _navItem(1, Icons.bookmark_rounded, Icons.bookmark_border, "Saved"),
                _sellFab(),
                _navItem(3, Icons.chat_bubble_rounded, Icons.chat_bubble_outline_rounded, "Messages"),
                _navItem(4, Icons.person_rounded, Icons.person_outline_rounded, "Profile"),
              ],
            ),
          ),
        ),
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
      backgroundColor: _navy,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F1A2E), _navyCard],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.storefront_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Nuvelo",
                        style: GoogleFonts.dmSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Welcome back 👋",
                    style: GoogleFonts.dmSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Discover. Connect. Trade. Anywhere.",
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: _textPrimary),
                    decoration: const InputDecoration(
                      hintText: "Your name",
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: _textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _contactController,
                    style: const TextStyle(color: _textPrimary),
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: "Phone or email",
                      prefixIcon: Icon(
                        Icons.phone_android,
                        color: _textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _otpController,
                    style: const TextStyle(color: _textPrimary),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "OTP code",
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: _textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_isSubmitting)
                    const Center(
                      child: CircularProgressIndicator(color: _green),
                    )
                  else
                    _gradientButton(
                      "Sign In",
                      Icons.arrow_forward_rounded,
                      _submit,
                    ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      "Admin access is managed separately.",
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: _textMuted,
                      ),
                    ),
                  ),
                ],
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
          return const Center(
            child: CircularProgressIndicator(color: _green),
          );
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
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F1A2E), _navy],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _navyLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _navyBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _location.isEmpty ? "Your City" : _location,
                              style: GoogleFonts.dmSans(
                                color: _textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _navyLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _navyBorder),
                        ),
                        child: const Icon(Icons.notifications_none_rounded, color: _textSecondary, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Discover\neverything.",
                    style: GoogleFonts.dmSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: _navyLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _navyBorder),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        const Icon(Icons.search, color: _textMuted, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            style: const TextStyle(color: _textPrimary),
                            decoration: InputDecoration(
                              hintText: "Search listings near you…",
                              hintStyle: GoogleFonts.dmSans(color: _textMuted, fontSize: 14),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onChanged: (v) => setState(() => _query = v),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(6),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                children: [
                  _pill(null, "All", Icons.apps_rounded),
                  ...widget.categories.map((c) => _pill(c.id, c.name, _categoryIcon(c.id))),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D3321), Color(0xFF1A5C3A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "🌍 New on Nuvelo",
                            style: GoogleFonts.dmSans(
                              color: _green,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "List your first item\nfor free today",
                          style: GoogleFonts.dmSans(
                            color: _textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Post now",
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.rocket_launch_rounded, color: _green, size: 56),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Text(
                    "Recent listings",
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.grid_view_rounded,
                      color: _trendingGridView ? _green : _textMuted,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _trendingGridView = true),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: Icon(
                      Icons.view_list_rounded,
                      color: !_trendingGridView ? _green : _textMuted,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _trendingGridView = false),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
          if (filtered.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    "No listings match your filters.",
                    style: TextStyle(color: _textSecondary),
                  ),
                ),
              ),
            ),
          if (filtered.isNotEmpty && !_trendingGridView)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _listCard(ctx, filtered[i]),
                  childCount: filtered.length,
                ),
              ),
            ),
          if (filtered.isNotEmpty && _trendingGridView)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _gridCard(ctx, filtered[i]),
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _pill(String? id, String label, IconData icon) {
    final selected = _categoryId == id;
    return GestureDetector(
      onTap: () => setState(() => _categoryId = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _green : _navyLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? _green : _navyBorder),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? Colors.white : _textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : _textSecondary,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listCard(BuildContext context, Listing listing) {
    final isFav = widget.favoriteIds.contains(listing.id);
    return GestureDetector(
      onTap: () => openListingDetails(
        context: context,
        listing: listing,
        isFavorite: isFav,
        onToggleFavorite: () => widget.onToggleFavorite(listing.id),
        onReport: () => widget.onReportListing(listing),
        onBlock: () => widget.onBlockUser(listing.sellerId),
        onStartChat: () => widget.onStartChat(listing),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _navyCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _navyBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                gradient: LinearGradient(
                  colors: _catGradient(listing.categoryId),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Icon(
                  _catIcon(listing.categoryId),
                  color: Colors.white.withOpacity(0.15),
                  size: 40,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style: GoogleFonts.dmSans(
                        color: _textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      listing.priceLabel,
                      style: GoogleFonts.dmSans(
                        color: _green,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: _textMuted),
                        const SizedBox(width: 3),
                        Text(
                          listing.location,
                          style: GoogleFonts.dmSans(color: _textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFav ? Colors.redAccent : _textMuted,
                  size: 22,
                ),
                onPressed: () => widget.onToggleFavorite(listing.id),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gridCard(BuildContext context, Listing listing) {
    final isFav = widget.favoriteIds.contains(listing.id);
    return GestureDetector(
      onTap: () => openListingDetails(
        context: context,
        listing: listing,
        isFavorite: isFav,
        onToggleFavorite: () => widget.onToggleFavorite(listing.id),
        onReport: () => widget.onReportListing(listing),
        onBlock: () => widget.onBlockUser(listing.sellerId),
        onStartChat: () => widget.onStartChat(listing),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _navyCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _navyBorder),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    gradient: LinearGradient(
                      colors: _catGradient(listing.categoryId),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _catIcon(listing.categoryId),
                      color: Colors.white.withOpacity(0.12),
                      size: 44,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => widget.onToggleFavorite(listing.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFav ? Colors.redAccent : Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.priceLabel,
                      style: GoogleFonts.dmSans(
                        color: _green,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.title,
                      style: GoogleFonts.dmSans(
                        color: _textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      listing.location,
                      style: GoogleFonts.dmSans(color: _textMuted, fontSize: 11),
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
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Listings",
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...listings.map(
            (listing) {
              final gradient = _catGradient(listing.categoryId);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: _navyCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _navyBorder),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => openListingDetails(
                      context: context,
                      listing: listing,
                      isFavorite: false,
                      onToggleFavorite: () {},
                      onReport: () => onReportListing(listing),
                      onBlock: () => onBlockUser(listing.sellerId),
                      onStartChat: () => onStartChat(listing),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: gradient,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _catIcon(listing.categoryId),
                            color: _textPrimary.withOpacity(0.85),
                            size: 30,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 12,
                              top: 12,
                              bottom: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  listing.title,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: _textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: _textMuted,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        listing.location,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          color: _textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      listing.priceLabel,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: _green,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _navyLight,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: _navyBorder),
                                      ),
                                      child: Text(
                                        listing.status.toUpperCase(),
                                        style: GoogleFonts.dmSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: _textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
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

  Widget _badge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailChip(String key, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _navyLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _navyBorder),
      ),
      child: Text(
        "$key: $value",
        style: GoogleFonts.dmSans(color: _textSecondary, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as ListingDetailsArgs?;
    final data = args?.listing ?? sampleListings.first;
    final isFavorite = _isFavorite ?? args?.isFavorite ?? false;

    return Scaffold(
      backgroundColor: _navy,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: _navy,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
                  onPressed: () {},
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFavorite ? Colors.redAccent : Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    args?.onToggleFavorite();
                    setState(() => _isFavorite = !isFavorite);
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _catGradient(data.categoryId),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    _catIcon(data.categoryId),
                    color: Colors.white.withOpacity(0.08),
                    size: 120,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          data.title,
                          style: GoogleFonts.dmSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        data.priceLabel,
                        style: GoogleFonts.dmSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: _textMuted),
                      const SizedBox(width: 4),
                      Text(
                        data.location,
                        style: GoogleFonts.dmSans(color: _textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _navyCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _navyBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              data.sellerName.isNotEmpty ? data.sellerName[0] : "?",
                              style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.sellerName,
                                style: GoogleFonts.dmSans(
                                  color: _textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                "Seller",
                                style: GoogleFonts.dmSans(
                                  color: _textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text("View profile"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _badge("Verified", Icons.verified_rounded, _green),
                      _badge("Secure chat", Icons.lock_outline_rounded, const Color(0xFF60A5FA)),
                      _badge("Fast responder", Icons.access_time_rounded, _gold),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "About this listing",
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.description,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: _textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (data.categoryFields.isNotEmpty) ...[
                    Text(
                      "Details",
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _detailChip("Condition", data.condition),
                        ...data.categoryFields.entries.map(
                          (e) => _detailChip(e.key, e.value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _gold.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _gold.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_rounded, color: _gold, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Use secure chat and meet in public for safe transactions.",
                            style: GoogleFonts.dmSans(
                              color: _textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      OutlinedButton(onPressed: args?.onReport, child: const Text("Report")),
                      const SizedBox(width: 12),
                      OutlinedButton(onPressed: args?.onBlock, child: const Text("Block")),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: _navyCard,
          border: Border(top: BorderSide(color: _navyBorder)),
        ),
        child: _gradientButton(
          "Chat with seller",
          Icons.chat_bubble_outline_rounded,
          args?.onStartChat ?? () {},
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
    return Scaffold(
      backgroundColor: _navy,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F1A2E), _navyCard],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 16,
              16,
              16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.maybePop(context),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.dmSans(
                      color: _textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  "New Advert",
                  style: GoogleFonts.dmSans(
                    color: _textPrimary,
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
                    for (final controller in _fieldControllers.values) {
                      controller.clear();
                    }
                    setState(() => _images.clear());
                  },
                  child: Text(
                    "Clear",
                    style: GoogleFonts.dmSans(
                      color: _green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: _green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: _navyBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: _navyBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Step 1 of 3 — Basic info",
                  style: GoogleFonts.dmSans(color: _textSecondary, fontSize: 12),
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
                  style: const TextStyle(color: _textPrimary),
                  decoration: const InputDecoration(hintText: "Title*"),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _categoryId,
                  dropdownColor: _navyCard,
                  style: const TextStyle(color: _textPrimary),
                  decoration: const InputDecoration(hintText: "Category*"),
                  items: categories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(
                            c.name,
                            style: const TextStyle(color: _textPrimary),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _categoryId = v);
                    }
                  },
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _addPlaceholderImage,
                  child: Container(
                    height: 90,
                    decoration: BoxDecoration(
                      color: _navyLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _green.withOpacity(0.5), width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt_outlined, color: _green, size: 28),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Add photos",
                              style: GoogleFonts.dmSans(
                                color: _green,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "${_images.length}/8 added",
                              style: GoogleFonts.dmSans(color: _textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        value: _locationController.text.isEmpty ? null : _locationController.text,
                        dropdownColor: _navyCard,
                        style: const TextStyle(color: _textPrimary),
                        decoration: const InputDecoration(hintText: "Region"),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text("Region", style: TextStyle(color: _textMuted)),
                          ),
                          ...["Budapest", "Vienna", "Prague", "Other"].map(
                            (s) => DropdownMenuItem<String?>(
                              value: s,
                              child: Text(s, style: const TextStyle(color: _textPrimary)),
                            ),
                          ),
                        ],
                        onChanged: (v) {
                          _locationController.text = v ?? "";
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _priceController,
                        style: const TextStyle(color: _textPrimary),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: "Price (HUF)"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  style: const TextStyle(color: _textPrimary),
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: "Description",
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                _buildCategoryFields(),
                const SizedBox(height: 24),
                _gradientButton(
                  _submitting ? "Submitting…" : "Continue",
                  Icons.arrow_forward_rounded,
                  _submitting ? () {} : _submitListing,
                ),
                const SizedBox(height: 16),
                Text(
                  "By posting, you accept the Terms of Use and confirm compliance with our Safety Tips.",
                  style: GoogleFonts.dmSans(fontSize: 12, color: _textMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
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
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F1A2E), _navyCard],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 16,
              16,
              16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Messages",
                  style: GoogleFonts.dmSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: _navyLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _navyBorder),
                  ),
                  child: TextField(
                    style: const TextStyle(color: _textPrimary),
                    decoration: InputDecoration(
                      hintText: "Search in Messages",
                      hintStyle: GoogleFonts.dmSans(color: _textMuted, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: _textMuted, size: 22),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: _navyCard,
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
                  return const Center(
                    child: CircularProgressIndicator(color: _green),
                  );
                }
                final conversations = snapshot.data ?? [];
                if (conversations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: _textMuted,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No conversations yet.",
                          style: GoogleFonts.dmSans(color: _textMuted, fontSize: 15),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conv = conversations[index];
                    final peerId = conv.buyerId == widget.userId
                        ? conv.sellerId
                        : conv.buyerId;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: _navyCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _navyBorder),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _navyLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _navyBorder),
                          ),
                          child: Center(
                            child: Text(
                              peerId.isNotEmpty ? peerId[0].toUpperCase() : "?",
                              style: GoogleFonts.dmSans(
                                color: _green,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          "User $peerId",
                          style: GoogleFonts.dmSans(
                            color: _textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          "Listing ${conv.listingId}",
                          style: GoogleFonts.dmSans(
                            color: _textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Text(
                          "Now",
                          style: GoogleFonts.dmSans(
                            color: _textMuted,
                            fontSize: 12,
                          ),
                        ),
                        onTap: () => widget.onOpenConversation(conv),
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
                color: selected ? _green : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: selected ? _green : _textMuted,
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

  Widget _favTab(String label, int index) {
    final selected = _tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _green : Colors.transparent,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            color: selected ? Colors.white : _textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F1A2E), _navyCard],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 16,
              16,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Saved",
                  style: GoogleFonts.dmSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _favTab("Ads", 0),
                    const SizedBox(width: 4),
                    _favTab("Searches", 1),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _tabIndex == 0 ? _buildAdsTab() : _buildSearchesTab(),
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
          return const Center(
            child: CircularProgressIndicator(color: _green),
          );
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
                    Icons.bookmark_border_rounded,
                    size: 80,
                    color: _textMuted.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "You don't have favorite ads yet",
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Save ads you're interested in to find them here later.",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: _textSecondary,
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
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        color: _navyCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _navyBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(colors: _catGradient(listing.categoryId)),
          ),
          child: Icon(
            _catIcon(listing.categoryId),
            color: Colors.white.withOpacity(0.2),
            size: 26,
          ),
        ),
        title: Text(
          listing.title,
          style: GoogleFonts.dmSans(
            color: _textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          listing.priceLabel,
          style: GoogleFonts.dmSans(color: _green, fontSize: 13),
        ),
        trailing: const Icon(Icons.chevron_right, color: _textMuted),
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
                Icons.search_off_rounded,
                size: 80,
                color: _textMuted.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 16),
              Text(
                "No saved searches yet",
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Save a search to get notified when new ads match.",
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: _textSecondary,
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
          color: _navyCard,
          margin: const EdgeInsets.only(bottom: 1),
          child: ListTile(
            title: Text(
              search.query.isEmpty ? "All listings" : search.query,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: _textPrimary,
              ),
            ),
            subtitle: Text(
              [
                if (search.categoryId != null) search.categoryId!,
                if (search.location != null) search.location!,
              ].whereType<String>().join(" • "),
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: _textSecondary,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: _textMuted, size: 22),
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
      return const Scaffold(
        backgroundColor: _navy,
        body: Center(
          child: Text(
            "No conversation.",
            style: TextStyle(color: _textSecondary),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: _navy,
      appBar: AppBar(
        backgroundColor: _navyCard,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Listing ${args.listingId}",
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            Text(
              "Tap to view listing",
              style: GoogleFonts.dmSans(fontSize: 11, color: _textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined, color: _textSecondary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: _textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Message>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: _green),
                  );
                }
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: _textMuted,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No messages yet.",
                          style: GoogleFonts.dmSans(color: _textMuted, fontSize: 15),
                        ),
                        Text(
                          "Start the conversation below.",
                          style: GoogleFonts.dmSans(color: _textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: messages.map((msg) {
                    return Align(
                      alignment: msg.senderId == args.currentUserId
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: _DarkBubble(
                        text: msg.text,
                        isMine: msg.senderId == args.currentUserId,
                        time: msg.createdAt,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
            decoration: const BoxDecoration(
              color: _navyCard,
              border: Border(top: BorderSide(color: _navyBorder)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _navyLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _navyBorder),
                  ),
                  child: const Icon(
                    Icons.attach_file_rounded,
                    color: _textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: _textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Type a message…",
                      hintStyle: GoogleFonts.dmSans(color: _textMuted),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_green, _greenLight]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _green.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkBubble extends StatelessWidget {
  final String text;
  final bool isMine;
  final String time;

  const _DarkBubble({
    required this.text,
    required this.isMine,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final timeLabel =
        time.length > 15 ? time.substring(11, 16) : time;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMine ? _green : _navyCard,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMine ? 16 : 4),
                bottomRight: Radius.circular(isMine ? 4 : 16),
              ),
              border: isMine ? null : Border.all(color: _navyBorder),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isMine ? Colors.white : _textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            timeLabel,
            style: GoogleFonts.dmSans(color: _textMuted, fontSize: 10),
          ),
        ],
      ),
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
    final initials = user.name.isNotEmpty ? user.name[0].toUpperCase() : "?";
    final memberSinceLabel =
        (user.memberSince.isNotEmpty ? user.memberSince : "").trim();
    final favoritesCount = favoriteIds.length;
    final savedSearchCount = savedSearches.length;

    final hasEmail = user.email != null && user.email!.isNotEmpty;

    // Approximate "sales rate" from approved vs total listings when available
    final listingsTotal = user.listingCount;
    final approved = user.approvedListings;
    final salesRate =
        listingsTotal > 0 ? ((approved / listingsTotal) * 100).clamp(0, 100) : 0.0;

    return Container(
      color: _navy,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 20,
                20,
                24,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D1F12), _navy],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "Profile",
                        style: GoogleFonts.dmSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _navyCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _navyBorder),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SettingsScreen(
                                user: user,
                                onSignOut: onSignOut,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.settings_outlined,
                                size: 16,
                                color: _textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Settings",
                                style: GoogleFonts.dmSans(
                                  color: _textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_green, _greenLight],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: _green.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: GoogleFonts.dmSans(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: _green,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: _navy, width: 2),
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: GoogleFonts.dmSans(
                                color: _textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (hasEmail) ...[
                              const SizedBox(height: 2),
                              Text(
                                user.email!,
                                style: GoogleFonts.dmSans(
                                  color: _textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _green.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _green.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                roleLabel(role),
                                style: GoogleFonts.dmSans(
                                  color: _green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    decoration: BoxDecoration(
                      color: _navyCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _navyBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: _textMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                memberSinceLabel.isNotEmpty
                                    ? "Member since $memberSinceLabel"
                                    : "Member since —",
                                style: GoogleFonts.dmSans(
                                  color: _textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _ProfileBadge(
                                label: "Email verified",
                                icon: Icons.email_outlined,
                                active: user.emailVerified,
                              ),
                              _ProfileBadge(
                                label: "Phone verified",
                                icon: Icons.phone_outlined,
                                active: user.phoneVerified,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _green.withOpacity(0.12),
                          _navyCard,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _green.withOpacity(0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Seller performance",
                              style: GoogleFonts.dmSans(
                                color: _textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.trending_up_rounded,
                              color: _green,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                value: listingsTotal > 0
                                    ? "${salesRate.toStringAsFixed(0)}%"
                                    : "—",
                                label: "Sales rate",
                                icon: Icons.percent_rounded,
                                color: _green,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatCard(
                                value: approved.toString(),
                                label: "Approved ads",
                                icon: Icons.check_circle_outline,
                                color: const Color(0xFF60A5FA),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatCard(
                                value: listingsTotal.toString(),
                                label: "Total ads",
                                icon: Icons.list_alt_rounded,
                                color: _gold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionHeader(
                    title: "Favorites",
                    action: favoritesCount > 0 ? "See all" : null,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: _navyCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _navyBorder),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              favoritesCount > 0
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: _textMuted,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              favoritesCount > 0
                                  ? "$favoritesCount favorites"
                                  : "No favorites yet",
                              style: GoogleFonts.dmSans(
                                color: _textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionHeader(
                    title: "Saved searches",
                    action: savedSearchCount > 0 ? "See all" : null,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: _navyCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _navyBorder),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.bookmark_border_rounded,
                              color: _textMuted,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              savedSearchCount > 0
                                  ? "$savedSearchCount saved searches"
                                  : "No saved searches yet",
                              style: GoogleFonts.dmSans(
                                color: _textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _PrimaryButton(
                    label: "My Listings",
                    icon: Icons.list_alt_rounded,
                    onPressed: () => Navigator.push(
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
                  OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: BorderSide(color: _navyBorder),
                      foregroundColor: _textPrimary,
                    ),
                    icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                    label: Text(
                      "Switch role",
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const _PrimaryButton({
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_green, _greenLight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _green.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;

  const _ProfileBadge({
    required this.label,
    required this.icon,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = active ? _green : _textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.15) : _navyLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? color.withOpacity(0.4) : _navyBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: active ? color : _textSecondary,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.dmSans(
              color: active ? color : _textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;

  const _SectionHeader({
    required this.title,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.dmSans(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        if (action != null)
          Text(
            action!,
            style: GoogleFonts.dmSans(
              color: _green,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _navyCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _navyBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.dmSans(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.dmSans(
              color: _textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
      backgroundColor: _navyCard,
      appBar: AppBar(
        backgroundColor: _navy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Settings",
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _settingsTile(
            icon: Icons.person_outline,
            iconBg: _navy,
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
            iconBg: _green,
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
            iconBg: _green,
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
            iconBg: _green,
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
            label: "Nuvelo delivery",
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
            label: "About Nuvelo",
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
      color: _navyCard,
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
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary,
                  ),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: _textSecondary,
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: _textSecondary, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, color: _navyBorder);
}

class BusinessDetailsScreen extends StatelessWidget {
  const BusinessDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navyCard,
      appBar: AppBar(
        backgroundColor: _navy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _green),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Business details",
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
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
      color: _navyCard,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: _textSecondary, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, color: _navyBorder);
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
      appBar: AppBar(
        title: Text(
          "My Listings",
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
      ),
      body: FutureBuilder<List<Listing>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_green),
              ),
            );
          }
          final listings = snapshot.data ?? [];
          if (listings.isEmpty) {
            return Center(
              child: Text(
                "No listings yet.",
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: _textSecondary,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              final gradient = _catGradient(listing.categoryId);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: _navyCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _navyBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradient,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _catIcon(listing.categoryId),
                        color: _textPrimary.withOpacity(0.85),
                        size: 32,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 12,
                          top: 14,
                          bottom: 14,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listing.title,
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              listing.priceLabel,
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _navyLight,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: _navyBorder),
                                  ),
                                  child: Text(
                                    listing.status.toUpperCase(),
                                    style: GoogleFonts.dmSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: _textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
