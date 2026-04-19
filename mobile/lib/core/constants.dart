/// Category slugs align with web `web/src/data/categories.js` and API `categoryId`.
class NuveloCategory {
  const NuveloCategory({
    required this.id,
    required this.labelKey,
    required this.emoji,
  });

  final String id;
  final String labelKey; // l10n key suffix — resolved in UI
  final String emoji;
}

/// Trending is a UX filter (popular sort), not always a DB slug.
const String kTrendingCategoryId = 'trending';

const List<NuveloCategory> kBrowseCategories = [
  NuveloCategory(id: kTrendingCategoryId, labelKey: 'categoryTrending', emoji: '🔥'),
  NuveloCategory(id: 'events', labelKey: 'categoryEvents', emoji: '🎉'),
  NuveloCategory(id: 'donations', labelKey: 'categoryDonations', emoji: '🤲'),
  NuveloCategory(id: 'rentals', labelKey: 'categoryRentals', emoji: '🏠'),
  NuveloCategory(id: 'jobs', labelKey: 'categoryJobs', emoji: '💼'),
  NuveloCategory(id: 'services', labelKey: 'categoryServices', emoji: '🔧'),
  NuveloCategory(id: 'goods', labelKey: 'categoryGoods', emoji: '👕'),
  NuveloCategory(id: 'vehicles', labelKey: 'categoryVehicles', emoji: '🚗'),
  NuveloCategory(id: 'electronics', labelKey: 'categoryElectronics', emoji: '💻'),
  NuveloCategory(id: 'furniture', labelKey: 'categoryFurniture', emoji: '🛋️'),
  NuveloCategory(id: 'fashion', labelKey: 'categoryFashion', emoji: '👗'),
  NuveloCategory(id: 'babies-kids', labelKey: 'categoryBabiesKids', emoji: '🧸'),
  NuveloCategory(id: 'other', labelKey: 'categoryOther', emoji: '🗂️'),
];

/// Post-ad grid (website order without Trending).
const List<NuveloCategory> kPostCategories = [
  NuveloCategory(id: 'events', labelKey: 'categoryEvents', emoji: '🎉'),
  NuveloCategory(id: 'donations', labelKey: 'categoryDonations', emoji: '🤲'),
  NuveloCategory(id: 'rentals', labelKey: 'categoryRentals', emoji: '🏠'),
  NuveloCategory(id: 'jobs', labelKey: 'categoryJobs', emoji: '💼'),
  NuveloCategory(id: 'services', labelKey: 'categoryServices', emoji: '🔧'),
  NuveloCategory(id: 'goods', labelKey: 'categoryGoods', emoji: '👕'),
  NuveloCategory(id: 'vehicles', labelKey: 'categoryVehicles', emoji: '🚗'),
  NuveloCategory(id: 'electronics', labelKey: 'categoryElectronics', emoji: '💻'),
  NuveloCategory(id: 'furniture', labelKey: 'categoryFurniture', emoji: '🛋️'),
  NuveloCategory(id: 'fashion', labelKey: 'categoryFashion', emoji: '👗'),
  NuveloCategory(id: 'babies-kids', labelKey: 'categoryBabiesKids', emoji: '🧸'),
  NuveloCategory(id: 'other', labelKey: 'categoryOther', emoji: '🗂️'),
];

const List<String> kHungarianCities = [
  'Budapest',
  'Debrecen',
  'Szeged',
  'Miskolc',
  'Pécs',
  'Győr',
  'Nyíregyháza',
  'Kecskemét',
  'Székesfehérvár',
  'Szombathely',
  'Szolnok',
  'Tatabánya',
  'Kaposvár',
  'Veszprém',
  'Érd',
  'Zalaegerszeg',
  'Sopron',
  'Eger',
  'Nagykanizsa',
  'All Hungary',
];

const List<String> kUserRoles = [
  'buyer',
  'tenant',
  'seller',
  'agent',
  'landlord',
];

const String kPrefsLang = 'nuvelo_lang';
const String kPrefsThemeMode = 'nuvelo_theme';
/// Matches product spec key `onboarding_done` (first-launch flag).
const String kPrefsOnboardingDone = 'onboarding_done';

/// Default listings API — same source as nuvelo.one web (`/api/listings`).
const String kDefaultListingsApiBase = 'https://nuvelo.one/api';
