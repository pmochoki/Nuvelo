import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hu')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Nuvelo'**
  String get appTitle;

  /// No description provided for @taglineNiceVibesOnly.
  ///
  /// In en, this message translates to:
  /// **'Nice Vibes Only'**
  String get taglineNiceVibesOnly;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get continueWithFacebook;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerTitle;

  /// No description provided for @verifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get verifyTitle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get dontHaveAccount;

  /// No description provided for @termsFooter.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to Nuvelo\'s Terms and Privacy Policy.'**
  String get termsFooter;

  /// No description provided for @categoryTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get categoryTrending;

  /// No description provided for @categoryEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get categoryEvents;

  /// No description provided for @categoryDonations.
  ///
  /// In en, this message translates to:
  /// **'Donations'**
  String get categoryDonations;

  /// No description provided for @categoryRentals.
  ///
  /// In en, this message translates to:
  /// **'Rentals'**
  String get categoryRentals;

  /// No description provided for @categoryJobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get categoryJobs;

  /// No description provided for @categoryServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get categoryServices;

  /// No description provided for @categoryGoods.
  ///
  /// In en, this message translates to:
  /// **'Goods & Items'**
  String get categoryGoods;

  /// No description provided for @categoryVehicles.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get categoryVehicles;

  /// No description provided for @categoryElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get categoryElectronics;

  /// No description provided for @categoryFurniture.
  ///
  /// In en, this message translates to:
  /// **'Furniture & Home'**
  String get categoryFurniture;

  /// No description provided for @categoryFashion.
  ///
  /// In en, this message translates to:
  /// **'Fashion'**
  String get categoryFashion;

  /// No description provided for @categoryBabiesKids.
  ///
  /// In en, this message translates to:
  /// **'Babies & Kids'**
  String get categoryBabiesKids;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'What are you looking for?'**
  String get searchPlaceholder;

  /// No description provided for @locationAllHungary.
  ///
  /// In en, this message translates to:
  /// **'All Hungary'**
  String get locationAllHungary;

  /// No description provided for @trendingAds.
  ///
  /// In en, this message translates to:
  /// **'Trending ads'**
  String get trendingAds;

  /// No description provided for @recentAds.
  ///
  /// In en, this message translates to:
  /// **'Recent ads'**
  String get recentAds;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @noListingsYet.
  ///
  /// In en, this message translates to:
  /// **'No listings yet — be the first to post!'**
  String get noListingsYet;

  /// No description provided for @postAd.
  ///
  /// In en, this message translates to:
  /// **'Post ad'**
  String get postAd;

  /// No description provided for @browseTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browseTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @messagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @sellTitle.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sellTitle;

  /// No description provided for @priceOnRequest.
  ///
  /// In en, this message translates to:
  /// **'Price on request'**
  String get priceOnRequest;

  /// No description provided for @listingDetail.
  ///
  /// In en, this message translates to:
  /// **'Listing'**
  String get listingDetail;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @languageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @languageHu.
  ///
  /// In en, this message translates to:
  /// **'Hungarian'**
  String get languageHu;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Buy & Sell in Hungary'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Body.
  ///
  /// In en, this message translates to:
  /// **'Find rentals, jobs, services and goods from Hungary\'s expat community.'**
  String get onboarding1Body;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Post a Free Ad'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Body.
  ///
  /// In en, this message translates to:
  /// **'List anything in 60 seconds. Your ad goes live after a quick review.'**
  String get onboarding2Body;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Safe & Local'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Body.
  ///
  /// In en, this message translates to:
  /// **'Meet sellers near you. Verified badges mean real people.'**
  String get onboarding3Body;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @emptyMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet.'**
  String get emptyMessages;

  /// No description provided for @emptySaved.
  ///
  /// In en, this message translates to:
  /// **'No saved ads yet.'**
  String get emptySaved;

  /// No description provided for @couldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load listings. Pull to refresh.'**
  String get couldNotLoad;

  /// No description provided for @safetyMeetPublic.
  ///
  /// In en, this message translates to:
  /// **'Meet in public. Never pay in advance.'**
  String get safetyMeetPublic;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get sendMessage;

  /// No description provided for @thisIsYourListing.
  ///
  /// In en, this message translates to:
  /// **'This is your own listing — manage it under My ads.'**
  String get thisIsYourListing;

  /// No description provided for @shareListing.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareListing;

  /// No description provided for @verifySmsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter the code we sent'**
  String get verifySmsPrompt;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @welcomeRegister.
  ///
  /// In en, this message translates to:
  /// **'Tell us about you'**
  String get welcomeRegister;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// No description provided for @createAccountBtn.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccountBtn;

  /// No description provided for @roleBuyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get roleBuyer;

  /// No description provided for @roleTenant.
  ///
  /// In en, this message translates to:
  /// **'Tenant'**
  String get roleTenant;

  /// No description provided for @roleSeller.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get roleSeller;

  /// No description provided for @roleAgent.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get roleAgent;

  /// No description provided for @roleLandlord.
  ///
  /// In en, this message translates to:
  /// **'Landlord'**
  String get roleLandlord;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hu':
      return AppLocalizationsHu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
