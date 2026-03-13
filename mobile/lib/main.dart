import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:flutter/services.dart";

import "api.dart";
import "models.dart";
import "theme.dart";

// Centralized color palette (IHColors) is defined in `theme.dart`.
// These aliases preserve existing private names used across the file,
// while ensuring all colors stay consistent with the redesign theme.
const Color _green = IHColors.green;
const Color _greenLight = IHColors.greenLight;
const Color _navy = IHColors.navy;
const Color _navyCard = IHColors.navyCard;
const Color _navyLight = IHColors.navyLight;
const Color _navyBorder = IHColors.navyBorder;
const Color _gold = IHColors.gold;
const Color _textPrimary = IHColors.textPrimary;
const Color _textSecondary = IHColors.textSecondary;
const Color _textMuted = IHColors.textMuted;

// Aliases for legacy color names (for compatibility)
const Color _jijiGreen = _green;
const Color _jijiGreenDark = _green;
const Color _jijiBg = _navy;
const Color _jijiCard = _navyCard;
const Color _jijiText = _textPrimary;
const Color _jijiTextGray = _textSecondary;
const Color _jijiSectionBg = _navy;

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF111827),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
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
        cardTheme: CardTheme(
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
                        "InterHungary",
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
                    "Hungary's marketplace for everyone.",
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
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0F1A2E), _navy],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _pill(
                        label: _location.isEmpty ? "Budapest, HU" : _location,
                        icon: Icons.keyboard_arrow_down,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        color: _textPrimary,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Discover\neverything.",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: _navyLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _navyBorder),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search...",
                        hintStyle: GoogleFonts.poppins(color: _textMuted, fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: _textMuted, size: 22),
                        filled: true,
                        fillColor: _navyLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  _pill(label: "All", selected: _categoryId == null, onTap: () => setState(() => _categoryId = null)),
                  ...widget.categories.map(
                    (c) => _pill(
                      label: c.name,
                      selected: _categoryId == c.id,
                      onTap: () => setState(() => _categoryId = c.id),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D3321), Color(0xFF1A5C3A)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text("🇭🇺", style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "New in Budapest / List your first item…",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent listings",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.view_list,
                          color: _trendingGridView ? _textSecondary : _green,
                          size: 22,
                        ),
                        onPressed: () => setState(() => _trendingGridView = false),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: Icon(
                          Icons.grid_view,
                          color: _trendingGridView ? _green : _textSecondary,
                          size: 22,
                        ),
                        onPressed: () => setState(() => _trendingGridView = true),
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    "No listings match your filters.",
                    style: GoogleFonts.poppins(color: _textSecondary),
                  ),
                ),
              ),
            ),
          if (filtered.isNotEmpty && !_trendingGridView)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final listing = filtered[index];
                  return _listCard(context, listing);
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
                    return _gridCard(context, listing);
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _pill({required String label, IconData? icon, bool selected = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? _green : _navyCard,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: selected ? _green : _navyBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: selected ? Colors.white : _textSecondary,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 4),
                  Icon(icon, color: selected ? Colors.white : _textMuted, size: 18),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Redesign listing card mapped to real `Listing` model + callbacks
  //
  // - `listing.title` / `listing.location` / `listing.priceLabel`:
  //   fill the visual fields from the backend `Listing` entity (replaces
  //   the redesign's sample map like `{'title': ..., 'location': ...}`).
  // - `widget.favoriteIds` / `widget.onToggleFavorite`:
  //   drive the heart icon state and toggle using the existing favorites API.
  // - `openListingDetails(...)`:
  //   keeps original navigation & chat/report/block flows while using
  //   the new gradient image/header layout from the redesign.
  Widget _listCard(BuildContext context, Listing listing) {
    final gradient = _catGradient(listing.categoryId);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: _navyCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _navyBorder),
      ),
      child: Material(
        color: Colors.transparent,
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
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradient,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_catIcon(listing.categoryId), color: _textPrimary.withOpacity(0.9), size: 32),
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
                          color: _textPrimary,
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
                          color: _green,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        listing.location,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    widget.favoriteIds.contains(listing.id) ? Icons.favorite : Icons.favorite_border,
                    color: widget.favoriteIds.contains(listing.id) ? Colors.red : _textSecondary,
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

  // Grid variant of the redesign listing card wired to real data:
  //
  // - Uses the same `Listing` fields (`title`, `location`, `priceLabel`)
  //   and favorite IDs as the list view, but in a compact grid layout
  //   matching the redesign.
  // - Reuses `openListingDetails(...)` so existing routing, chat start,
  //   report and block logic stay unchanged under the new UI.
  Widget _gridCard(BuildContext context, Listing listing) {
    final gradient = _catGradient(listing.categoryId);
    return Container(
      decoration: BoxDecoration(
        color: _navyCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _navyBorder),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
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
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradient,
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Icon(_catIcon(listing.categoryId), color: _textPrimary.withOpacity(0.9), size: 36),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: IconButton(
                      icon: Icon(
                        widget.favoriteIds.contains(listing.id) ? Icons.favorite : Icons.favorite_border,
                        color: widget.favoriteIds.contains(listing.id) ? Colors.red : _textSecondary,
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
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        listing.priceLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _green,
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
                          color: _textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        listing.location,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: _textMuted,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _navyCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _navyBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailChip(String key, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _navyCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _navyBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$key: ",
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: _textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: _textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as ListingDetailsArgs?;
    final data = args?.listing ?? sampleListings.first;
    final isFavorite = _isFavorite ?? args?.isFavorite ?? false;
    final gradientColors = _catGradient(data.categoryId);

    return Scaffold(
      backgroundColor: _navy,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: _navy,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded, color: _textPrimary),
                onPressed: () {},
              ),
              IconButton(
                onPressed: () {
                  args?.onToggleFavorite();
                  setState(() => _isFavorite = !isFavorite);
                },
                icon: Icon(
                  isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFavorite ? Colors.redAccent : _textPrimary,
                  size: 24,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                ),
                child: Center(
                  child: Icon(
                    _catIcon(data.categoryId),
                    size: 72,
                    color: _textPrimary.withValues(alpha: 0.9),
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
                  // Title + price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          data.title,
                          style: GoogleFonts.dmSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        data.priceLabel,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Location row
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 18, color: _textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        data.location,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: _textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Seller card
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
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _navyLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _navyBorder),
                          ),
                          child: Center(
                            child: Text(
                              data.sellerName.isNotEmpty ? data.sellerName[0].toUpperCase() : "?",
                              style: GoogleFonts.dmSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: _green,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.sellerName,
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _textPrimary,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  foregroundColor: _green,
                                ),
                                child: Text(
                                  "View profile",
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Trust badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _badge("Verified seller", Icons.verified_rounded, _green),
                      _badge("Secure chat", Icons.lock_outline_rounded, _green),
                      _badge("Fast responder", Icons.access_time_rounded, _green),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // About this listing
                  Text(
                    "About this listing",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.description,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      height: 1.5,
                      color: _textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Details chips
                  Text(
                    "Details",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _detailChip("Condition", data.condition),
                      ...data.categoryFields.entries.map(
                        (entry) => _detailChip(entry.key, entry.value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Safety notice card
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
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.shield_rounded, color: _gold, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            "Use secure chat and meet in public for safe transactions.",
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: _textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Report / Block
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: args?.onReport,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _textSecondary,
                          side: const BorderSide(color: _navyBorder),
                        ),
                        child: const Text("Report"),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: args?.onBlock,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _textSecondary,
                          side: const BorderSide(color: _navyBorder),
                        ),
                        child: const Text("Block"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Chat button
                  _gradientButton(
                    "Chat with seller",
                    Icons.chat_bubble_outline_rounded,
                    args?.onStartChat ?? () {},
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
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
        // Dark gradient header: Cancel | New Advert | Clear
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 14),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F1A2E), _navyCard],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.maybePop(context),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.dmSans(
                    color: _textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
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
                    color: _textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Step progress bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: _navyCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Step 1 of 3 — Basic info",
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: _textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 1 / 3,
                  backgroundColor: _navyLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(_green),
                  minHeight: 4,
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
                  suffixIcon: Icon(Icons.arrow_drop_down, color: _textSecondary),
                ),
                dropdownColor: _navyCard,
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
              Material(
                color: _navyLight,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: _addPlaceholderImage,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Icon(Icons.camera_alt_rounded, color: _textMuted, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          "Add photos",
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: _textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String?>(
                      value: _locationController.text.isEmpty ? null : _locationController.text,
                      decoration: const InputDecoration(
                        hintText: "Region",
                        suffixIcon: Icon(Icons.arrow_drop_down, color: _textSecondary),
                      ),
                      dropdownColor: _navyCard,
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
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        hintText: "Price",
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
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
              _buildCategoryFields(),
              const SizedBox(height: 24),
              _gradientButton(
                _submitting ? "Submitting…" : "Continue",
                Icons.arrow_forward_rounded,
                _submitting ? () {} : _submitListing,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.dmSans(fontSize: 12, color: _textMuted),
                    children: [
                      const TextSpan(
                        text: "By clicking Continue, you accept the ",
                      ),
                      TextSpan(
                        text: "Terms of Use",
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: _green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(
                        text: ", confirm that you will abide by the ",
                      ),
                      TextSpan(
                        text: "Safety Tips",
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: _green,
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
          // Top gradient header: 0xFF0F1A2E -> _navyCard
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0F1A2E), _navyCard],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Messages",
                  style: GoogleFonts.dmSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search in Messages",
                    hintStyle: GoogleFonts.dmSans(color: _textMuted, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: _textMuted, size: 22),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          // Tab row in _navyCard
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: _textMuted),
                        const SizedBox(height: 16),
                        Text(
                          "No conversations yet.",
                          style: GoogleFonts.dmSans(color: _textMuted, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: conversations.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: _navyBorder),
                  itemBuilder: (context, index) {
                    final conv = conversations[index];
                    final peerId = conv.buyerId == widget.userId
                        ? conv.sellerId
                        : conv.buyerId;
                    final initials = peerId.isNotEmpty
                        ? peerId
                            .split(" ")
                            .where((p) => p.isNotEmpty)
                            .map((p) => p[0])
                            .take(2)
                            .join()
                            .toUpperCase()
                        : "?";
                    return GestureDetector(
                      onTap: () => widget.onOpenConversation(conv),
                      child: Container(
                        color: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [_green, _greenLight],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  initials,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "User $peerId",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.dmSans(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: _textPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _ChatScreenState._timeDisplay(
                                          conv.createdAt,
                                        ),
                                        style: GoogleFonts.dmSans(
                                          fontSize: 11,
                                          color: _textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    "Listing ${conv.listingId}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: _textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Unread pill placeholder – stylistic only (no backend count)
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _green.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                "Chat",
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _green,
                                ),
                              ),
                            ),
                          ],
                        ),
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
                width: 3,
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
    final isActive = _tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? _green : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
            color: isActive ? _green : _textMuted,
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
          // Dark header: Saved
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 20),
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
                Text(
                  "Saved",
                  style: GoogleFonts.dmSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _favTab("Ads", 0)),
                    Expanded(child: _favTab("Searches", 1)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: _navy,
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
    final cat = listing.categoryId;
    return Container(
      color: _navyCard,
      margin: const EdgeInsets.only(bottom: 1),
      child: Material(
        color: _navyCard,
        child: InkWell(
          onTap: () => openListingDetails(
            context: context,
            listing: listing,
            isFavorite: true,
            onToggleFavorite: () => widget.onToggleFavorite(listing.id),
            onReport: () => widget.onReportListing(listing),
            onBlock: () => widget.onBlockUser(listing.sellerId),
            onStartChat: () => widget.onStartChat(listing),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _catGradient(cat),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_catIcon(cat), color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: _textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        listing.priceLabel,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _green,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: _textMuted, size: 22),
              ],
            ),
          ),
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

  static String _timeDisplay(String raw) {
    final d = DateTime.tryParse(raw);
    if (d != null) {
      return "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final args = _args;
    if (args == null) {
      return const Scaffold(body: Center(child: Text("No conversation.")));
    }
    return Scaffold(
      backgroundColor: _navy,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            color: _navyCard,
            border: Border(
              bottom: BorderSide(color: _navyBorder),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_green, _greenLight],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        args.peerId.isNotEmpty
                            ? args.peerId[0].toUpperCase()
                            : "?",
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Chat",
                          style: GoogleFonts.dmSans(
                            color: _textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Listing ${args.listingId}",
                          style: GoogleFonts.dmSans(
                            color: _textSecondary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _headerActionButton(Icons.call_outlined),
                      const SizedBox(width: 6),
                      _headerActionButton(Icons.more_vert_rounded),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 48,
                          color: _textMuted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No messages yet",
                          style: GoogleFonts.dmSans(
                            color: _textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Start the conversation below",
                          style: GoogleFonts.dmSans(
                            color: _textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMine = message.senderId == args.currentUserId;
                    return Align(
                      alignment: isMine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: _DarkBubble(
                        text: message.text,
                        isMine: isMine,
                        time: _timeDisplay(message.createdAt),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
            decoration: const BoxDecoration(
              color: _navyCard,
              border: Border(
                top: BorderSide(color: _navyBorder),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _navyLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _navyBorder),
                  ),
                  child: const Icon(
                    Icons.attach_file_rounded,
                    color: _textSecondary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _navyLight,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _navyBorder),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            style: GoogleFonts.dmSans(
                              color: _textPrimary,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: "Type a message…",
                              hintStyle: GoogleFonts.dmSans(
                                color: _textMuted,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              filled: false,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ],
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
                      gradient: const LinearGradient(
                        colors: [_green, _greenLight],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _green.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerActionButton(IconData icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: _navyLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _navyBorder),
      ),
      child: Icon(
        icon,
        color: _textSecondary,
        size: 16,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMine ? _green : _navyCard,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMine ? 16 : 4),
          bottomRight: Radius.circular(isMine ? 4 : 16),
        ),
        border: isMine
            ? null
            : Border.all(color: _navyBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              height: 1.4,
              color: isMine ? Colors.white : _textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              color: isMine
                  ? Colors.white.withOpacity(0.6)
                  : _textMuted,
            ),
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

  Widget _profileCard({
    required IconData icon,
    required String label,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _navyLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _navyBorder),
          ),
          child: Row(
            children: [
              if (badge != null)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(icon, color: _textSecondary, size: 24),
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
                Icon(icon, color: _textSecondary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: _textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: _textMuted, size: 22),
            ],
          ),
        ),
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
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    this.action,
    this.onAction,
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
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: GoogleFonts.dmSans(
                color: _green,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
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
        backgroundColor: _navyCard,
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
