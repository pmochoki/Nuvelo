import "package:flutter/material.dart";

void main() {
  runApp(const InterHungaryApp());
}

class InterHungaryApp extends StatelessWidget {
  const InterHungaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "InterHungary",
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      routes: {
        "/": (_) => const AppRoot(),
        "/listing": (_) => const ListingDetailsScreen(),
        "/chat": (_) => const ChatScreen(),
        "/my-listings": (_) => const MyListingsScreen()
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

class Category {
  final String id;
  final String name;

  const Category({required this.id, required this.name});
}

class Listing {
  final String id;
  final String title;
  final String description;
  final String categoryId;
  final String location;
  final int? price;
  final String currency;
  final String priceLabel;
  final String condition;
  final String sellerId;
  final String sellerName;
  final Map<String, String> categoryFields;

  const Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.location,
    required this.price,
    required this.currency,
    required this.priceLabel,
    required this.condition,
    required this.sellerId,
    required this.sellerName,
    required this.categoryFields
  });
}

class SavedSearch {
  final String query;
  final String? categoryId;
  final String? location;

  const SavedSearch({required this.query, this.categoryId, this.location});
}

class ListingDetailsArgs {
  final Listing listing;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onReport;
  final VoidCallback onBlock;

  const ListingDetailsArgs({
    required this.listing,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onReport,
    required this.onBlock
  });
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  UserRole? _role;

  void _setRole(UserRole role) {
    setState(() => _role = role);
  }

  void _signOut() {
    setState(() => _role = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_role == null) {
      return SignInScreen(onSelectRole: _setRole);
    }
    return MainShell(role: _role!, onSignOut: _signOut);
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
    }
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
    }
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
  )
];

void openListingDetails({
  required BuildContext context,
  required Listing listing,
  required bool isFavorite,
  required VoidCallback onToggleFavorite,
  required VoidCallback onReport,
  required VoidCallback onBlock
}) {
  Navigator.pushNamed(
    context,
    "/listing",
    arguments: ListingDetailsArgs(
      listing: listing,
      isFavorite: isFavorite,
      onToggleFavorite: onToggleFavorite,
      onReport: onReport,
      onBlock: onBlock
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
  final VoidCallback onSignOut;

  const MainShell({super.key, required this.role, required this.onSignOut});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final Set<String> _favoriteIds = {};
  final List<SavedSearch> _savedSearches = [];
  final Set<String> _blockedUsers = {};

  void _toggleFavorite(String listingId) {
    setState(() {
      if (_favoriteIds.contains(listingId)) {
        _favoriteIds.remove(listingId);
      } else {
        _favoriteIds.add(listingId);
      }
    });
  }

  void _saveSearch(SavedSearch search) {
    setState(() => _savedSearches.add(search));
  }

  void _blockUser(String userId) {
    setState(() => _blockedUsers.add(userId));
  }

  List<Widget> get _pages {
    final role = widget.role;
    final pages = <Widget>[
      RoleHomeScreen(
        role: role,
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
        onSaveSearch: _saveSearch,
        onBlockUser: _blockUser,
      ),
      InboxScreen(role: role),
      ProfileScreen(
        role: role,
        onSignOut: widget.onSignOut,
        favoriteIds: _favoriteIds,
        savedSearches: _savedSearches,
      )
    ];
    if (role != UserRole.customer) {
      pages.insert(1, PostListingScreen(role: role));
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

class SignInScreen extends StatelessWidget {
  final void Function(UserRole role) onSelectRole;

  const SignInScreen({super.key, required this.onSelectRole});

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
            ...roles.map(
              (role) => Card(
                child: ListTile(
                  title: Text(roleLabel(role)),
                  subtitle: Text(_roleDescription(role)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => onSelectRole(role),
                ),
              ),
            )
          ],
        ),
      ),
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
  final Set<String> favoriteIds;
  final void Function(String listingId) onToggleFavorite;
  final void Function(SavedSearch search) onSaveSearch;
  final void Function(String userId) onBlockUser;

  const RoleHomeScreen({
    super.key,
    required this.role,
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.onSaveSearch,
    required this.onBlockUser
  });

  @override
  Widget build(BuildContext context) {
    if (role == UserRole.agent) {
      return RoleDashboardScreen(
        title: "Agent dashboard",
        subtitle: "Rental leads waiting for you.",
        listings: sampleListings
            .where((listing) => listing.categoryId == "rentals")
            .toList()
      );
    }
    if (role == UserRole.landlord) {
      return RoleDashboardScreen(
        title: "Landlord dashboard",
        subtitle: "Manage your properties.",
        listings: sampleListings
            .where((listing) => listing.categoryId == "rentals")
            .toList()
      );
    }
    if (role == UserRole.seller) {
      return RoleDashboardScreen(
        title: "Seller dashboard",
        subtitle: "Track sales and new requests.",
        listings: sampleListings
      );
    }
    return CustomerBrowseScreen(
      listings: sampleListings,
      categories: categories,
      favoriteIds: favoriteIds,
      onToggleFavorite: onToggleFavorite,
      onSaveSearch: onSaveSearch,
      onBlockUser: onBlockUser
    );
  }
}

class CustomerBrowseScreen extends StatefulWidget {
  final List<Listing> listings;
  final List<Category> categories;
  final Set<String> favoriteIds;
  final void Function(String listingId) onToggleFavorite;
  final void Function(SavedSearch search) onSaveSearch;
  final void Function(String userId) onBlockUser;

  const CustomerBrowseScreen({
    super.key,
    required this.listings,
    required this.categories,
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.onSaveSearch,
    required this.onBlockUser
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

  void _saveSearch() {
    final search = SavedSearch(
      query: _query,
      categoryId: _categoryId,
      location: _location.isEmpty ? null : _location
    );
    widget.onSaveSearch(search);
    showNotice(context, "Saved search added.");
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Explore", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              labelText: "Search",
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            value: _categoryId,
            decoration: const InputDecoration(labelText: "Category"),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text("All categories"),
              ),
              ...widget.categories.map(
                (category) => DropdownMenuItem<String?>(
                  value: category.id,
                  child: Text(category.name),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _categoryId = value),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(labelText: "Location"),
            onChanged: (value) => setState(() => _location = value),
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
          const SizedBox(height: 16),
          Text("Listings", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (filtered.isEmpty)
            const Text("No listings match your filters."),
          ...filtered.map(
            (listing) => Card(
              child: ListTile(
                title: Text(listing.title),
                subtitle: Text("${listing.location} • ${listing.priceLabel}"),
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
                  onReport: () => showNotice(
                    context,
                    "Report submitted for ${listing.title}.",
                  ),
                  onBlock: () {
                    widget.onBlockUser(listing.sellerId);
                    showNotice(context, "Blocked ${listing.sellerName}.");
                  },
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

  const RoleDashboardScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.listings
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
                  onReport: () =>
                      showNotice(context, "Report submitted for listing."),
                  onBlock: () => showNotice(context, "Seller blocked."),
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
                onPressed: () => Navigator.pushNamed(context, "/chat"),
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

  const PostListingScreen({super.key, required this.role});

  @override
  State<PostListingScreen> createState() => _PostListingScreenState();
}

class _PostListingScreenState extends State<PostListingScreen> {
  String _categoryId = "rentals";
  String _condition = "good";

  Widget _buildCategoryFields() {
    switch (_categoryId) {
      case "vehicles":
        return Column(
          children: const [
            TextField(decoration: InputDecoration(labelText: "Make")),
            TextField(decoration: InputDecoration(labelText: "Model")),
            TextField(decoration: InputDecoration(labelText: "Year")),
            TextField(decoration: InputDecoration(labelText: "Mileage")),
            TextField(decoration: InputDecoration(labelText: "Transmission")),
            TextField(decoration: InputDecoration(labelText: "Fuel")),
          ],
        );
      case "real-estate":
      case "rentals":
        return Column(
          children: const [
            TextField(decoration: InputDecoration(labelText: "Property type")),
            TextField(decoration: InputDecoration(labelText: "Bedrooms")),
            TextField(decoration: InputDecoration(labelText: "Bathrooms")),
            TextField(decoration: InputDecoration(labelText: "Area (sqm)")),
            TextField(decoration: InputDecoration(labelText: "Furnished")),
            TextField(decoration: InputDecoration(labelText: "Lease type")),
          ],
        );
      case "electronics":
        return Column(
          children: const [
            TextField(decoration: InputDecoration(labelText: "Brand")),
            TextField(decoration: InputDecoration(labelText: "Model")),
            TextField(decoration: InputDecoration(labelText: "Storage")),
            TextField(decoration: InputDecoration(labelText: "Warranty")),
          ],
        );
      case "jobs":
        return Column(
          children: const [
            TextField(decoration: InputDecoration(labelText: "Role")),
            TextField(decoration: InputDecoration(labelText: "Contract type")),
            TextField(decoration: InputDecoration(labelText: "Salary range")),
            TextField(decoration: InputDecoration(labelText: "Experience")),
          ],
        );
      case "services":
        return Column(
          children: const [
            TextField(decoration: InputDecoration(labelText: "Service type")),
            TextField(decoration: InputDecoration(labelText: "Availability")),
            TextField(decoration: InputDecoration(labelText: "Service area")),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
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
          const TextField(decoration: InputDecoration(labelText: "Title")),
          const TextField(
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
          const TextField(decoration: InputDecoration(labelText: "Price")),
          const TextField(decoration: InputDecoration(labelText: "Location")),
          const SizedBox(height: 12),
          _buildCategoryFields(),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => showNotice(
              context,
              "Listing submitted for moderation.",
            ),
            child: const Text("Submit for review")
          )
        ],
      ),
    );
  }
}

class InboxScreen extends StatelessWidget {
  final UserRole role;

  const InboxScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Chats", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: const Text("Anna Nagy"),
              subtitle: const Text("Is the apartment still available?"),
              onTap: () => Navigator.pushNamed(context, "/chat"),
            ),
          )
        ],
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Conversation")),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                Align(
                  alignment: Alignment.centerLeft,
                  child: ChatBubble(text: "Hello! Is it still available?")
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: ChatBubble(text: "Yes, it is.")
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(hintText: "Type a message")
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(onPressed: () {}, icon: const Icon(Icons.send))
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
  final VoidCallback onSignOut;
  final Set<String> favoriteIds;
  final List<SavedSearch> savedSearches;

  const ProfileScreen({
    super.key,
    required this.role,
    required this.onSignOut,
    required this.favoriteIds,
    required this.savedSearches
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Profile", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text("David Smith"),
            subtitle: Text("david@example.com")
          ),
          const SizedBox(height: 8),
          Chip(label: Text(roleLabel(role))),
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
            onPressed: () => Navigator.pushNamed(context, "/my-listings"),
            child: const Text("My Listings")
          ),
          TextButton(onPressed: onSignOut, child: const Text("Switch role"))
        ],
      ),
    );
  }
}

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statusById = {
      "l1": "Approved",
      "l2": "Approved",
      "l3": "Pending",
      "l4": "Approved",
      "l5": "Approved"
    };
    return Scaffold(
      appBar: AppBar(title: const Text("My Listings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: sampleListings
            .map(
              (listing) => Card(
                child: ListTile(
                  title: Text(listing.title),
                  subtitle: Text(
                    "${listing.priceLabel} • ${statusById[listing.id] ?? 'Pending'}",
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
