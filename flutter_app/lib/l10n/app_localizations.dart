import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('pl')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Food Scanner'**
  String get appTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languagePolish.
  ///
  /// In en, this message translates to:
  /// **'Polski'**
  String get languagePolish;

  /// No description provided for @screenSplashLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get screenSplashLoading;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get loginWelcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue your journey.'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @registerCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerCreateAccount;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your journey with us today.'**
  String get registerSubtitle;

  /// No description provided for @validationEnterEmailAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter both email and password'**
  String get validationEnterEmailAndPassword;

  /// No description provided for @validationEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email address'**
  String get validationEnterEmail;

  /// No description provided for @validationValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get validationValidEmail;

  /// No description provided for @validationPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long'**
  String get validationPasswordMinLength;

  /// No description provided for @validationPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordsDoNotMatch;

  /// No description provided for @registerAccountExists.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists'**
  String get registerAccountExists;

  /// No description provided for @registerSuccessVerifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Check your email to verify your account.'**
  String get registerSuccessVerifyEmail;

  /// No description provided for @registerNoUserCreated.
  ///
  /// In en, this message translates to:
  /// **'Registration failed: No user created'**
  String get registerNoUserCreated;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed: {message}'**
  String registerFailed(Object message);

  /// No description provided for @genericErrorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {message}'**
  String genericErrorWithMessage(Object message);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubscriptionSection.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get settingsSubscriptionSection;

  /// No description provided for @settingsManageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get settingsManageSubscription;

  /// No description provided for @settingsUpgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get settingsUpgradeToPremium;

  /// No description provided for @settingsDataManagementSection.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get settingsDataManagementSection;

  /// No description provided for @settingsExportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get settingsExportData;

  /// No description provided for @settingsExportDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Download your weight history and meal data'**
  String get settingsExportDataSubtitle;

  /// No description provided for @settingsAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountSection;

  /// No description provided for @settingsProfileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get settingsProfileSettings;

  /// No description provided for @settingsProfileSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your profile information'**
  String get settingsProfileSettingsSubtitle;

  /// No description provided for @settingsPrivacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get settingsPrivacySecurity;

  /// No description provided for @settingsPrivacySecuritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your privacy settings'**
  String get settingsPrivacySecuritySubtitle;

  /// No description provided for @settingsSupportSection.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSupportSection;

  /// No description provided for @settingsHelpFaq.
  ///
  /// In en, this message translates to:
  /// **'Help & FAQ'**
  String get settingsHelpFaq;

  /// No description provided for @settingsHelpFaqSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get help and find answers'**
  String get settingsHelpFaqSubtitle;

  /// No description provided for @settingsSendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get settingsSendFeedback;

  /// No description provided for @settingsSendFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help us improve the app'**
  String get settingsSendFeedbackSubtitle;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose app language'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsSubscriptionPortalUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not open subscription portal'**
  String get settingsSubscriptionPortalUnavailable;

  /// No description provided for @settingsSubscriptionPortalFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to access subscription portal'**
  String get settingsSubscriptionPortalFailed;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon!'**
  String get comingSoon;

  /// No description provided for @subscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get subscriptionTitle;

  /// No description provided for @subscriptionHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium Features'**
  String get subscriptionHeaderTitle;

  /// No description provided for @subscriptionHeaderTrialSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your 7-day free trial'**
  String get subscriptionHeaderTrialSubtitle;

  /// No description provided for @subscriptionHeaderChoosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose your plan'**
  String get subscriptionHeaderChoosePlan;

  /// No description provided for @subscriptionFeatureUnlimitedScanning.
  ///
  /// In en, this message translates to:
  /// **'Unlimited food scanning'**
  String get subscriptionFeatureUnlimitedScanning;

  /// No description provided for @subscriptionFeatureAiAnalysis.
  ///
  /// In en, this message translates to:
  /// **'AI-powered nutrition analysis'**
  String get subscriptionFeatureAiAnalysis;

  /// No description provided for @subscriptionFeatureMealTracking.
  ///
  /// In en, this message translates to:
  /// **'Advanced meal tracking'**
  String get subscriptionFeatureMealTracking;

  /// No description provided for @subscriptionFeatureRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Personalized recommendations'**
  String get subscriptionFeatureRecommendations;

  /// No description provided for @subscriptionFeatureExportData.
  ///
  /// In en, this message translates to:
  /// **'Export your data'**
  String get subscriptionFeatureExportData;

  /// No description provided for @subscriptionFeaturePrioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get subscriptionFeaturePrioritySupport;

  /// No description provided for @subscriptionBestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get subscriptionBestValue;

  /// No description provided for @subscriptionJustPricePerMonth.
  ///
  /// In en, this message translates to:
  /// **'Just {price}'**
  String subscriptionJustPricePerMonth(Object price);

  /// No description provided for @subscriptionCheckoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to start checkout'**
  String get subscriptionCheckoutFailed;

  /// No description provided for @subscriptionOpeningCheckout.
  ///
  /// In en, this message translates to:
  /// **'Opening Stripe Checkout... Return to the app after completing purchase.'**
  String get subscriptionOpeningCheckout;

  /// No description provided for @subscriptionCouldNotOpenCheckout.
  ///
  /// In en, this message translates to:
  /// **'Could not open checkout'**
  String get subscriptionCouldNotOpenCheckout;

  /// No description provided for @subscriptionStartFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'Start Free Trial'**
  String get subscriptionStartFreeTrial;

  /// No description provided for @subscriptionSubscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscriptionSubscribeNow;

  /// No description provided for @subscriptionTrialTerms.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime. You won\'t be charged until the trial ends.'**
  String get subscriptionTrialTerms;

  /// No description provided for @subscriptionPaidTerms.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime. Billed monthly or annually.'**
  String get subscriptionPaidTerms;

  /// No description provided for @subscriptionCurrentStatus.
  ///
  /// In en, this message translates to:
  /// **'Current Status: {status}'**
  String subscriptionCurrentStatus(Object status);

  /// No description provided for @subscriptionTierLabel.
  ///
  /// In en, this message translates to:
  /// **'Tier: {tier}'**
  String subscriptionTierLabel(Object tier);

  /// No description provided for @subscriptionTrialEnds.
  ///
  /// In en, this message translates to:
  /// **'Trial ends: {date}'**
  String subscriptionTrialEnds(Object date);

  /// No description provided for @subscriptionFreeTrialBadge.
  ///
  /// In en, this message translates to:
  /// **'7-day free trial'**
  String get subscriptionFreeTrialBadge;

  /// No description provided for @subscriptionStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get subscriptionStatusActive;

  /// No description provided for @subscriptionStatusTrial.
  ///
  /// In en, this message translates to:
  /// **'Trial'**
  String get subscriptionStatusTrial;

  /// No description provided for @subscriptionStatusFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get subscriptionStatusFree;

  /// No description provided for @subscriptionStatusPastDue.
  ///
  /// In en, this message translates to:
  /// **'Past Due'**
  String get subscriptionStatusPastDue;

  /// No description provided for @subscriptionStatusCanceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get subscriptionStatusCanceled;

  /// No description provided for @subscriptionTierMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get subscriptionTierMonthly;

  /// No description provided for @subscriptionTierYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get subscriptionTierYearly;

  /// No description provided for @subscriptionCancelsInDays.
  ///
  /// In en, this message translates to:
  /// **'Cancels in {days} days - {tier}'**
  String subscriptionCancelsInDays(int days, Object tier);

  /// No description provided for @subscriptionCancelsTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Cancels tomorrow - {tier}'**
  String subscriptionCancelsTomorrow(Object tier);

  /// No description provided for @subscriptionCancelsToday.
  ///
  /// In en, this message translates to:
  /// **'Cancels today - {tier}'**
  String subscriptionCancelsToday(Object tier);

  /// No description provided for @subscriptionCancelsOnDate.
  ///
  /// In en, this message translates to:
  /// **'Cancels on {date}'**
  String subscriptionCancelsOnDate(Object date);

  /// No description provided for @subscriptionTrialDaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'Trial - {days} days remaining'**
  String subscriptionTrialDaysRemaining(int days);

  /// No description provided for @subscriptionTrialOneDayRemaining.
  ///
  /// In en, this message translates to:
  /// **'Trial - 1 day remaining'**
  String get subscriptionTrialOneDayRemaining;

  /// No description provided for @subscriptionTrialHoursRemaining.
  ///
  /// In en, this message translates to:
  /// **'Trial - {hours} hours remaining'**
  String subscriptionTrialHoursRemaining(int hours);

  /// No description provided for @subscriptionTrialTier.
  ///
  /// In en, this message translates to:
  /// **'Trial - {tier}'**
  String subscriptionTrialTier(Object tier);

  /// No description provided for @subscriptionStatusWithTier.
  ///
  /// In en, this message translates to:
  /// **'{status} - {tier}'**
  String subscriptionStatusWithTier(Object status, Object tier);

  /// No description provided for @subscriptionUnlockUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlock unlimited features'**
  String get subscriptionUnlockUnlimited;

  /// No description provided for @subscriptionStartTrial.
  ///
  /// In en, this message translates to:
  /// **'Start 7-day free trial'**
  String get subscriptionStartTrial;

  /// No description provided for @exportDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportDataTitle;

  /// No description provided for @exportDataExportingTitle.
  ///
  /// In en, this message translates to:
  /// **'Exporting your data...'**
  String get exportDataExportingTitle;

  /// No description provided for @exportDataExportingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This may take a few moments'**
  String get exportDataExportingSubtitle;

  /// No description provided for @exportSectionDataToExport.
  ///
  /// In en, this message translates to:
  /// **'Data to Export'**
  String get exportSectionDataToExport;

  /// No description provided for @exportSectionDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get exportSectionDateRange;

  /// No description provided for @exportSectionFormat.
  ///
  /// In en, this message translates to:
  /// **'Export Format'**
  String get exportSectionFormat;

  /// No description provided for @exportWeightHistory.
  ///
  /// In en, this message translates to:
  /// **'Weight History'**
  String get exportWeightHistory;

  /// No description provided for @exportWeightHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'All your weight tracking data'**
  String get exportWeightHistorySubtitle;

  /// No description provided for @exportMealHistory.
  ///
  /// In en, this message translates to:
  /// **'Meal History'**
  String get exportMealHistory;

  /// No description provided for @exportMealHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Coming soon - meal tracking data'**
  String get exportMealHistorySubtitle;

  /// No description provided for @exportSelectAllData.
  ///
  /// In en, this message translates to:
  /// **'Select All Data'**
  String get exportSelectAllData;

  /// No description provided for @exportSelectAllDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export all available data from your account'**
  String get exportSelectAllDataSubtitle;

  /// No description provided for @fromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromLabel;

  /// No description provided for @toLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toLabel;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @exportFormatCsvDescription.
  ///
  /// In en, this message translates to:
  /// **'Comma-separated values, ideal for spreadsheets'**
  String get exportFormatCsvDescription;

  /// No description provided for @exportFormatJsonDescription.
  ///
  /// In en, this message translates to:
  /// **'Structured data format, ideal for developers'**
  String get exportFormatJsonDescription;

  /// No description provided for @exportFormatXmlDescription.
  ///
  /// In en, this message translates to:
  /// **'Enterprise-friendly structured data format'**
  String get exportFormatXmlDescription;

  /// No description provided for @exportFormatPdfDescription.
  ///
  /// In en, this message translates to:
  /// **'Human-readable report with charts and graphs'**
  String get exportFormatPdfDescription;

  /// No description provided for @exportButton.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportButton;

  /// No description provided for @exportSelectAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one data type to export'**
  String get exportSelectAtLeastOne;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully!'**
  String get exportSuccess;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {message}'**
  String exportFailed(Object message);

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorPrefix(Object message);

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get commonUpdate;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get commonSettings;

  /// No description provided for @commonProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get commonProfile;

  /// No description provided for @commonLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get commonLogout;

  /// No description provided for @commonCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get commonCamera;

  /// No description provided for @commonGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get commonGallery;

  /// No description provided for @commonCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get commonCalendar;

  /// No description provided for @commonPreviousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous Day'**
  String get commonPreviousDay;

  /// No description provided for @commonNextDay.
  ///
  /// In en, this message translates to:
  /// **'Next Day'**
  String get commonNextDay;

  /// No description provided for @commonCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get commonCalories;

  /// No description provided for @commonProteins.
  ///
  /// In en, this message translates to:
  /// **'Proteins'**
  String get commonProteins;

  /// No description provided for @commonCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get commonCarbs;

  /// No description provided for @commonFats.
  ///
  /// In en, this message translates to:
  /// **'Fats'**
  String get commonFats;

  /// No description provided for @commonWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get commonWeight;

  /// No description provided for @commonAddMeal.
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get commonAddMeal;

  /// No description provided for @commonMealName.
  ///
  /// In en, this message translates to:
  /// **'Meal Name'**
  String get commonMealName;

  /// No description provided for @commonMeal.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get commonMeal;

  /// No description provided for @commonNoPhoto.
  ///
  /// In en, this message translates to:
  /// **'No photo'**
  String get commonNoPhoto;

  /// No description provided for @commonNoPhotoAvailable.
  ///
  /// In en, this message translates to:
  /// **'No photo available'**
  String get commonNoPhotoAvailable;

  /// No description provided for @commonToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get commonToday;

  /// No description provided for @dashboardCompleteProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get dashboardCompleteProfileTitle;

  /// No description provided for @dashboardCompleteProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'To get personalized calorie and nutrition targets, please complete your profile with your basic information.'**
  String get dashboardCompleteProfileDescription;

  /// No description provided for @dashboardSkipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for Now'**
  String get dashboardSkipForNow;

  /// No description provided for @dashboardCompleteProfileCta.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get dashboardCompleteProfileCta;

  /// No description provided for @dashboardAddedMeal.
  ///
  /// In en, this message translates to:
  /// **'Added: {mealName}'**
  String dashboardAddedMeal(Object mealName);

  /// No description provided for @dashboardFailedToAddMeal.
  ///
  /// In en, this message translates to:
  /// **'Failed to add meal: {message}'**
  String dashboardFailedToAddMeal(Object message);

  /// No description provided for @dashboardMealDiscarded.
  ///
  /// In en, this message translates to:
  /// **'Meal \"{mealName}\" discarded'**
  String dashboardMealDiscarded(Object mealName);

  /// No description provided for @dashboardMealNameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Meal name cannot be empty'**
  String get dashboardMealNameCannotBeEmpty;

  /// No description provided for @dashboardFinishCurrentEdit.
  ///
  /// In en, this message translates to:
  /// **'Please finish the current edit first'**
  String get dashboardFinishCurrentEdit;

  /// No description provided for @dashboardEditMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Message'**
  String get dashboardEditMessageTitle;

  /// No description provided for @dashboardEditMealNotice.
  ///
  /// In en, this message translates to:
  /// **'This will update your meal and daily nutrition totals'**
  String get dashboardEditMealNotice;

  /// No description provided for @dashboardEditMealConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will update your meal and daily nutrition totals. Continue?'**
  String get dashboardEditMealConfirm;

  /// No description provided for @dashboardEnterFoodDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your food description'**
  String get dashboardEnterFoodDescription;

  /// No description provided for @dashboardMessageCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Message cannot be empty'**
  String get dashboardMessageCannotBeEmpty;

  /// No description provided for @dashboardFailedToEditMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to edit message: {message}'**
  String dashboardFailedToEditMessage(Object message);

  /// No description provided for @dashboardMessageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Message updated successfully'**
  String get dashboardMessageUpdated;

  /// No description provided for @dashboardMealUpdated.
  ///
  /// In en, this message translates to:
  /// **'Meal updated successfully'**
  String get dashboardMealUpdated;

  /// No description provided for @dashboardTypeAnswerPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type your answer in the chat below and send it.'**
  String get dashboardTypeAnswerPrompt;

  /// No description provided for @dashboardChatEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your food!'**
  String get dashboardChatEmptyTitle;

  /// No description provided for @dashboardChatEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Describe what you ate or record audio.\nOur AI will analyze the nutrition for you.'**
  String get dashboardChatEmptySubtitle;

  /// No description provided for @dashboardDailyNutrition.
  ///
  /// In en, this message translates to:
  /// **'Daily Nutrition'**
  String get dashboardDailyNutrition;

  /// No description provided for @dashboardPersonalized.
  ///
  /// In en, this message translates to:
  /// **'Personalized'**
  String get dashboardPersonalized;

  /// No description provided for @dashboardGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal: {goal}'**
  String dashboardGoal(Object goal);

  /// No description provided for @dashboardNutritionCaloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'{current} kcal / {target} kcal'**
  String dashboardNutritionCaloriesLabel(Object current, Object target);

  /// No description provided for @dashboardNutritionProteinLabel.
  ///
  /// In en, this message translates to:
  /// **'{current}g / {target}g Protein'**
  String dashboardNutritionProteinLabel(Object current, Object target);

  /// No description provided for @dashboardNutritionCarbsLabel.
  ///
  /// In en, this message translates to:
  /// **'{current}g / {target}g Carbs'**
  String dashboardNutritionCarbsLabel(Object current, Object target);

  /// No description provided for @dashboardNutritionFatLabel.
  ///
  /// In en, this message translates to:
  /// **'{current}g / {target}g Fat'**
  String dashboardNutritionFatLabel(Object current, Object target);

  /// No description provided for @dashboardAmountLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount}{unit} left'**
  String dashboardAmountLeft(Object amount, Object unit);

  /// No description provided for @dashboardAmountOver.
  ///
  /// In en, this message translates to:
  /// **'{amount}{unit} over'**
  String dashboardAmountOver(Object amount, Object unit);

  /// No description provided for @dashboardPercentOfTarget.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of target'**
  String dashboardPercentOfTarget(Object percent);

  /// No description provided for @dashboardNoMealsAddedToday.
  ///
  /// In en, this message translates to:
  /// **'No meals added today'**
  String get dashboardNoMealsAddedToday;

  /// No description provided for @dashboardTapPlusToAddMeal.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first meal'**
  String get dashboardTapPlusToAddMeal;

  /// No description provided for @dashboardDiscardMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard Meal'**
  String get dashboardDiscardMealTitle;

  /// No description provided for @dashboardDiscardMealPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for this discarded meal:'**
  String get dashboardDiscardMealPrompt;

  /// No description provided for @dashboardMealNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Pizza'**
  String get dashboardMealNameHint;

  /// No description provided for @dashboardDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get dashboardDiscard;

  /// No description provided for @chatEdited.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get chatEdited;

  /// No description provided for @chatImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get chatImage;

  /// No description provided for @chatAudioMessage.
  ///
  /// In en, this message translates to:
  /// **'Audio message'**
  String get chatAudioMessage;

  /// No description provided for @chatProvisionalAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Provisional Analysis'**
  String get chatProvisionalAnalysis;

  /// No description provided for @chatAiAnalysis.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis'**
  String get chatAiAnalysis;

  /// No description provided for @chatNeedsClarification.
  ///
  /// In en, this message translates to:
  /// **'NEEDS CLARIFICATION'**
  String get chatNeedsClarification;

  /// No description provided for @chatAnswerThisQuestion.
  ///
  /// In en, this message translates to:
  /// **'Answer this question'**
  String get chatAnswerThisQuestion;

  /// No description provided for @chatAddToTodaysMeals.
  ///
  /// In en, this message translates to:
  /// **'Add to Today\'s Meals'**
  String get chatAddToTodaysMeals;

  /// No description provided for @chatDiscardedMeal.
  ///
  /// In en, this message translates to:
  /// **'Discarded: {mealName}'**
  String chatDiscardedMeal(Object mealName);

  /// No description provided for @chatAddedMeal.
  ///
  /// In en, this message translates to:
  /// **'Added: {mealName}'**
  String chatAddedMeal(Object mealName);

  /// No description provided for @chatDeletedMeal.
  ///
  /// In en, this message translates to:
  /// **'Deleted: {mealName}'**
  String chatDeletedMeal(Object mealName);

  /// No description provided for @chatDeleteMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Meal?'**
  String get chatDeleteMealTitle;

  /// No description provided for @chatDeleteMealPrompt.
  ///
  /// In en, this message translates to:
  /// **'This will remove \"{mealName}\" from your meal log.'**
  String chatDeleteMealPrompt(Object mealName);

  /// No description provided for @chatMealDeleted.
  ///
  /// In en, this message translates to:
  /// **'Meal deleted'**
  String get chatMealDeleted;

  /// No description provided for @chatFailedToDeleteMeal.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete: {message}'**
  String chatFailedToDeleteMeal(Object message);

  /// No description provided for @chatNutritionFound.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Found:'**
  String get chatNutritionFound;

  /// No description provided for @chatMacroProtein.
  ///
  /// In en, this message translates to:
  /// **'protein'**
  String get chatMacroProtein;

  /// No description provided for @chatMacroCarbs.
  ///
  /// In en, this message translates to:
  /// **'carbs'**
  String get chatMacroCarbs;

  /// No description provided for @chatMacroFat.
  ///
  /// In en, this message translates to:
  /// **'fat'**
  String get chatMacroFat;

  /// No description provided for @chatMacroSummary.
  ///
  /// In en, this message translates to:
  /// **'{calories} cal • {protein}g protein • {carbs}g carbs • {fats}g fat'**
  String chatMacroSummary(
      Object calories, Object protein, Object carbs, Object fats);

  /// No description provided for @chatInputSendPhoto.
  ///
  /// In en, this message translates to:
  /// **'Send Photo'**
  String get chatInputSendPhoto;

  /// No description provided for @chatInputFailedToPickImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {message}'**
  String chatInputFailedToPickImage(Object message);

  /// No description provided for @chatInputAudioUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Audio recording temporarily unavailable'**
  String get chatInputAudioUnavailable;

  /// No description provided for @chatInputAudioUnavailableTooltip.
  ///
  /// In en, this message translates to:
  /// **'Audio recording unavailable'**
  String get chatInputAudioUnavailableTooltip;

  /// No description provided for @chatInputSendPhotoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Send photo for analysis'**
  String get chatInputSendPhotoTooltip;

  /// No description provided for @chatInputDescribeFood.
  ///
  /// In en, this message translates to:
  /// **'Describe your food...'**
  String get chatInputDescribeFood;

  /// No description provided for @chatInputSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatInputSend;

  /// No description provided for @subscriptionBannerDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days} days left in your free trial'**
  String subscriptionBannerDaysLeft(int days);

  /// No description provided for @subscriptionBannerDaysLeftUrgent.
  ///
  /// In en, this message translates to:
  /// **'{days} days left in your free trial!'**
  String subscriptionBannerDaysLeftUrgent(int days);

  /// No description provided for @subscriptionBannerHoursLeft.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours left in your free trial!'**
  String subscriptionBannerHoursLeft(int hours);

  /// No description provided for @subscriptionBannerSubscribeUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to continue unlimited access'**
  String get subscriptionBannerSubscribeUnlimited;

  /// No description provided for @subscriptionBannerSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscriptionBannerSubscribe;

  /// No description provided for @subscriptionBannerTryFree.
  ///
  /// In en, this message translates to:
  /// **'Try Free'**
  String get subscriptionBannerTryFree;

  /// No description provided for @subscriptionBannerUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get subscriptionBannerUpgrade;

  /// No description provided for @subscriptionBannerPaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get subscriptionBannerPaymentFailed;

  /// No description provided for @subscriptionBannerUpdatePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Please update your payment method'**
  String get subscriptionBannerUpdatePaymentMethod;

  /// No description provided for @calendarExitToMainMenu.
  ///
  /// In en, this message translates to:
  /// **'Exit to Main Menu'**
  String get calendarExitToMainMenu;

  /// No description provided for @calendarErrorLoadingMeals.
  ///
  /// In en, this message translates to:
  /// **'Error loading meals: {message}'**
  String calendarErrorLoadingMeals(Object message);

  /// No description provided for @calendarCaloriesChartLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Calories Chart (Last 30 Days)'**
  String get calendarCaloriesChartLast30Days;

  /// No description provided for @dayMealsNoMealsLogged.
  ///
  /// In en, this message translates to:
  /// **'No meals logged for this day'**
  String get dayMealsNoMealsLogged;

  /// No description provided for @dayMealsDailySummary.
  ///
  /// In en, this message translates to:
  /// **'Daily Summary'**
  String get dayMealsDailySummary;

  /// No description provided for @dayMealsMeals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get dayMealsMeals;

  /// No description provided for @dayMealsErrorLoadingMeals.
  ///
  /// In en, this message translates to:
  /// **'Error loading meals: {message}'**
  String dayMealsErrorLoadingMeals(Object message);

  /// No description provided for @barcodeScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get barcodeScanTitle;

  /// No description provided for @barcodeScanInstructions.
  ///
  /// In en, this message translates to:
  /// **'Position the barcode within the frame to scan'**
  String get barcodeScanInstructions;

  /// No description provided for @mealDetailUpdatingMeal.
  ///
  /// In en, this message translates to:
  /// **'Updating meal...'**
  String get mealDetailUpdatingMeal;

  /// No description provided for @mealDetailUpdated.
  ///
  /// In en, this message translates to:
  /// **'Meal updated successfully!'**
  String get mealDetailUpdated;

  /// No description provided for @mealDetailFailedToUpdate.
  ///
  /// In en, this message translates to:
  /// **'Failed to update meal: {message}'**
  String mealDetailFailedToUpdate(Object message);

  /// No description provided for @mealDetailDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Meal'**
  String get mealDetailDeleteTitle;

  /// No description provided for @mealDetailDeletePrompt.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this meal? This action cannot be undone.'**
  String get mealDetailDeletePrompt;

  /// No description provided for @mealDetailDeletingMeal.
  ///
  /// In en, this message translates to:
  /// **'Deleting meal...'**
  String get mealDetailDeletingMeal;

  /// No description provided for @mealDetailDeleted.
  ///
  /// In en, this message translates to:
  /// **'Meal deleted successfully!'**
  String get mealDetailDeleted;

  /// No description provided for @mealDetailFailedToDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete meal: {message}'**
  String mealDetailFailedToDelete(Object message);

  /// No description provided for @mealDetailEditMeal.
  ///
  /// In en, this message translates to:
  /// **'Edit Meal'**
  String get mealDetailEditMeal;

  /// No description provided for @mealDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal Details'**
  String get mealDetailTitle;

  /// No description provided for @mealDetailPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get mealDetailPhoto;

  /// No description provided for @mealDetailMealInformation.
  ///
  /// In en, this message translates to:
  /// **'Meal Information'**
  String get mealDetailMealInformation;

  /// No description provided for @mealDetailNutritionInformation.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Information'**
  String get mealDetailNutritionInformation;

  /// No description provided for @mealDetailName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get mealDetailName;

  /// No description provided for @mealDetailDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get mealDetailDate;

  /// No description provided for @mealDetailCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get mealDetailCreated;

  /// No description provided for @mealDetailCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'{date} at {time}'**
  String mealDetailCreatedAt(Object date, Object time);

  /// No description provided for @validationEnterMealName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a meal name'**
  String get validationEnterMealName;

  /// No description provided for @validationEnterCalories.
  ///
  /// In en, this message translates to:
  /// **'Please enter calories'**
  String get validationEnterCalories;

  /// No description provided for @validationEnterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get validationEnterValidNumber;

  /// No description provided for @validationCaloriesNonNegative.
  ///
  /// In en, this message translates to:
  /// **'Calories cannot be negative'**
  String get validationCaloriesNonNegative;

  /// No description provided for @validationEnterProteins.
  ///
  /// In en, this message translates to:
  /// **'Please enter proteins'**
  String get validationEnterProteins;

  /// No description provided for @validationProteinsNonNegative.
  ///
  /// In en, this message translates to:
  /// **'Proteins cannot be negative'**
  String get validationProteinsNonNegative;

  /// No description provided for @validationEnterFats.
  ///
  /// In en, this message translates to:
  /// **'Please enter fats'**
  String get validationEnterFats;

  /// No description provided for @validationFatsNonNegative.
  ///
  /// In en, this message translates to:
  /// **'Fats cannot be negative'**
  String get validationFatsNonNegative;

  /// No description provided for @validationEnterCarbs.
  ///
  /// In en, this message translates to:
  /// **'Please enter carbs'**
  String get validationEnterCarbs;

  /// No description provided for @validationCarbsNonNegative.
  ///
  /// In en, this message translates to:
  /// **'Carbs cannot be negative'**
  String get validationCarbsNonNegative;

  /// No description provided for @addMealLookupProduct.
  ///
  /// In en, this message translates to:
  /// **'Looking up product...'**
  String get addMealLookupProduct;

  /// No description provided for @addMealProductFound.
  ///
  /// In en, this message translates to:
  /// **'Product found: {name}'**
  String addMealProductFound(Object name);

  /// No description provided for @addMealUnknownProduct.
  ///
  /// In en, this message translates to:
  /// **'Unknown Product ({barcode})'**
  String addMealUnknownProduct(Object barcode);

  /// No description provided for @addMealProductNotFoundManual.
  ///
  /// In en, this message translates to:
  /// **'Product not found in database. You can enter nutrition manually.'**
  String get addMealProductNotFoundManual;

  /// No description provided for @addMealFailedToScanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Failed to scan barcode: {message}'**
  String addMealFailedToScanBarcode(Object message);

  /// No description provided for @addMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Meal - {date}'**
  String addMealTitle(Object date);

  /// No description provided for @addMealFailedToPickImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {message}'**
  String addMealFailedToPickImage(Object message);

  /// No description provided for @addMealAnalysisFailed.
  ///
  /// In en, this message translates to:
  /// **'Analysis failed: {message}'**
  String addMealAnalysisFailed(Object message);

  /// No description provided for @addMealFilledFromPhotoAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Nutrition values filled from photo analysis!'**
  String get addMealFilledFromPhotoAnalysis;

  /// No description provided for @addMealAcceptedBarcodeNutrition.
  ///
  /// In en, this message translates to:
  /// **'Product nutrition accepted! Values filled in.'**
  String get addMealAcceptedBarcodeNutrition;

  /// No description provided for @addMealAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Meal added successfully!'**
  String get addMealAddedSuccessfully;

  /// No description provided for @addMealFailedToAdd.
  ///
  /// In en, this message translates to:
  /// **'Failed to add meal: {message}'**
  String addMealFailedToAdd(Object message);

  /// No description provided for @addMealAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get addMealAnalyzing;

  /// No description provided for @addMealChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get addMealChangePhoto;

  /// No description provided for @addMealPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addMealPhoto;

  /// No description provided for @addMealAnalyzeWithAi.
  ///
  /// In en, this message translates to:
  /// **'Analyze with AI'**
  String get addMealAnalyzeWithAi;

  /// No description provided for @addMealScanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get addMealScanning;

  /// No description provided for @addMealScanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get addMealScanBarcode;

  /// No description provided for @addMealAdding.
  ///
  /// In en, this message translates to:
  /// **'Adding...'**
  String get addMealAdding;

  /// No description provided for @addMealSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get addMealSubmit;

  /// No description provided for @addMealAssumptions.
  ///
  /// In en, this message translates to:
  /// **'Assumptions:'**
  String get addMealAssumptions;

  /// No description provided for @addMealItems.
  ///
  /// In en, this message translates to:
  /// **'Items:'**
  String get addMealItems;

  /// No description provided for @addMealYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer...'**
  String get addMealYourAnswer;

  /// No description provided for @addMealUseCurrentEstimate.
  ///
  /// In en, this message translates to:
  /// **'Use current estimate'**
  String get addMealUseCurrentEstimate;

  /// No description provided for @addMealPleaseEnterAnswer.
  ///
  /// In en, this message translates to:
  /// **'Please enter an answer'**
  String get addMealPleaseEnterAnswer;

  /// No description provided for @addMealRefineEstimate.
  ///
  /// In en, this message translates to:
  /// **'Refine estimate'**
  String get addMealRefineEstimate;

  /// No description provided for @addMealAcceptFillValues.
  ///
  /// In en, this message translates to:
  /// **'Accept & Fill Values'**
  String get addMealAcceptFillValues;

  /// No description provided for @addMealProductFoundLabel.
  ///
  /// In en, this message translates to:
  /// **'Product Found:'**
  String get addMealProductFoundLabel;

  /// No description provided for @addMealBarcodeScannedLabel.
  ///
  /// In en, this message translates to:
  /// **'Barcode Scanned:'**
  String get addMealBarcodeScannedLabel;

  /// No description provided for @addMealBarcodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Barcode: {barcode}'**
  String addMealBarcodeLabel(Object barcode);

  /// No description provided for @addMealNutritionPer100g.
  ///
  /// In en, this message translates to:
  /// **'Nutrition per 100g:'**
  String get addMealNutritionPer100g;

  /// No description provided for @addMealAcceptFillNutritionValues.
  ///
  /// In en, this message translates to:
  /// **'Accept & Fill Nutrition Values'**
  String get addMealAcceptFillNutritionValues;

  /// No description provided for @addMealProductNotFoundOpenFoodFacts.
  ///
  /// In en, this message translates to:
  /// **'Product not found in OpenFoodFacts database.\nYou can enter nutrition information manually.'**
  String get addMealProductNotFoundOpenFoodFacts;

  /// No description provided for @addMealConfidenceHigh.
  ///
  /// In en, this message translates to:
  /// **'HIGH'**
  String get addMealConfidenceHigh;

  /// No description provided for @addMealConfidenceMedium.
  ///
  /// In en, this message translates to:
  /// **'MEDIUM'**
  String get addMealConfidenceMedium;

  /// No description provided for @addMealConfidenceLow.
  ///
  /// In en, this message translates to:
  /// **'LOW'**
  String get addMealConfidenceLow;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get profileTitle;

  /// No description provided for @profilePersonalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get profilePersonalInformation;

  /// No description provided for @profileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get profileFullName;

  /// No description provided for @profileEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get profileEnterName;

  /// No description provided for @profileGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get profileGender;

  /// No description provided for @profileSelectGender.
  ///
  /// In en, this message translates to:
  /// **'Please select your gender'**
  String get profileSelectGender;

  /// No description provided for @profileGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get profileGenderMale;

  /// No description provided for @profileGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get profileGenderFemale;

  /// No description provided for @profileDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get profileDateOfBirth;

  /// No description provided for @profileSelectDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Select date of birth'**
  String get profileSelectDateOfBirth;

  /// No description provided for @profilePleaseSelectDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Please select your date of birth'**
  String get profilePleaseSelectDateOfBirth;

  /// No description provided for @profileInvalidDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid date of birth'**
  String get profileInvalidDateOfBirth;

  /// No description provided for @profilePhysicalCharacteristics.
  ///
  /// In en, this message translates to:
  /// **'Physical Characteristics'**
  String get profilePhysicalCharacteristics;

  /// No description provided for @profileHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get profileHeight;

  /// No description provided for @profileHeightCm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get profileHeightCm;

  /// No description provided for @profileEnterHeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter your height'**
  String get profileEnterHeight;

  /// No description provided for @profileInvalidHeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid height (100-250 cm)'**
  String get profileInvalidHeight;

  /// No description provided for @profileCurrentWeight.
  ///
  /// In en, this message translates to:
  /// **'Current weight'**
  String get profileCurrentWeight;

  /// No description provided for @profileCurrentWeightKg.
  ///
  /// In en, this message translates to:
  /// **'Current weight (kg)'**
  String get profileCurrentWeightKg;

  /// No description provided for @profileEnterCurrentWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current weight'**
  String get profileEnterCurrentWeight;

  /// No description provided for @profileInvalidCurrentWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid weight (30-300 kg)'**
  String get profileInvalidCurrentWeight;

  /// No description provided for @profileTargetWeight.
  ///
  /// In en, this message translates to:
  /// **'Target weight'**
  String get profileTargetWeight;

  /// No description provided for @profileTargetWeightOptional.
  ///
  /// In en, this message translates to:
  /// **'Target weight (kg) - Optional'**
  String get profileTargetWeightOptional;

  /// No description provided for @profileInvalidTargetWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid target weight (30-300 kg)'**
  String get profileInvalidTargetWeight;

  /// No description provided for @profileGoalsTargets.
  ///
  /// In en, this message translates to:
  /// **'Goals & Targets'**
  String get profileGoalsTargets;

  /// No description provided for @profilePrimaryGoal.
  ///
  /// In en, this message translates to:
  /// **'Primary goal'**
  String get profilePrimaryGoal;

  /// No description provided for @profileGoalMaintaining.
  ///
  /// In en, this message translates to:
  /// **'Maintaining'**
  String get profileGoalMaintaining;

  /// No description provided for @profileGoalWeightLoss.
  ///
  /// In en, this message translates to:
  /// **'Weight Loss'**
  String get profileGoalWeightLoss;

  /// No description provided for @profileGoalWeightGain.
  ///
  /// In en, this message translates to:
  /// **'Weight Gain'**
  String get profileGoalWeightGain;

  /// No description provided for @profileGoalHypertrophy.
  ///
  /// In en, this message translates to:
  /// **'Hypertrophy'**
  String get profileGoalHypertrophy;

  /// No description provided for @profileWeeklyTarget.
  ///
  /// In en, this message translates to:
  /// **'Weekly target'**
  String get profileWeeklyTarget;

  /// No description provided for @profileWeeklyWeightLossTarget.
  ///
  /// In en, this message translates to:
  /// **'Weekly weight loss target (kg)'**
  String get profileWeeklyWeightLossTarget;

  /// No description provided for @profileWeeklyWeightGainTarget.
  ///
  /// In en, this message translates to:
  /// **'Weekly weight gain target (kg)'**
  String get profileWeeklyWeightGainTarget;

  /// No description provided for @profileWeeklyTargetHelper.
  ///
  /// In en, this message translates to:
  /// **'Recommended: 0.5-1.0 kg/week for sustainable results'**
  String get profileWeeklyTargetHelper;

  /// No description provided for @profileEnterWeeklyTarget.
  ///
  /// In en, this message translates to:
  /// **'Please enter weekly target'**
  String get profileEnterWeeklyTarget;

  /// No description provided for @profileInvalidWeeklyTarget.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid target (0.1-2.0 kg/week)'**
  String get profileInvalidWeeklyTarget;

  /// No description provided for @profileActivityLevel.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get profileActivityLevel;

  /// No description provided for @profilePalValue.
  ///
  /// In en, this message translates to:
  /// **'PAL: {value}'**
  String profilePalValue(Object value);

  /// No description provided for @profileActivitySedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get profileActivitySedentary;

  /// No description provided for @profileActivityLightlyActive.
  ///
  /// In en, this message translates to:
  /// **'Lightly active'**
  String get profileActivityLightlyActive;

  /// No description provided for @profileActivityModeratelyActive.
  ///
  /// In en, this message translates to:
  /// **'Moderately active'**
  String get profileActivityModeratelyActive;

  /// No description provided for @profileActivityVeryActive.
  ///
  /// In en, this message translates to:
  /// **'Very active'**
  String get profileActivityVeryActive;

  /// No description provided for @profileActivityExtremelyActive.
  ///
  /// In en, this message translates to:
  /// **'Extremely active'**
  String get profileActivityExtremelyActive;

  /// No description provided for @profileSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get profileSubscription;

  /// No description provided for @profileStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get profileStatus;

  /// No description provided for @profilePlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get profilePlan;

  /// No description provided for @profileMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get profileMonthly;

  /// No description provided for @profileYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get profileYearly;

  /// No description provided for @profileFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get profileFree;

  /// No description provided for @profileFreeTier.
  ///
  /// In en, this message translates to:
  /// **'Free tier'**
  String get profileFreeTier;

  /// No description provided for @profileLimitedFeatures.
  ///
  /// In en, this message translates to:
  /// **'Limited features'**
  String get profileLimitedFeatures;

  /// No description provided for @profileTrial.
  ///
  /// In en, this message translates to:
  /// **'Trial'**
  String get profileTrial;

  /// No description provided for @profilePremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get profilePremium;

  /// No description provided for @profilePastDue.
  ///
  /// In en, this message translates to:
  /// **'Past due'**
  String get profilePastDue;

  /// No description provided for @profileCanceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get profileCanceled;

  /// No description provided for @profileTrialEnds.
  ///
  /// In en, this message translates to:
  /// **'Trial ends'**
  String get profileTrialEnds;

  /// No description provided for @profileNextPayment.
  ///
  /// In en, this message translates to:
  /// **'Next payment'**
  String get profileNextPayment;

  /// No description provided for @profileRenewalDate.
  ///
  /// In en, this message translates to:
  /// **'Renewal date'**
  String get profileRenewalDate;

  /// No description provided for @profileNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get profileNotAvailable;

  /// No description provided for @profileExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get profileExpired;

  /// No description provided for @profileInMonths.
  ///
  /// In en, this message translates to:
  /// **'in {count} month{plural}'**
  String profileInMonths(Object count, Object plural);

  /// No description provided for @profileInDays.
  ///
  /// In en, this message translates to:
  /// **'in {count} day{plural}'**
  String profileInDays(Object count, Object plural);

  /// No description provided for @profileInHours.
  ///
  /// In en, this message translates to:
  /// **'in {count} hour{plural}'**
  String profileInHours(Object count, Object plural);

  /// No description provided for @profileLessThanHour.
  ///
  /// In en, this message translates to:
  /// **'Less than 1 hour'**
  String get profileLessThanHour;

  /// No description provided for @profileUpgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get profileUpgradeToPremium;

  /// No description provided for @profileLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Error loading profile: {error}'**
  String profileLoadingError(Object error);

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved successfully!'**
  String get profileSaved;

  /// No description provided for @profileSavingError.
  ///
  /// In en, this message translates to:
  /// **'Error saving profile: {error}'**
  String profileSavingError(Object error);

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get profileSave;

  /// No description provided for @weightTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight Tracking'**
  String get weightTrackingTitle;

  /// No description provided for @weightTrackingLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Error loading data: {error}'**
  String weightTrackingLoadingError(Object error);

  /// No description provided for @weightTrackingEnterWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter your weight'**
  String get weightTrackingEnterWeight;

  /// No description provided for @weightTrackingInvalidWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid weight (1-300 kg)'**
  String get weightTrackingInvalidWeight;

  /// No description provided for @weightTrackingAdded.
  ///
  /// In en, this message translates to:
  /// **'Weight entry added successfully!'**
  String get weightTrackingAdded;

  /// No description provided for @weightTrackingAddError.
  ///
  /// In en, this message translates to:
  /// **'Error adding weight entry: {error}'**
  String weightTrackingAddError(Object error);

  /// No description provided for @weightTrackingNeedMoreData.
  ///
  /// In en, this message translates to:
  /// **'Need at least 2 weight entries and a complete profile for analysis'**
  String get weightTrackingNeedMoreData;

  /// No description provided for @weightTrackingProgressAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Progress Analysis'**
  String get weightTrackingProgressAnalysis;

  /// No description provided for @weightTrackingActualWeightChange.
  ///
  /// In en, this message translates to:
  /// **'Actual Weight Change'**
  String get weightTrackingActualWeightChange;

  /// No description provided for @weightTrackingExpectedWeightChange.
  ///
  /// In en, this message translates to:
  /// **'Expected Weight Change'**
  String get weightTrackingExpectedWeightChange;

  /// No description provided for @weightTrackingProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get weightTrackingProgress;

  /// No description provided for @weightTrackingWeeklyActual.
  ///
  /// In en, this message translates to:
  /// **'Weekly Actual'**
  String get weightTrackingWeeklyActual;

  /// No description provided for @weightTrackingWeeklyExpected.
  ///
  /// In en, this message translates to:
  /// **'Weekly Expected'**
  String get weightTrackingWeeklyExpected;

  /// No description provided for @weightTrackingStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String weightTrackingStatus(Object status);

  /// No description provided for @weightTrackingUnableToAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Unable to analyze progress'**
  String get weightTrackingUnableToAnalyze;

  /// No description provided for @weightTrackingDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Weight Entry'**
  String get weightTrackingDeleteTitle;

  /// No description provided for @weightTrackingDeletePrompt.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the weight entry from {date}?'**
  String weightTrackingDeletePrompt(Object date);

  /// No description provided for @weightTrackingDeleteInvalidId.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete entry: Invalid ID'**
  String get weightTrackingDeleteInvalidId;

  /// No description provided for @weightTrackingDeleted.
  ///
  /// In en, this message translates to:
  /// **'Weight entry deleted successfully'**
  String get weightTrackingDeleted;

  /// No description provided for @weightTrackingDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting weight entry: {error}'**
  String weightTrackingDeleteError(Object error);

  /// No description provided for @weightTrackingStatusExceeding.
  ///
  /// In en, this message translates to:
  /// **'Exceeding Target'**
  String get weightTrackingStatusExceeding;

  /// No description provided for @weightTrackingStatusOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On Track'**
  String get weightTrackingStatusOnTrack;

  /// No description provided for @weightTrackingStatusSlowProgress.
  ///
  /// In en, this message translates to:
  /// **'Slow Progress'**
  String get weightTrackingStatusSlowProgress;

  /// No description provided for @weightTrackingStatusMinimalProgress.
  ///
  /// In en, this message translates to:
  /// **'Minimal Progress'**
  String get weightTrackingStatusMinimalProgress;

  /// No description provided for @weightTrackingStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get weightTrackingStatusUnknown;

  /// No description provided for @weightTrackingChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight Chart'**
  String get weightTrackingChartTitle;

  /// No description provided for @weightTrackingChartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add weight entries to see your progress chart'**
  String get weightTrackingChartEmpty;

  /// No description provided for @weightTrackingProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight Progress'**
  String get weightTrackingProgressTitle;

  /// No description provided for @weightTrackingAnalysisEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add at least 2 weight entries to see your progress analysis'**
  String get weightTrackingAnalysisEmpty;

  /// No description provided for @weightTrackingUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get weightTrackingUnknownError;

  /// No description provided for @weightTrackingAddEntry.
  ///
  /// In en, this message translates to:
  /// **'Add Weight Entry'**
  String get weightTrackingAddEntry;

  /// No description provided for @weightTrackingWeightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightTrackingWeightKg;

  /// No description provided for @weightTrackingWeightHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 70.5 or 70,5'**
  String get weightTrackingWeightHint;

  /// No description provided for @weightTrackingDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get weightTrackingDate;

  /// No description provided for @weightTrackingMeasurementTime.
  ///
  /// In en, this message translates to:
  /// **'Measurement Time'**
  String get weightTrackingMeasurementTime;

  /// No description provided for @weightTrackingMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get weightTrackingMorning;

  /// No description provided for @weightTrackingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get weightTrackingAfternoon;

  /// No description provided for @weightTrackingEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get weightTrackingEvening;

  /// No description provided for @weightTrackingNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get weightTrackingNotesOptional;

  /// No description provided for @weightTrackingNotesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., after workout, before breakfast'**
  String get weightTrackingNotesHint;

  /// No description provided for @weightTrackingHistory.
  ///
  /// In en, this message translates to:
  /// **'Weight History'**
  String get weightTrackingHistory;

  /// No description provided for @weightTrackingNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No weight entries yet'**
  String get weightTrackingNoEntries;

  /// No description provided for @weightTrackingNoEntriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first weight entry above to start tracking your progress'**
  String get weightTrackingNoEntriesSubtitle;

  /// No description provided for @weightTrackingDeleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete entry'**
  String get weightTrackingDeleteEntry;

  /// No description provided for @weightTrackingInitialPhase.
  ///
  /// In en, this message translates to:
  /// **'Initial Phase'**
  String get weightTrackingInitialPhase;

  /// No description provided for @dashboardAnalysisFoodSuccess.
  ///
  /// In en, this message translates to:
  /// **'Food analyzed successfully'**
  String get dashboardAnalysisFoodSuccess;

  /// No description provided for @dashboardAnalysisFoodFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to analyze food: {error}'**
  String dashboardAnalysisFoodFailed(Object error);

  /// No description provided for @dashboardAnalysisAudioSuccess.
  ///
  /// In en, this message translates to:
  /// **'Food analyzed from audio'**
  String get dashboardAnalysisAudioSuccess;

  /// No description provided for @dashboardAnalysisAudioFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to analyze audio: {error}'**
  String dashboardAnalysisAudioFailed(Object error);

  /// No description provided for @dashboardAnalysisImageSuccess.
  ///
  /// In en, this message translates to:
  /// **'Food analyzed from image'**
  String get dashboardAnalysisImageSuccess;

  /// No description provided for @dashboardAnalysisImageFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to analyze image: {error}'**
  String dashboardAnalysisImageFailed(Object error);

  /// No description provided for @dashboardAnalysisRefinedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Refined food analysis'**
  String get dashboardAnalysisRefinedSuccess;

  /// No description provided for @dashboardAnalysisRefinedFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to refine analysis: {error}'**
  String dashboardAnalysisRefinedFailed(Object error);

  /// No description provided for @dashboardUpdatedMealFallback.
  ///
  /// In en, this message translates to:
  /// **'Updated Meal'**
  String get dashboardUpdatedMealFallback;
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
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
