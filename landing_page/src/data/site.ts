export const SUPPORTED_LOCALES = ["en", "pl"] as const;

export type Locale = (typeof SUPPORTED_LOCALES)[number];
export type RouteKey = "home" | "privacy" | "terms" | "contact";

export type LocaleSiteCopy = {
  lang: string;
  localeLabel: string;
  languageSwitcherLabel: string;
  title: string;
  description: string;
  footerTagline: string;
  headerCtaLabel: string;
  footerNav: {
    privacy: string;
    terms: string;
    contact: string;
  };
  legalLabel: string;
  contactLabel: string;
  updatedLabel: string;
  navAriaLabel: string;
  footerAriaLabel: string;
  localeNavAriaLabel: string;
  redirectMessage: string;
  redirectCtaLabel: string;
};

export const DEFAULT_LOCALE: Locale = "en";

export const siteConfig = {
  name: "Yapper",
  url: "https://yapper.app",
  appStoreUrl: "#",
  contactEmail: "hello@yapper.app",
  contactHref: "mailto:hello@yapper.app",
  partnerEmail: "partners@yapper.app",
  partnerHref: "mailto:partners@yapper.app",
  ogImagePath: "/og-cover.svg"
} as const;

export const siteCopy: Record<Locale, LocaleSiteCopy> = {
  en: {
    lang: "en",
    localeLabel: "English",
    languageSwitcherLabel: "Language",
    title: "Yapper | Snap a Meal. Know Your Macros.",
    description:
      "AI-powered food tracking for iOS. Log meals by photo, voice, text, or barcode without wrestling with bloated calorie apps.",
    footerTagline: "Built with AI for humans who eat food.",
    headerCtaLabel: "Download Free",
    footerNav: {
      privacy: "Privacy",
      terms: "Terms",
      contact: "Contact"
    },
    legalLabel: "Legal",
    contactLabel: "Contact",
    updatedLabel: "Updated",
    navAriaLabel: "Primary",
    footerAriaLabel: "Footer",
    localeNavAriaLabel: "Language switcher",
    redirectMessage: "Redirecting to the English site.",
    redirectCtaLabel: "Continue to English"
  },
  pl: {
    lang: "pl",
    localeLabel: "Polski",
    languageSwitcherLabel: "Język",
    title: "Yapper | Zrób zdjęcie. Ogarnij makro.",
    description:
      "Aplikacja AI do liczenia jedzenia na iOS. Dodawaj posiłki zdjęciem, głosem, tekstem albo kodem kreskowym, bez przeklikiwania się przez przeładowane tabelki.",
    footerTagline: "Zbudowane z AI dla ludzi, którzy po prostu jedzą.",
    headerCtaLabel: "Pobierz za darmo",
    footerNav: {
      privacy: "Prywatność",
      terms: "Regulamin",
      contact: "Kontakt"
    },
    legalLabel: "Informacje prawne",
    contactLabel: "Kontakt",
    updatedLabel: "Aktualizacja",
    navAriaLabel: "Nawigacja główna",
    footerAriaLabel: "Stopka",
    localeNavAriaLabel: "Przełącznik języka",
    redirectMessage: "Przekierowujemy do angielskiej wersji strony.",
    redirectCtaLabel: "Przejdź do wersji angielskiej"
  }
};

export function getSiteCopy(locale: Locale) {
  return siteCopy[locale];
}
