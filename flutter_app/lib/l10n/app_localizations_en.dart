// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Food Scanner';

  @override
  String get language => 'Language';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePolish => 'Polski';

  @override
  String get screenSplashLoading => 'Loading...';

  @override
  String get loginWelcomeBack => 'Welcome Back!';

  @override
  String get loginSubtitle => 'Log in to continue your journey.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get logIn => 'Log In';

  @override
  String get register => 'Register';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get registerCreateAccount => 'Create Account';

  @override
  String get registerSubtitle => 'Start your journey with us today.';

  @override
  String get validationEnterEmailAndPassword =>
      'Please enter both email and password';

  @override
  String get validationEnterEmail => 'Please enter an email address';

  @override
  String get validationValidEmail => 'Please enter a valid email address';

  @override
  String get validationPasswordMinLength =>
      'Password must be at least 6 characters long';

  @override
  String get validationPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get registerAccountExists =>
      'An account with this email already exists';

  @override
  String get registerSuccessVerifyEmail =>
      'Registration successful! Check your email to verify your account.';

  @override
  String get registerNoUserCreated => 'Registration failed: No user created';

  @override
  String registerFailed(Object message) {
    return 'Registration failed: $message';
  }

  @override
  String genericErrorWithMessage(Object message) {
    return 'An error occurred: $message';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubscriptionSection => 'Subscription';

  @override
  String get settingsManageSubscription => 'Manage Subscription';

  @override
  String get settingsUpgradeToPremium => 'Upgrade to Premium';

  @override
  String get settingsDataManagementSection => 'Data Management';

  @override
  String get settingsExportData => 'Export Data';

  @override
  String get settingsExportDataSubtitle =>
      'Download your weight history and meal data';

  @override
  String get settingsAccountSection => 'Account';

  @override
  String get settingsProfileSettings => 'Profile Settings';

  @override
  String get settingsProfileSettingsSubtitle =>
      'Manage your profile information';

  @override
  String get settingsPrivacySecurity => 'Privacy & Security';

  @override
  String get settingsPrivacySecuritySubtitle => 'Manage your privacy settings';

  @override
  String get settingsSupportSection => 'Support';

  @override
  String get settingsHelpFaq => 'Help & FAQ';

  @override
  String get settingsHelpFaqSubtitle => 'Get help and find answers';

  @override
  String get settingsSendFeedback => 'Send Feedback';

  @override
  String get settingsSendFeedbackSubtitle => 'Help us improve the app';

  @override
  String get settingsLanguageSubtitle => 'Choose app language';

  @override
  String get settingsSubscriptionPortalUnavailable =>
      'Could not open subscription portal';

  @override
  String get settingsSubscriptionPortalFailed =>
      'Failed to access subscription portal';

  @override
  String get comingSoon => 'Coming soon!';

  @override
  String get subscriptionTitle => 'Upgrade to Premium';

  @override
  String get subscriptionHeaderTitle => 'Unlock Premium Features';

  @override
  String get subscriptionHeaderTrialSubtitle => 'Start your 7-day free trial';

  @override
  String get subscriptionHeaderChoosePlan => 'Choose your plan';

  @override
  String get subscriptionFeatureUnlimitedScanning => 'Unlimited food scanning';

  @override
  String get subscriptionFeatureAiAnalysis => 'AI-powered nutrition analysis';

  @override
  String get subscriptionFeatureMealTracking => 'Advanced meal tracking';

  @override
  String get subscriptionFeatureRecommendations =>
      'Personalized recommendations';

  @override
  String get subscriptionFeatureExportData => 'Export your data';

  @override
  String get subscriptionFeaturePrioritySupport => 'Priority support';

  @override
  String get subscriptionBestValue => 'BEST VALUE';

  @override
  String subscriptionJustPricePerMonth(Object price) {
    return 'Just $price';
  }

  @override
  String get subscriptionCheckoutFailed => 'Failed to start checkout';

  @override
  String get subscriptionOpeningCheckout =>
      'Opening Stripe Checkout... Return to the app after completing purchase.';

  @override
  String get subscriptionCouldNotOpenCheckout => 'Could not open checkout';

  @override
  String get subscriptionStartFreeTrial => 'Start Free Trial';

  @override
  String get subscriptionSubscribeNow => 'Subscribe Now';

  @override
  String get subscriptionTrialTerms =>
      'Cancel anytime. You won\'t be charged until the trial ends.';

  @override
  String get subscriptionPaidTerms =>
      'Cancel anytime. Billed monthly or annually.';

  @override
  String subscriptionCurrentStatus(Object status) {
    return 'Current Status: $status';
  }

  @override
  String subscriptionTierLabel(Object tier) {
    return 'Tier: $tier';
  }

  @override
  String subscriptionTrialEnds(Object date) {
    return 'Trial ends: $date';
  }

  @override
  String get subscriptionFreeTrialBadge => '7-day free trial';

  @override
  String get subscriptionStatusActive => 'Active';

  @override
  String get subscriptionStatusTrial => 'Trial';

  @override
  String get subscriptionStatusFree => 'Free';

  @override
  String get subscriptionStatusPastDue => 'Past Due';

  @override
  String get subscriptionStatusCanceled => 'Canceled';

  @override
  String get subscriptionTierMonthly => 'Monthly';

  @override
  String get subscriptionTierYearly => 'Yearly';

  @override
  String subscriptionCancelsInDays(int days, Object tier) {
    return 'Cancels in $days days - $tier';
  }

  @override
  String subscriptionCancelsTomorrow(Object tier) {
    return 'Cancels tomorrow - $tier';
  }

  @override
  String subscriptionCancelsToday(Object tier) {
    return 'Cancels today - $tier';
  }

  @override
  String subscriptionCancelsOnDate(Object date) {
    return 'Cancels on $date';
  }

  @override
  String subscriptionTrialDaysRemaining(int days) {
    return 'Trial - $days days remaining';
  }

  @override
  String get subscriptionTrialOneDayRemaining => 'Trial - 1 day remaining';

  @override
  String subscriptionTrialHoursRemaining(int hours) {
    return 'Trial - $hours hours remaining';
  }

  @override
  String subscriptionTrialTier(Object tier) {
    return 'Trial - $tier';
  }

  @override
  String subscriptionStatusWithTier(Object status, Object tier) {
    return '$status - $tier';
  }

  @override
  String get subscriptionUnlockUnlimited => 'Unlock unlimited features';

  @override
  String get subscriptionStartTrial => 'Start 7-day free trial';

  @override
  String get exportDataTitle => 'Export Data';

  @override
  String get exportDataExportingTitle => 'Exporting your data...';

  @override
  String get exportDataExportingSubtitle => 'This may take a few moments';

  @override
  String get exportSectionDataToExport => 'Data to Export';

  @override
  String get exportSectionDateRange => 'Date Range';

  @override
  String get exportSectionFormat => 'Export Format';

  @override
  String get exportWeightHistory => 'Weight History';

  @override
  String get exportWeightHistorySubtitle => 'All your weight tracking data';

  @override
  String get exportMealHistory => 'Meal History';

  @override
  String get exportMealHistorySubtitle => 'Coming soon - meal tracking data';

  @override
  String get exportSelectAllData => 'Select All Data';

  @override
  String get exportSelectAllDataSubtitle =>
      'Export all available data from your account';

  @override
  String get fromLabel => 'From';

  @override
  String get toLabel => 'To';

  @override
  String get selectDate => 'Select date';

  @override
  String get exportFormatCsvDescription =>
      'Comma-separated values, ideal for spreadsheets';

  @override
  String get exportFormatJsonDescription =>
      'Structured data format, ideal for developers';

  @override
  String get exportFormatXmlDescription =>
      'Enterprise-friendly structured data format';

  @override
  String get exportFormatPdfDescription =>
      'Human-readable report with charts and graphs';

  @override
  String get exportButton => 'Export Data';

  @override
  String get exportSelectAtLeastOne =>
      'Please select at least one data type to export';

  @override
  String get exportSuccess => 'Data exported successfully!';

  @override
  String exportFailed(Object message) {
    return 'Export failed: $message';
  }

  @override
  String errorPrefix(Object message) {
    return 'Error: $message';
  }

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonUpdate => 'Update';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSettings => 'Settings';

  @override
  String get commonProfile => 'Profile';

  @override
  String get commonLogout => 'Logout';

  @override
  String get commonCamera => 'Camera';

  @override
  String get commonGallery => 'Gallery';

  @override
  String get commonCalendar => 'Calendar';

  @override
  String get commonPreviousDay => 'Previous Day';

  @override
  String get commonNextDay => 'Next Day';

  @override
  String get commonCalories => 'Calories';

  @override
  String get commonProteins => 'Proteins';

  @override
  String get commonCarbs => 'Carbs';

  @override
  String get commonFats => 'Fats';

  @override
  String get commonWeight => 'Weight';

  @override
  String get commonAddMeal => 'Add Meal';

  @override
  String get commonMealName => 'Meal Name';

  @override
  String get commonMeal => 'Meal';

  @override
  String get commonNoPhoto => 'No photo';

  @override
  String get commonNoPhotoAvailable => 'No photo available';

  @override
  String get commonToday => 'Today';

  @override
  String get dashboardCompleteProfileTitle => 'Complete Your Profile';

  @override
  String get dashboardCompleteProfileDescription =>
      'To get personalized calorie and nutrition targets, please complete your profile with your basic information.';

  @override
  String get dashboardSkipForNow => 'Skip for Now';

  @override
  String get dashboardCompleteProfileCta => 'Complete Profile';

  @override
  String dashboardAddedMeal(Object mealName) {
    return 'Added: $mealName';
  }

  @override
  String dashboardFailedToAddMeal(Object message) {
    return 'Failed to add meal: $message';
  }

  @override
  String dashboardMealDiscarded(Object mealName) {
    return 'Meal \"$mealName\" discarded';
  }

  @override
  String get dashboardMealNameCannotBeEmpty => 'Meal name cannot be empty';

  @override
  String get dashboardFinishCurrentEdit =>
      'Please finish the current edit first';

  @override
  String get dashboardEditMessageTitle => 'Edit Message';

  @override
  String get dashboardEditMealNotice =>
      'This will update your meal and daily nutrition totals';

  @override
  String get dashboardEditMealConfirm =>
      'This will update your meal and daily nutrition totals. Continue?';

  @override
  String get dashboardEnterFoodDescription => 'Enter your food description';

  @override
  String get dashboardMessageCannotBeEmpty => 'Message cannot be empty';

  @override
  String dashboardFailedToEditMessage(Object message) {
    return 'Failed to edit message: $message';
  }

  @override
  String get dashboardMessageUpdated => 'Message updated successfully';

  @override
  String get dashboardMealUpdated => 'Meal updated successfully';

  @override
  String get dashboardTypeAnswerPrompt =>
      'Type your answer in the chat below and send it.';

  @override
  String get dashboardChatEmptyTitle => 'Start tracking your food!';

  @override
  String get dashboardChatEmptySubtitle =>
      'Describe what you ate or record audio.\nOur AI will analyze the nutrition for you.';

  @override
  String get dashboardDailyNutrition => 'Daily Nutrition';

  @override
  String get dashboardPersonalized => 'Personalized';

  @override
  String dashboardGoal(Object goal) {
    return 'Goal: $goal';
  }

  @override
  String dashboardNutritionCaloriesLabel(Object current, Object target) {
    return '$current kcal / $target kcal';
  }

  @override
  String dashboardNutritionProteinLabel(Object current, Object target) {
    return '${current}g / ${target}g Protein';
  }

  @override
  String dashboardNutritionCarbsLabel(Object current, Object target) {
    return '${current}g / ${target}g Carbs';
  }

  @override
  String dashboardNutritionFatLabel(Object current, Object target) {
    return '${current}g / ${target}g Fat';
  }

  @override
  String dashboardAmountLeft(Object amount, Object unit) {
    return '$amount$unit left';
  }

  @override
  String dashboardAmountOver(Object amount, Object unit) {
    return '$amount$unit over';
  }

  @override
  String dashboardPercentOfTarget(Object percent) {
    return '$percent% of target';
  }

  @override
  String get dashboardNoMealsAddedToday => 'No meals added today';

  @override
  String get dashboardTapPlusToAddMeal =>
      'Tap the + button to add your first meal';

  @override
  String get dashboardDiscardMealTitle => 'Discard Meal';

  @override
  String get dashboardDiscardMealPrompt =>
      'Enter a name for this discarded meal:';

  @override
  String get dashboardMealNameHint => 'e.g., Pizza';

  @override
  String get dashboardDiscard => 'Discard';

  @override
  String get chatEdited => 'edited';

  @override
  String get chatImage => 'Image';

  @override
  String get chatAudioMessage => 'Audio message';

  @override
  String get chatProvisionalAnalysis => 'Provisional Analysis';

  @override
  String get chatAiAnalysis => 'AI Analysis';

  @override
  String get chatNeedsClarification => 'NEEDS CLARIFICATION';

  @override
  String get chatAnswerThisQuestion => 'Answer this question';

  @override
  String get chatAddToTodaysMeals => 'Add to Today\'s Meals';

  @override
  String chatDiscardedMeal(Object mealName) {
    return 'Discarded: $mealName';
  }

  @override
  String chatAddedMeal(Object mealName) {
    return 'Added: $mealName';
  }

  @override
  String chatDeletedMeal(Object mealName) {
    return 'Deleted: $mealName';
  }

  @override
  String get chatDeleteMealTitle => 'Delete Meal?';

  @override
  String chatDeleteMealPrompt(Object mealName) {
    return 'This will remove \"$mealName\" from your meal log.';
  }

  @override
  String get chatMealDeleted => 'Meal deleted';

  @override
  String chatFailedToDeleteMeal(Object message) {
    return 'Failed to delete: $message';
  }

  @override
  String get chatNutritionFound => 'Nutrition Found:';

  @override
  String get chatMacroProtein => 'protein';

  @override
  String get chatMacroCarbs => 'carbs';

  @override
  String get chatMacroFat => 'fat';

  @override
  String chatMacroSummary(
      Object calories, Object protein, Object carbs, Object fats) {
    return '$calories cal • ${protein}g protein • ${carbs}g carbs • ${fats}g fat';
  }

  @override
  String get chatInputSendPhoto => 'Send Photo';

  @override
  String chatInputFailedToPickImage(Object message) {
    return 'Failed to pick image: $message';
  }

  @override
  String get chatInputAudioUnavailable =>
      'Audio recording temporarily unavailable';

  @override
  String get chatInputAudioUnavailableTooltip => 'Audio recording unavailable';

  @override
  String get chatInputSendPhotoTooltip => 'Send photo for analysis';

  @override
  String get chatInputDescribeFood => 'Describe your food...';

  @override
  String get chatInputSend => 'Send';

  @override
  String subscriptionBannerDaysLeft(int days) {
    return '$days days left in your free trial';
  }

  @override
  String subscriptionBannerDaysLeftUrgent(int days) {
    return '$days days left in your free trial!';
  }

  @override
  String subscriptionBannerHoursLeft(int hours) {
    return '$hours hours left in your free trial!';
  }

  @override
  String get subscriptionBannerSubscribeUnlimited =>
      'Subscribe to continue unlimited access';

  @override
  String get subscriptionBannerSubscribe => 'Subscribe';

  @override
  String get subscriptionBannerTryFree => 'Try Free';

  @override
  String get subscriptionBannerUpgrade => 'Upgrade';

  @override
  String get subscriptionBannerPaymentFailed => 'Payment Failed';

  @override
  String get subscriptionBannerUpdatePaymentMethod =>
      'Please update your payment method';

  @override
  String get calendarExitToMainMenu => 'Exit to Main Menu';

  @override
  String calendarErrorLoadingMeals(Object message) {
    return 'Error loading meals: $message';
  }

  @override
  String get calendarCaloriesChartLast30Days => 'Calories Chart (Last 30 Days)';

  @override
  String get dayMealsNoMealsLogged => 'No meals logged for this day';

  @override
  String get dayMealsDailySummary => 'Daily Summary';

  @override
  String get dayMealsMeals => 'Meals';

  @override
  String dayMealsErrorLoadingMeals(Object message) {
    return 'Error loading meals: $message';
  }

  @override
  String get barcodeScanTitle => 'Scan Barcode';

  @override
  String get barcodeScanInstructions =>
      'Position the barcode within the frame to scan';

  @override
  String get mealDetailUpdatingMeal => 'Updating meal...';

  @override
  String get mealDetailUpdated => 'Meal updated successfully!';

  @override
  String mealDetailFailedToUpdate(Object message) {
    return 'Failed to update meal: $message';
  }

  @override
  String get mealDetailDeleteTitle => 'Delete Meal';

  @override
  String get mealDetailDeletePrompt =>
      'Are you sure you want to delete this meal? This action cannot be undone.';

  @override
  String get mealDetailDeletingMeal => 'Deleting meal...';

  @override
  String get mealDetailDeleted => 'Meal deleted successfully!';

  @override
  String mealDetailFailedToDelete(Object message) {
    return 'Failed to delete meal: $message';
  }

  @override
  String get mealDetailEditMeal => 'Edit Meal';

  @override
  String get mealDetailTitle => 'Meal Details';

  @override
  String get mealDetailPhoto => 'Photo';

  @override
  String get mealDetailMealInformation => 'Meal Information';

  @override
  String get mealDetailNutritionInformation => 'Nutrition Information';

  @override
  String get mealDetailName => 'Name';

  @override
  String get mealDetailDate => 'Date';

  @override
  String get mealDetailCreated => 'Created';

  @override
  String mealDetailCreatedAt(Object date, Object time) {
    return '$date at $time';
  }

  @override
  String get validationEnterMealName => 'Please enter a meal name';

  @override
  String get validationEnterCalories => 'Please enter calories';

  @override
  String get validationEnterValidNumber => 'Please enter a valid number';

  @override
  String get validationCaloriesNonNegative => 'Calories cannot be negative';

  @override
  String get validationEnterProteins => 'Please enter proteins';

  @override
  String get validationProteinsNonNegative => 'Proteins cannot be negative';

  @override
  String get validationEnterFats => 'Please enter fats';

  @override
  String get validationFatsNonNegative => 'Fats cannot be negative';

  @override
  String get validationEnterCarbs => 'Please enter carbs';

  @override
  String get validationCarbsNonNegative => 'Carbs cannot be negative';

  @override
  String get addMealLookupProduct => 'Looking up product...';

  @override
  String addMealProductFound(Object name) {
    return 'Product found: $name';
  }

  @override
  String addMealUnknownProduct(Object barcode) {
    return 'Unknown Product ($barcode)';
  }

  @override
  String get addMealProductNotFoundManual =>
      'Product not found in database. You can enter nutrition manually.';

  @override
  String addMealFailedToScanBarcode(Object message) {
    return 'Failed to scan barcode: $message';
  }

  @override
  String addMealTitle(Object date) {
    return 'Add Meal - $date';
  }

  @override
  String addMealFailedToPickImage(Object message) {
    return 'Failed to pick image: $message';
  }

  @override
  String addMealAnalysisFailed(Object message) {
    return 'Analysis failed: $message';
  }

  @override
  String get addMealFilledFromPhotoAnalysis =>
      'Nutrition values filled from photo analysis!';

  @override
  String get addMealAcceptedBarcodeNutrition =>
      'Product nutrition accepted! Values filled in.';

  @override
  String get addMealAddedSuccessfully => 'Meal added successfully!';

  @override
  String addMealFailedToAdd(Object message) {
    return 'Failed to add meal: $message';
  }

  @override
  String get addMealAnalyzing => 'Analyzing...';

  @override
  String get addMealChangePhoto => 'Change Photo';

  @override
  String get addMealPhoto => 'Add Photo';

  @override
  String get addMealAnalyzeWithAi => 'Analyze with AI';

  @override
  String get addMealScanning => 'Scanning...';

  @override
  String get addMealScanBarcode => 'Scan Barcode';

  @override
  String get addMealAdding => 'Adding...';

  @override
  String get addMealSubmit => 'Submit';

  @override
  String get addMealAssumptions => 'Assumptions:';

  @override
  String get addMealItems => 'Items:';

  @override
  String get addMealYourAnswer => 'Your answer...';

  @override
  String get addMealUseCurrentEstimate => 'Use current estimate';

  @override
  String get addMealPleaseEnterAnswer => 'Please enter an answer';

  @override
  String get addMealRefineEstimate => 'Refine estimate';

  @override
  String get addMealAcceptFillValues => 'Accept & Fill Values';

  @override
  String get addMealProductFoundLabel => 'Product Found:';

  @override
  String get addMealBarcodeScannedLabel => 'Barcode Scanned:';

  @override
  String addMealBarcodeLabel(Object barcode) {
    return 'Barcode: $barcode';
  }

  @override
  String get addMealNutritionPer100g => 'Nutrition per 100g:';

  @override
  String get addMealAcceptFillNutritionValues =>
      'Accept & Fill Nutrition Values';

  @override
  String get addMealProductNotFoundOpenFoodFacts =>
      'Product not found in OpenFoodFacts database.\nYou can enter nutrition information manually.';

  @override
  String get addMealConfidenceHigh => 'HIGH';

  @override
  String get addMealConfidenceMedium => 'MEDIUM';

  @override
  String get addMealConfidenceLow => 'LOW';

  @override
  String get profileTitle => 'Your Profile';

  @override
  String get profilePersonalInformation => 'Personal Information';

  @override
  String get profileFullName => 'Full Name';

  @override
  String get profileEnterName => 'Please enter your name';

  @override
  String get profileGender => 'Gender';

  @override
  String get profileSelectGender => 'Please select your gender';

  @override
  String get profileGenderMale => 'Male';

  @override
  String get profileGenderFemale => 'Female';

  @override
  String get profileDateOfBirth => 'Date of birth';

  @override
  String get profileSelectDateOfBirth => 'Select date of birth';

  @override
  String get profilePleaseSelectDateOfBirth =>
      'Please select your date of birth';

  @override
  String get profileInvalidDateOfBirth => 'Please enter a valid date of birth';

  @override
  String get profilePhysicalCharacteristics => 'Physical Characteristics';

  @override
  String get profileHeight => 'Height';

  @override
  String get profileHeightCm => 'Height (cm)';

  @override
  String get profileEnterHeight => 'Please enter your height';

  @override
  String get profileInvalidHeight => 'Please enter a valid height (100-250 cm)';

  @override
  String get profileCurrentWeight => 'Current weight';

  @override
  String get profileCurrentWeightKg => 'Current weight (kg)';

  @override
  String get profileEnterCurrentWeight => 'Please enter your current weight';

  @override
  String get profileInvalidCurrentWeight =>
      'Please enter a valid weight (30-300 kg)';

  @override
  String get profileTargetWeight => 'Target weight';

  @override
  String get profileTargetWeightOptional => 'Target weight (kg) - Optional';

  @override
  String get profileInvalidTargetWeight =>
      'Please enter a valid target weight (30-300 kg)';

  @override
  String get profileGoalsTargets => 'Goals & Targets';

  @override
  String get profilePrimaryGoal => 'Primary goal';

  @override
  String get profileGoalMaintaining => 'Maintaining';

  @override
  String get profileGoalWeightLoss => 'Weight Loss';

  @override
  String get profileGoalWeightGain => 'Weight Gain';

  @override
  String get profileGoalHypertrophy => 'Hypertrophy';

  @override
  String get profileWeeklyTarget => 'Weekly target';

  @override
  String get profileWeeklyWeightLossTarget => 'Weekly weight loss target (kg)';

  @override
  String get profileWeeklyWeightGainTarget => 'Weekly weight gain target (kg)';

  @override
  String get profileWeeklyTargetHelper =>
      'Recommended: 0.5-1.0 kg/week for sustainable results';

  @override
  String get profileEnterWeeklyTarget => 'Please enter weekly target';

  @override
  String get profileInvalidWeeklyTarget =>
      'Please enter a valid target (0.1-2.0 kg/week)';

  @override
  String get profileActivityLevel => 'Activity Level';

  @override
  String profilePalValue(Object value) {
    return 'PAL: $value';
  }

  @override
  String get profileActivitySedentary => 'Sedentary';

  @override
  String get profileActivityLightlyActive => 'Lightly active';

  @override
  String get profileActivityModeratelyActive => 'Moderately active';

  @override
  String get profileActivityVeryActive => 'Very active';

  @override
  String get profileActivityExtremelyActive => 'Extremely active';

  @override
  String get profileSubscription => 'Subscription';

  @override
  String get profileStatus => 'Status';

  @override
  String get profilePlan => 'Plan';

  @override
  String get profileMonthly => 'Monthly';

  @override
  String get profileYearly => 'Yearly';

  @override
  String get profileFree => 'Free';

  @override
  String get profileFreeTier => 'Free tier';

  @override
  String get profileLimitedFeatures => 'Limited features';

  @override
  String get profileTrial => 'Trial';

  @override
  String get profilePremium => 'Premium';

  @override
  String get profilePastDue => 'Past due';

  @override
  String get profileCanceled => 'Canceled';

  @override
  String get profileTrialEnds => 'Trial ends';

  @override
  String get profileNextPayment => 'Next payment';

  @override
  String get profileRenewalDate => 'Renewal date';

  @override
  String get profileNotAvailable => 'N/A';

  @override
  String get profileExpired => 'Expired';

  @override
  String profileInMonths(Object count, Object plural) {
    return 'in $count month$plural';
  }

  @override
  String profileInDays(Object count, Object plural) {
    return 'in $count day$plural';
  }

  @override
  String profileInHours(Object count, Object plural) {
    return 'in $count hour$plural';
  }

  @override
  String get profileLessThanHour => 'Less than 1 hour';

  @override
  String get profileUpgradeToPremium => 'Upgrade to Premium';

  @override
  String profileLoadingError(Object error) {
    return 'Error loading profile: $error';
  }

  @override
  String get profileSaved => 'Profile saved successfully!';

  @override
  String profileSavingError(Object error) {
    return 'Error saving profile: $error';
  }

  @override
  String get profileSave => 'Save Profile';

  @override
  String get weightTrackingTitle => 'Weight Tracking';

  @override
  String weightTrackingLoadingError(Object error) {
    return 'Error loading data: $error';
  }

  @override
  String get weightTrackingEnterWeight => 'Please enter your weight';

  @override
  String get weightTrackingInvalidWeight =>
      'Please enter a valid weight (1-300 kg)';

  @override
  String get weightTrackingAdded => 'Weight entry added successfully!';

  @override
  String weightTrackingAddError(Object error) {
    return 'Error adding weight entry: $error';
  }

  @override
  String get weightTrackingNeedMoreData =>
      'Need at least 2 weight entries and a complete profile for analysis';

  @override
  String get weightTrackingProgressAnalysis => 'Progress Analysis';

  @override
  String get weightTrackingActualWeightChange => 'Actual Weight Change';

  @override
  String get weightTrackingExpectedWeightChange => 'Expected Weight Change';

  @override
  String get weightTrackingProgress => 'Progress';

  @override
  String get weightTrackingWeeklyActual => 'Weekly Actual';

  @override
  String get weightTrackingWeeklyExpected => 'Weekly Expected';

  @override
  String weightTrackingStatus(Object status) {
    return 'Status: $status';
  }

  @override
  String get weightTrackingUnableToAnalyze => 'Unable to analyze progress';

  @override
  String get weightTrackingDeleteTitle => 'Delete Weight Entry';

  @override
  String weightTrackingDeletePrompt(Object date) {
    return 'Are you sure you want to delete the weight entry from $date?';
  }

  @override
  String get weightTrackingDeleteInvalidId => 'Cannot delete entry: Invalid ID';

  @override
  String get weightTrackingDeleted => 'Weight entry deleted successfully';

  @override
  String weightTrackingDeleteError(Object error) {
    return 'Error deleting weight entry: $error';
  }

  @override
  String get weightTrackingStatusExceeding => 'Exceeding Target';

  @override
  String get weightTrackingStatusOnTrack => 'On Track';

  @override
  String get weightTrackingStatusSlowProgress => 'Slow Progress';

  @override
  String get weightTrackingStatusMinimalProgress => 'Minimal Progress';

  @override
  String get weightTrackingStatusUnknown => 'Unknown';

  @override
  String get weightTrackingChartTitle => 'Weight Chart';

  @override
  String get weightTrackingChartEmpty =>
      'Add weight entries to see your progress chart';

  @override
  String get weightTrackingProgressTitle => 'Weight Progress';

  @override
  String get weightTrackingAnalysisEmpty =>
      'Add at least 2 weight entries to see your progress analysis';

  @override
  String get weightTrackingUnknownError => 'Unknown error';

  @override
  String get weightTrackingAddEntry => 'Add Weight Entry';

  @override
  String get weightTrackingWeightKg => 'Weight (kg)';

  @override
  String get weightTrackingWeightHint => 'e.g., 70.5 or 70,5';

  @override
  String get weightTrackingDate => 'Date';

  @override
  String get weightTrackingMeasurementTime => 'Measurement Time';

  @override
  String get weightTrackingMorning => 'Morning';

  @override
  String get weightTrackingAfternoon => 'Afternoon';

  @override
  String get weightTrackingEvening => 'Evening';

  @override
  String get weightTrackingNotesOptional => 'Notes (optional)';

  @override
  String get weightTrackingNotesHint => 'e.g., after workout, before breakfast';

  @override
  String get weightTrackingHistory => 'Weight History';

  @override
  String get weightTrackingNoEntries => 'No weight entries yet';

  @override
  String get weightTrackingNoEntriesSubtitle =>
      'Add your first weight entry above to start tracking your progress';

  @override
  String get weightTrackingDeleteEntry => 'Delete entry';

  @override
  String get weightTrackingInitialPhase => 'Initial Phase';

  @override
  String get dashboardAnalysisFoodSuccess => 'Food analyzed successfully';

  @override
  String dashboardAnalysisFoodFailed(Object error) {
    return 'Failed to analyze food: $error';
  }

  @override
  String get dashboardAnalysisAudioSuccess => 'Food analyzed from audio';

  @override
  String dashboardAnalysisAudioFailed(Object error) {
    return 'Failed to analyze audio: $error';
  }

  @override
  String get dashboardAnalysisImageSuccess => 'Food analyzed from image';

  @override
  String dashboardAnalysisImageFailed(Object error) {
    return 'Failed to analyze image: $error';
  }

  @override
  String get dashboardAnalysisRefinedSuccess => 'Refined food analysis';

  @override
  String dashboardAnalysisRefinedFailed(Object error) {
    return 'Failed to refine analysis: $error';
  }

  @override
  String get dashboardUpdatedMealFallback => 'Updated Meal';
}
