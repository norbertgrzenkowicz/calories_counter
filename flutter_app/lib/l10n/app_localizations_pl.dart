// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Skaner Jedzenia';

  @override
  String get language => 'Język';

  @override
  String get languageSystemDefault => 'Domyślny systemowy';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePolish => 'Polski';

  @override
  String get screenSplashLoading => 'Ładowanie...';

  @override
  String get loginWelcomeBack => 'Witaj ponownie!';

  @override
  String get loginSubtitle => 'Zaloguj się, aby kontynuować swoją drogę.';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Hasło';

  @override
  String get confirmPassword => 'Potwierdź hasło';

  @override
  String get logIn => 'Zaloguj się';

  @override
  String get register => 'Zarejestruj się';

  @override
  String get dontHaveAccount => 'Nie masz konta?';

  @override
  String get alreadyHaveAccount => 'Masz już konto?';

  @override
  String get registerCreateAccount => 'Utwórz konto';

  @override
  String get registerSubtitle => 'Rozpocznij swoją drogę już dziś.';

  @override
  String get validationEnterEmailAndPassword => 'Wpisz adres e-mail i hasło';

  @override
  String get validationEnterEmail => 'Wpisz adres e-mail';

  @override
  String get validationValidEmail => 'Wpisz poprawny adres e-mail';

  @override
  String get validationPasswordMinLength =>
      'Hasło musi mieć co najmniej 6 znaków';

  @override
  String get validationPasswordsDoNotMatch => 'Hasła nie są takie same';

  @override
  String get registerAccountExists => 'Konto z tym adresem e-mail już istnieje';

  @override
  String get registerSuccessVerifyEmail =>
      'Rejestracja zakończona sukcesem. Sprawdź skrzynkę e-mail, aby potwierdzić konto.';

  @override
  String get registerNoUserCreated =>
      'Rejestracja nie powiodła się: konto nie zostało utworzone';

  @override
  String registerFailed(Object message) {
    return 'Rejestracja nie powiodła się: $message';
  }

  @override
  String genericErrorWithMessage(Object message) {
    return 'Wystąpił błąd: $message';
  }

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get settingsSubscriptionSection => 'Subskrypcja';

  @override
  String get settingsManageSubscription => 'Zarządzaj subskrypcją';

  @override
  String get settingsUpgradeToPremium => 'Przejdź na Premium';

  @override
  String get settingsDataManagementSection => 'Zarządzanie danymi';

  @override
  String get settingsExportData => 'Eksport danych';

  @override
  String get settingsExportDataSubtitle =>
      'Pobierz historię wagi i dane posiłków';

  @override
  String get settingsAccountSection => 'Konto';

  @override
  String get settingsProfileSettings => 'Ustawienia profilu';

  @override
  String get settingsProfileSettingsSubtitle =>
      'Zarządzaj informacjami profilowymi';

  @override
  String get settingsPrivacySecurity => 'Prywatność i bezpieczeństwo';

  @override
  String get settingsPrivacySecuritySubtitle =>
      'Zarządzaj ustawieniami prywatności';

  @override
  String get settingsSupportSection => 'Wsparcie';

  @override
  String get settingsHelpFaq => 'Pomoc i FAQ';

  @override
  String get settingsHelpFaqSubtitle => 'Znajdź pomoc i odpowiedzi';

  @override
  String get settingsSendFeedback => 'Wyślij opinię';

  @override
  String get settingsSendFeedbackSubtitle => 'Pomóż nam ulepszyć aplikację';

  @override
  String get settingsLanguageSubtitle => 'Wybierz język aplikacji';

  @override
  String get settingsSubscriptionPortalUnavailable =>
      'Nie udało się otworzyć panelu subskrypcji';

  @override
  String get settingsSubscriptionPortalFailed =>
      'Nie udało się uzyskać dostępu do panelu subskrypcji';

  @override
  String get comingSoon => 'Wkrótce dostępne!';

  @override
  String get subscriptionTitle => 'Przejdź na Premium';

  @override
  String get subscriptionHeaderTitle => 'Odblokuj funkcje Premium';

  @override
  String get subscriptionHeaderTrialSubtitle =>
      'Rozpocznij 7-dniowy okres próbny';

  @override
  String get subscriptionHeaderChoosePlan => 'Wybierz plan';

  @override
  String get subscriptionFeatureUnlimitedScanning =>
      'Nielimitowane skanowanie jedzenia';

  @override
  String get subscriptionFeatureAiAnalysis =>
      'Analiza wartości odżywczych wspierana przez AI';

  @override
  String get subscriptionFeatureMealTracking =>
      'Zaawansowane śledzenie posiłków';

  @override
  String get subscriptionFeatureRecommendations =>
      'Spersonalizowane rekomendacje';

  @override
  String get subscriptionFeatureExportData => 'Eksport danych';

  @override
  String get subscriptionFeaturePrioritySupport => 'Priorytetowe wsparcie';

  @override
  String get subscriptionBestValue => 'NAJLEPSZA OPCJA';

  @override
  String subscriptionJustPricePerMonth(Object price) {
    return 'Tylko $price';
  }

  @override
  String get subscriptionCheckoutFailed => 'Nie udało się rozpocząć zakupu';

  @override
  String get subscriptionOpeningCheckout =>
      'Otwieranie Stripe Checkout... Wróć do aplikacji po zakończeniu zakupu.';

  @override
  String get subscriptionCouldNotOpenCheckout =>
      'Nie udało się otworzyć płatności';

  @override
  String get subscriptionStartFreeTrial => 'Rozpocznij darmowy okres próbny';

  @override
  String get subscriptionSubscribeNow => 'Subskrybuj teraz';

  @override
  String get subscriptionTrialTerms =>
      'Anuluj w dowolnym momencie. Opłata nie zostanie pobrana do końca okresu próbnego.';

  @override
  String get subscriptionPaidTerms =>
      'Anuluj w dowolnym momencie. Rozliczenie miesięczne lub roczne.';

  @override
  String subscriptionCurrentStatus(Object status) {
    return 'Aktualny status: $status';
  }

  @override
  String subscriptionTierLabel(Object tier) {
    return 'Plan: $tier';
  }

  @override
  String subscriptionTrialEnds(Object date) {
    return 'Koniec okresu próbnego: $date';
  }

  @override
  String get subscriptionFreeTrialBadge => '7-dniowy okres próbny';

  @override
  String get subscriptionStatusActive => 'Aktywna';

  @override
  String get subscriptionStatusTrial => 'Okres próbny';

  @override
  String get subscriptionStatusFree => 'Darmowa';

  @override
  String get subscriptionStatusPastDue => 'Zaległa';

  @override
  String get subscriptionStatusCanceled => 'Anulowana';

  @override
  String get subscriptionTierMonthly => 'Miesięczna';

  @override
  String get subscriptionTierYearly => 'Roczna';

  @override
  String subscriptionCancelsInDays(int days, Object tier) {
    return 'Anuluje się za $days dni - $tier';
  }

  @override
  String subscriptionCancelsTomorrow(Object tier) {
    return 'Anuluje się jutro - $tier';
  }

  @override
  String subscriptionCancelsToday(Object tier) {
    return 'Anuluje się dzisiaj - $tier';
  }

  @override
  String subscriptionCancelsOnDate(Object date) {
    return 'Anuluje się $date';
  }

  @override
  String subscriptionTrialDaysRemaining(int days) {
    return 'Okres próbny - pozostało $days dni';
  }

  @override
  String get subscriptionTrialOneDayRemaining =>
      'Okres próbny - pozostał 1 dzień';

  @override
  String subscriptionTrialHoursRemaining(int hours) {
    return 'Okres próbny - pozostało $hours godz.';
  }

  @override
  String subscriptionTrialTier(Object tier) {
    return 'Okres próbny - $tier';
  }

  @override
  String subscriptionStatusWithTier(Object status, Object tier) {
    return '$status - $tier';
  }

  @override
  String get subscriptionUnlockUnlimited => 'Odblokuj nielimitowane funkcje';

  @override
  String get subscriptionStartTrial => 'Rozpocznij 7-dniowy okres próbny';

  @override
  String get exportDataTitle => 'Eksport danych';

  @override
  String get exportDataExportingTitle => 'Eksportowanie danych...';

  @override
  String get exportDataExportingSubtitle => 'To może potrwać chwilę';

  @override
  String get exportSectionDataToExport => 'Dane do eksportu';

  @override
  String get exportSectionDateRange => 'Zakres dat';

  @override
  String get exportSectionFormat => 'Format eksportu';

  @override
  String get exportWeightHistory => 'Historia wagi';

  @override
  String get exportWeightHistorySubtitle => 'Wszystkie dane śledzenia wagi';

  @override
  String get exportMealHistory => 'Historia posiłków';

  @override
  String get exportMealHistorySubtitle => 'Wkrótce - dane śledzenia posiłków';

  @override
  String get exportSelectAllData => 'Wybierz wszystkie dane';

  @override
  String get exportSelectAllDataSubtitle =>
      'Eksportuj wszystkie dostępne dane z konta';

  @override
  String get fromLabel => 'Od';

  @override
  String get toLabel => 'Do';

  @override
  String get selectDate => 'Wybierz datę';

  @override
  String get exportFormatCsvDescription =>
      'Wartości rozdzielone przecinkami, idealne do arkuszy';

  @override
  String get exportFormatJsonDescription =>
      'Strukturalny format danych, idealny dla programistów';

  @override
  String get exportFormatXmlDescription =>
      'Przyjazny dla firm strukturalny format danych';

  @override
  String get exportFormatPdfDescription =>
      'Czytelny raport z wykresami i analizą';

  @override
  String get exportButton => 'Eksportuj dane';

  @override
  String get exportSelectAtLeastOne =>
      'Wybierz co najmniej jeden typ danych do eksportu';

  @override
  String get exportSuccess => 'Dane zostały wyeksportowane!';

  @override
  String exportFailed(Object message) {
    return 'Eksport nie powiódł się: $message';
  }

  @override
  String errorPrefix(Object message) {
    return 'Błąd: $message';
  }

  @override
  String get commonCancel => 'Anuluj';

  @override
  String get commonDelete => 'Usuń';

  @override
  String get commonUpdate => 'Aktualizuj';

  @override
  String get commonRetry => 'Spróbuj ponownie';

  @override
  String get commonClose => 'Zamknij';

  @override
  String get commonSave => 'Zapisz';

  @override
  String get commonSettings => 'Ustawienia';

  @override
  String get commonProfile => 'Profil';

  @override
  String get commonLogout => 'Wyloguj';

  @override
  String get commonCamera => 'Aparat';

  @override
  String get commonGallery => 'Galeria';

  @override
  String get commonCalendar => 'Kalendarz';

  @override
  String get commonPreviousDay => 'Poprzedni dzień';

  @override
  String get commonNextDay => 'Następny dzień';

  @override
  String get commonCalories => 'Kalorie';

  @override
  String get commonProteins => 'Białko';

  @override
  String get commonCarbs => 'Węglowodany';

  @override
  String get commonFats => 'Tłuszcze';

  @override
  String get commonWeight => 'Waga';

  @override
  String get commonAddMeal => 'Dodaj posiłek';

  @override
  String get commonMealName => 'Nazwa posiłku';

  @override
  String get commonMeal => 'Posiłek';

  @override
  String get commonNoPhoto => 'Brak zdjęcia';

  @override
  String get commonNoPhotoAvailable => 'Brak dostępnego zdjęcia';

  @override
  String get commonToday => 'Dzisiaj';

  @override
  String get dashboardCompleteProfileTitle => 'Uzupełnij profil';

  @override
  String get dashboardCompleteProfileDescription =>
      'Aby otrzymywać spersonalizowane cele kalorii i makroskładników, uzupełnij profil podstawowymi informacjami.';

  @override
  String get dashboardSkipForNow => 'Pomiń na razie';

  @override
  String get dashboardCompleteProfileCta => 'Uzupełnij profil';

  @override
  String dashboardAddedMeal(Object mealName) {
    return 'Dodano: $mealName';
  }

  @override
  String dashboardFailedToAddMeal(Object message) {
    return 'Nie udało się dodać posiłku: $message';
  }

  @override
  String dashboardMealDiscarded(Object mealName) {
    return 'Posiłek „$mealName” został odrzucony';
  }

  @override
  String get dashboardMealNameCannotBeEmpty =>
      'Nazwa posiłku nie może być pusta';

  @override
  String get dashboardFinishCurrentEdit => 'Najpierw zakończ bieżącą edycję';

  @override
  String get dashboardEditMessageTitle => 'Edytuj wiadomość';

  @override
  String get dashboardEditMealNotice =>
      'To zaktualizuje posiłek i dzienne sumy odżywcze';

  @override
  String get dashboardEditMealConfirm =>
      'To zaktualizuje posiłek i dzienne sumy odżywcze. Kontynuować?';

  @override
  String get dashboardEnterFoodDescription => 'Wpisz opis jedzenia';

  @override
  String get dashboardMessageCannotBeEmpty => 'Wiadomość nie może być pusta';

  @override
  String dashboardFailedToEditMessage(Object message) {
    return 'Nie udało się edytować wiadomości: $message';
  }

  @override
  String get dashboardMessageUpdated => 'Wiadomość została zaktualizowana';

  @override
  String get dashboardMealUpdated => 'Posiłek został zaktualizowany';

  @override
  String get dashboardTypeAnswerPrompt =>
      'Wpisz odpowiedź na czacie poniżej i wyślij ją.';

  @override
  String get dashboardChatEmptyTitle => 'Zacznij śledzić swoje jedzenie!';

  @override
  String get dashboardChatEmptySubtitle =>
      'Opisz co zjadłeś lub nagraj audio.\nNasze AI przeanalizuje wartości odżywcze za Ciebie.';

  @override
  String get dashboardDailyNutrition => 'Dzienne wartości odżywcze';

  @override
  String get dashboardPersonalized => 'Spersonalizowane';

  @override
  String dashboardGoal(Object goal) {
    return 'Cel: $goal';
  }

  @override
  String dashboardNutritionCaloriesLabel(Object current, Object target) {
    return '$current kcal / $target kcal';
  }

  @override
  String dashboardNutritionProteinLabel(Object current, Object target) {
    return '${current}g / ${target}g białka';
  }

  @override
  String dashboardNutritionCarbsLabel(Object current, Object target) {
    return '${current}g / ${target}g węglowodanów';
  }

  @override
  String dashboardNutritionFatLabel(Object current, Object target) {
    return '${current}g / ${target}g tłuszczu';
  }

  @override
  String dashboardAmountLeft(Object amount, Object unit) {
    return 'Pozostało $amount$unit';
  }

  @override
  String dashboardAmountOver(Object amount, Object unit) {
    return 'Przekroczono o $amount$unit';
  }

  @override
  String dashboardPercentOfTarget(Object percent) {
    return '$percent% celu';
  }

  @override
  String get dashboardNoMealsAddedToday => 'Nie dodano dziś żadnych posiłków';

  @override
  String get dashboardTapPlusToAddMeal =>
      'Kliknij +, aby dodać pierwszy posiłek';

  @override
  String get dashboardDiscardMealTitle => 'Odrzuć posiłek';

  @override
  String get dashboardDiscardMealPrompt =>
      'Wpisz nazwę dla odrzuconego posiłku:';

  @override
  String get dashboardMealNameHint => 'np. Pizza';

  @override
  String get dashboardDiscard => 'Odrzuć';

  @override
  String get chatEdited => 'edytowano';

  @override
  String get chatImage => 'Obraz';

  @override
  String get chatAudioMessage => 'Wiadomość audio';

  @override
  String get chatProvisionalAnalysis => 'Wstępna analiza';

  @override
  String get chatAiAnalysis => 'Analiza AI';

  @override
  String get chatNeedsClarification => 'WYMAGA DOPRECYZOWANIA';

  @override
  String get chatAnswerThisQuestion => 'Odpowiedz na to pytanie';

  @override
  String get chatAddToTodaysMeals => 'Dodaj do dzisiejszych posiłków';

  @override
  String chatDiscardedMeal(Object mealName) {
    return 'Odrzucono: $mealName';
  }

  @override
  String chatAddedMeal(Object mealName) {
    return 'Dodano: $mealName';
  }

  @override
  String chatDeletedMeal(Object mealName) {
    return 'Usunięto: $mealName';
  }

  @override
  String get chatDeleteMealTitle => 'Usunąć posiłek?';

  @override
  String chatDeleteMealPrompt(Object mealName) {
    return 'To usunie „$mealName” z dziennika posiłków.';
  }

  @override
  String get chatMealDeleted => 'Posiłek usunięty';

  @override
  String chatFailedToDeleteMeal(Object message) {
    return 'Nie udało się usunąć: $message';
  }

  @override
  String get chatNutritionFound => 'Znalezione wartości odżywcze:';

  @override
  String get chatMacroProtein => 'białko';

  @override
  String get chatMacroCarbs => 'węglowodany';

  @override
  String get chatMacroFat => 'tłuszcz';

  @override
  String chatMacroSummary(
      Object calories, Object protein, Object carbs, Object fats) {
    return '$calories kcal • ${protein}g białka • ${carbs}g węglowodanów • ${fats}g tłuszczu';
  }

  @override
  String get chatInputSendPhoto => 'Wyślij zdjęcie';

  @override
  String chatInputFailedToPickImage(Object message) {
    return 'Nie udało się wybrać zdjęcia: $message';
  }

  @override
  String get chatInputAudioUnavailable =>
      'Nagrywanie audio jest tymczasowo niedostępne';

  @override
  String get chatInputAudioUnavailableTooltip => 'Nagrywanie audio niedostępne';

  @override
  String get chatInputSendPhotoTooltip => 'Wyślij zdjęcie do analizy';

  @override
  String get chatInputDescribeFood => 'Opisz swoje jedzenie...';

  @override
  String get chatInputSend => 'Wyślij';

  @override
  String subscriptionBannerDaysLeft(int days) {
    return 'Pozostało $days dni darmowego okresu próbnego';
  }

  @override
  String subscriptionBannerDaysLeftUrgent(int days) {
    return 'Pozostało tylko $days dni darmowego okresu próbnego!';
  }

  @override
  String subscriptionBannerHoursLeft(int hours) {
    return 'Pozostało tylko $hours godz. darmowego okresu próbnego!';
  }

  @override
  String get subscriptionBannerSubscribeUnlimited =>
      'Subskrybuj, aby zachować nielimitowany dostęp';

  @override
  String get subscriptionBannerSubscribe => 'Subskrybuj';

  @override
  String get subscriptionBannerTryFree => 'Wypróbuj za darmo';

  @override
  String get subscriptionBannerUpgrade => 'Ulepsz';

  @override
  String get subscriptionBannerPaymentFailed => 'Płatność nieudana';

  @override
  String get subscriptionBannerUpdatePaymentMethod =>
      'Zaktualizuj metodę płatności';

  @override
  String get calendarExitToMainMenu => 'Wyjdź do menu głównego';

  @override
  String calendarErrorLoadingMeals(Object message) {
    return 'Błąd ładowania posiłków: $message';
  }

  @override
  String get calendarCaloriesChartLast30Days =>
      'Wykres kalorii (ostatnie 30 dni)';

  @override
  String get dayMealsNoMealsLogged => 'Brak zapisanych posiłków tego dnia';

  @override
  String get dayMealsDailySummary => 'Podsumowanie dnia';

  @override
  String get dayMealsMeals => 'Posiłki';

  @override
  String dayMealsErrorLoadingMeals(Object message) {
    return 'Błąd ładowania posiłków: $message';
  }

  @override
  String get barcodeScanTitle => 'Skanuj kod kreskowy';

  @override
  String get barcodeScanInstructions =>
      'Ustaw kod kreskowy w ramce, aby go zeskanować';

  @override
  String get mealDetailUpdatingMeal => 'Aktualizowanie posiłku...';

  @override
  String get mealDetailUpdated => 'Posiłek został zaktualizowany!';

  @override
  String mealDetailFailedToUpdate(Object message) {
    return 'Nie udało się zaktualizować posiłku: $message';
  }

  @override
  String get mealDetailDeleteTitle => 'Usuń posiłek';

  @override
  String get mealDetailDeletePrompt =>
      'Czy na pewno chcesz usunąć ten posiłek? Tej operacji nie można cofnąć.';

  @override
  String get mealDetailDeletingMeal => 'Usuwanie posiłku...';

  @override
  String get mealDetailDeleted => 'Posiłek został usunięty!';

  @override
  String mealDetailFailedToDelete(Object message) {
    return 'Nie udało się usunąć posiłku: $message';
  }

  @override
  String get mealDetailEditMeal => 'Edytuj posiłek';

  @override
  String get mealDetailTitle => 'Szczegóły posiłku';

  @override
  String get mealDetailPhoto => 'Zdjęcie';

  @override
  String get mealDetailMealInformation => 'Informacje o posiłku';

  @override
  String get mealDetailNutritionInformation =>
      'Informacje o wartościach odżywczych';

  @override
  String get mealDetailName => 'Nazwa';

  @override
  String get mealDetailDate => 'Data';

  @override
  String get mealDetailCreated => 'Utworzono';

  @override
  String mealDetailCreatedAt(Object date, Object time) {
    return '$date o $time';
  }

  @override
  String get validationEnterMealName => 'Wpisz nazwę posiłku';

  @override
  String get validationEnterCalories => 'Wpisz kalorie';

  @override
  String get validationEnterValidNumber => 'Wpisz poprawną liczbę';

  @override
  String get validationCaloriesNonNegative => 'Kalorie nie mogą być ujemne';

  @override
  String get validationEnterProteins => 'Wpisz białko';

  @override
  String get validationProteinsNonNegative => 'Białko nie może być ujemne';

  @override
  String get validationEnterFats => 'Wpisz tłuszcze';

  @override
  String get validationFatsNonNegative => 'Tłuszcze nie mogą być ujemne';

  @override
  String get validationEnterCarbs => 'Wpisz węglowodany';

  @override
  String get validationCarbsNonNegative => 'Węglowodany nie mogą być ujemne';

  @override
  String get addMealLookupProduct => 'Wyszukiwanie produktu...';

  @override
  String addMealProductFound(Object name) {
    return 'Znaleziono produkt: $name';
  }

  @override
  String addMealUnknownProduct(Object barcode) {
    return 'Nieznany produkt ($barcode)';
  }

  @override
  String get addMealProductNotFoundManual =>
      'Nie znaleziono produktu w bazie. Możesz wprowadzić wartości odżywcze ręcznie.';

  @override
  String addMealFailedToScanBarcode(Object message) {
    return 'Nie udało się zeskanować kodu kreskowego: $message';
  }

  @override
  String addMealTitle(Object date) {
    return 'Dodaj posiłek - $date';
  }

  @override
  String addMealFailedToPickImage(Object message) {
    return 'Nie udało się wybrać zdjęcia: $message';
  }

  @override
  String addMealAnalysisFailed(Object message) {
    return 'Analiza nie powiodła się: $message';
  }

  @override
  String get addMealFilledFromPhotoAnalysis =>
      'Wartości odżywcze zostały uzupełnione na podstawie analizy zdjęcia!';

  @override
  String get addMealAcceptedBarcodeNutrition =>
      'Wartości odżywcze produktu zostały zaakceptowane i uzupełnione.';

  @override
  String get addMealAddedSuccessfully => 'Posiłek został dodany!';

  @override
  String addMealFailedToAdd(Object message) {
    return 'Nie udało się dodać posiłku: $message';
  }

  @override
  String get addMealAnalyzing => 'Analizowanie...';

  @override
  String get addMealChangePhoto => 'Zmień zdjęcie';

  @override
  String get addMealPhoto => 'Dodaj zdjęcie';

  @override
  String get addMealAnalyzeWithAi => 'Analizuj z AI';

  @override
  String get addMealScanning => 'Skanowanie...';

  @override
  String get addMealScanBarcode => 'Skanuj kod kreskowy';

  @override
  String get addMealAdding => 'Dodawanie...';

  @override
  String get addMealSubmit => 'Zatwierdź';

  @override
  String get addMealAssumptions => 'Założenia:';

  @override
  String get addMealItems => 'Składniki:';

  @override
  String get addMealYourAnswer => 'Twoja odpowiedź...';

  @override
  String get addMealUseCurrentEstimate => 'Użyj obecnego oszacowania';

  @override
  String get addMealPleaseEnterAnswer => 'Wpisz odpowiedź';

  @override
  String get addMealRefineEstimate => 'Doprecyzuj oszacowanie';

  @override
  String get addMealAcceptFillValues => 'Zaakceptuj i uzupełnij wartości';

  @override
  String get addMealProductFoundLabel => 'Znaleziony produkt:';

  @override
  String get addMealBarcodeScannedLabel => 'Zeskanowany kod kreskowy:';

  @override
  String addMealBarcodeLabel(Object barcode) {
    return 'Kod kreskowy: $barcode';
  }

  @override
  String get addMealNutritionPer100g => 'Wartości odżywcze na 100 g:';

  @override
  String get addMealAcceptFillNutritionValues =>
      'Zaakceptuj i uzupełnij wartości odżywcze';

  @override
  String get addMealProductNotFoundOpenFoodFacts =>
      'Nie znaleziono produktu w bazie OpenFoodFacts.\nMożesz wprowadzić wartości odżywcze ręcznie.';

  @override
  String get addMealConfidenceHigh => 'WYSOKA';

  @override
  String get addMealConfidenceMedium => 'ŚREDNIA';

  @override
  String get addMealConfidenceLow => 'NISKA';

  @override
  String get profileTitle => 'Twój profil';

  @override
  String get profilePersonalInformation => 'Dane osobowe';

  @override
  String get profileFullName => 'Imię i nazwisko';

  @override
  String get profileEnterName => 'Wpisz swoje imię i nazwisko';

  @override
  String get profileGender => 'Płeć';

  @override
  String get profileSelectGender => 'Wybierz płeć';

  @override
  String get profileGenderMale => 'Mężczyzna';

  @override
  String get profileGenderFemale => 'Kobieta';

  @override
  String get profileDateOfBirth => 'Data urodzenia';

  @override
  String get profileSelectDateOfBirth => 'Wybierz datę urodzenia';

  @override
  String get profilePleaseSelectDateOfBirth => 'Wybierz datę urodzenia';

  @override
  String get profileInvalidDateOfBirth => 'Podaj prawidłową datę urodzenia';

  @override
  String get profilePhysicalCharacteristics => 'Parametry fizyczne';

  @override
  String get profileHeight => 'Wzrost';

  @override
  String get profileHeightCm => 'Wzrost (cm)';

  @override
  String get profileEnterHeight => 'Wpisz swój wzrost';

  @override
  String get profileInvalidHeight => 'Podaj prawidłowy wzrost (100-250 cm)';

  @override
  String get profileCurrentWeight => 'Aktualna waga';

  @override
  String get profileCurrentWeightKg => 'Aktualna waga (kg)';

  @override
  String get profileEnterCurrentWeight => 'Wpisz aktualną wagę';

  @override
  String get profileInvalidCurrentWeight => 'Podaj prawidłową wagę (30-300 kg)';

  @override
  String get profileTargetWeight => 'Waga docelowa';

  @override
  String get profileTargetWeightOptional => 'Waga docelowa (kg) - opcjonalnie';

  @override
  String get profileInvalidTargetWeight =>
      'Podaj prawidłową wagę docelową (30-300 kg)';

  @override
  String get profileGoalsTargets => 'Cele i założenia';

  @override
  String get profilePrimaryGoal => 'Główny cel';

  @override
  String get profileGoalMaintaining => 'Utrzymanie wagi';

  @override
  String get profileGoalWeightLoss => 'Redukcja masy';

  @override
  String get profileGoalWeightGain => 'Przyrost masy';

  @override
  String get profileGoalHypertrophy => 'Hipertrofia';

  @override
  String get profileWeeklyTarget => 'Cel tygodniowy';

  @override
  String get profileWeeklyWeightLossTarget => 'Tygodniowy cel redukcji (kg)';

  @override
  String get profileWeeklyWeightGainTarget => 'Tygodniowy cel przyrostu (kg)';

  @override
  String get profileWeeklyTargetHelper =>
      'Zalecane: 0,5-1,0 kg/tydzień dla zrównoważonych rezultatów';

  @override
  String get profileEnterWeeklyTarget => 'Wpisz cel tygodniowy';

  @override
  String get profileInvalidWeeklyTarget =>
      'Podaj prawidłowy cel (0,1-2,0 kg/tydzień)';

  @override
  String get profileActivityLevel => 'Poziom aktywności';

  @override
  String profilePalValue(Object value) {
    return 'PAL: $value';
  }

  @override
  String get profileActivitySedentary => 'Siedzący tryb życia';

  @override
  String get profileActivityLightlyActive => 'Lekko aktywny';

  @override
  String get profileActivityModeratelyActive => 'Umiarkowanie aktywny';

  @override
  String get profileActivityVeryActive => 'Bardzo aktywny';

  @override
  String get profileActivityExtremelyActive => 'Ekstremalnie aktywny';

  @override
  String get profileSubscription => 'Subskrypcja';

  @override
  String get profileStatus => 'Status';

  @override
  String get profilePlan => 'Plan';

  @override
  String get profileMonthly => 'Miesięczny';

  @override
  String get profileYearly => 'Roczny';

  @override
  String get profileFree => 'Darmowy';

  @override
  String get profileFreeTier => 'Plan darmowy';

  @override
  String get profileLimitedFeatures => 'Ograniczone funkcje';

  @override
  String get profileTrial => 'Okres próbny';

  @override
  String get profilePremium => 'Premium';

  @override
  String get profilePastDue => 'Zaległość';

  @override
  String get profileCanceled => 'Anulowana';

  @override
  String get profileTrialEnds => 'Koniec okresu próbnego';

  @override
  String get profileNextPayment => 'Następna płatność';

  @override
  String get profileRenewalDate => 'Data odnowienia';

  @override
  String get profileNotAvailable => 'Brak';

  @override
  String get profileExpired => 'Wygasła';

  @override
  String profileInMonths(Object count, Object plural) {
    return 'za $count mies.$plural';
  }

  @override
  String profileInDays(Object count, Object plural) {
    return 'za $count dzień$plural';
  }

  @override
  String profileInHours(Object count, Object plural) {
    return 'za $count godz.$plural';
  }

  @override
  String get profileLessThanHour => 'Mniej niż 1 godzina';

  @override
  String get profileUpgradeToPremium => 'Przejdź na Premium';

  @override
  String profileLoadingError(Object error) {
    return 'Nie udało się załadować profilu: $error';
  }

  @override
  String get profileSaved => 'Profil został zapisany!';

  @override
  String profileSavingError(Object error) {
    return 'Nie udało się zapisać profilu: $error';
  }

  @override
  String get profileSave => 'Zapisz profil';

  @override
  String get weightTrackingTitle => 'Śledzenie wagi';

  @override
  String weightTrackingLoadingError(Object error) {
    return 'Nie udało się załadować danych: $error';
  }

  @override
  String get weightTrackingEnterWeight => 'Wpisz swoją wagę';

  @override
  String get weightTrackingInvalidWeight => 'Podaj prawidłową wagę (1-300 kg)';

  @override
  String get weightTrackingAdded => 'Wpis wagi został dodany!';

  @override
  String weightTrackingAddError(Object error) {
    return 'Nie udało się dodać wpisu wagi: $error';
  }

  @override
  String get weightTrackingNeedMoreData =>
      'Do analizy potrzebne są co najmniej 2 wpisy wagi i kompletny profil';

  @override
  String get weightTrackingProgressAnalysis => 'Analiza postępów';

  @override
  String get weightTrackingActualWeightChange => 'Rzeczywista zmiana wagi';

  @override
  String get weightTrackingExpectedWeightChange => 'Oczekiwana zmiana wagi';

  @override
  String get weightTrackingProgress => 'Postęp';

  @override
  String get weightTrackingWeeklyActual => 'Rzeczywiście tygodniowo';

  @override
  String get weightTrackingWeeklyExpected => 'Oczekiwane tygodniowo';

  @override
  String weightTrackingStatus(Object status) {
    return 'Status: $status';
  }

  @override
  String get weightTrackingUnableToAnalyze =>
      'Nie udało się przeanalizować postępów';

  @override
  String get weightTrackingDeleteTitle => 'Usuń wpis wagi';

  @override
  String weightTrackingDeletePrompt(Object date) {
    return 'Czy na pewno chcesz usunąć wpis wagi z dnia $date?';
  }

  @override
  String get weightTrackingDeleteInvalidId =>
      'Nie można usunąć wpisu: nieprawidłowe ID';

  @override
  String get weightTrackingDeleted => 'Wpis wagi został usunięty';

  @override
  String weightTrackingDeleteError(Object error) {
    return 'Nie udało się usunąć wpisu wagi: $error';
  }

  @override
  String get weightTrackingStatusExceeding => 'Powyżej celu';

  @override
  String get weightTrackingStatusOnTrack => 'Zgodnie z planem';

  @override
  String get weightTrackingStatusSlowProgress => 'Powolny postęp';

  @override
  String get weightTrackingStatusMinimalProgress => 'Minimalny postęp';

  @override
  String get weightTrackingStatusUnknown => 'Nieznany';

  @override
  String get weightTrackingChartTitle => 'Wykres wagi';

  @override
  String get weightTrackingChartEmpty =>
      'Dodaj wpisy wagi, aby zobaczyć wykres postępów';

  @override
  String get weightTrackingProgressTitle => 'Postęp wagi';

  @override
  String get weightTrackingAnalysisEmpty =>
      'Dodaj co najmniej 2 wpisy wagi, aby zobaczyć analizę postępów';

  @override
  String get weightTrackingUnknownError => 'Nieznany błąd';

  @override
  String get weightTrackingAddEntry => 'Dodaj wpis wagi';

  @override
  String get weightTrackingWeightKg => 'Waga (kg)';

  @override
  String get weightTrackingWeightHint => 'np. 70,5 lub 70.5';

  @override
  String get weightTrackingDate => 'Data';

  @override
  String get weightTrackingMeasurementTime => 'Pora pomiaru';

  @override
  String get weightTrackingMorning => 'Rano';

  @override
  String get weightTrackingAfternoon => 'Po południu';

  @override
  String get weightTrackingEvening => 'Wieczorem';

  @override
  String get weightTrackingNotesOptional => 'Notatki (opcjonalnie)';

  @override
  String get weightTrackingNotesHint => 'np. po treningu, przed śniadaniem';

  @override
  String get weightTrackingHistory => 'Historia wagi';

  @override
  String get weightTrackingNoEntries => 'Brak wpisów wagi';

  @override
  String get weightTrackingNoEntriesSubtitle =>
      'Dodaj pierwszy wpis powyżej, aby zacząć śledzić postępy';

  @override
  String get weightTrackingDeleteEntry => 'Usuń wpis';

  @override
  String get weightTrackingInitialPhase => 'Faza początkowa';

  @override
  String get dashboardAnalysisFoodSuccess =>
      'Analiza jedzenia zakończona powodzeniem';

  @override
  String dashboardAnalysisFoodFailed(Object error) {
    return 'Nie udało się przeanalizować jedzenia: $error';
  }

  @override
  String get dashboardAnalysisAudioSuccess =>
      'Jedzenie zostało przeanalizowane z nagrania audio';

  @override
  String dashboardAnalysisAudioFailed(Object error) {
    return 'Nie udało się przeanalizować audio: $error';
  }

  @override
  String get dashboardAnalysisImageSuccess =>
      'Jedzenie zostało przeanalizowane ze zdjęcia';

  @override
  String dashboardAnalysisImageFailed(Object error) {
    return 'Nie udało się przeanalizować zdjęcia: $error';
  }

  @override
  String get dashboardAnalysisRefinedSuccess =>
      'Analiza jedzenia została doprecyzowana';

  @override
  String dashboardAnalysisRefinedFailed(Object error) {
    return 'Nie udało się doprecyzować analizy: $error';
  }

  @override
  String get dashboardUpdatedMealFallback => 'Zaktualizowany posiłek';
}
