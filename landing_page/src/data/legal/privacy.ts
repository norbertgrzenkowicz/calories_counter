import type { Locale } from "../site";

type LegalSection = {
  heading: string;
  body: string;
};

type PrivacyContent = {
  eyebrow: string;
  title: string;
  description: string;
  updatedAt: string;
  intro: string;
  sections: LegalSection[];
};

const privacyContent: Record<Locale, PrivacyContent> = {
  en: {
    eyebrow: "Legal",
    title: "Privacy Policy",
    description: "Privacy details for the Yapper landing site and app entry point.",
    updatedAt: "March 22, 2026",
    intro:
      "This placeholder policy is structured for a production privacy page. Replace it with your final legal text before launch.",
    sections: [
      {
        heading: "Information We Collect",
        body:
          "Yapper may collect account information, nutrition log entries, barcode scans, uploaded meal photos, subscription records, and support messages needed to operate the service."
      },
      {
        heading: "How We Use Information",
        body:
          "Data is used to authenticate users, process meal logging workflows, improve product performance, support subscriptions, and provide customer support."
      },
      {
        heading: "Sharing and Retention",
        body:
          "Yapper should only share data with service providers required to operate the app and should retain information only as long as needed for product, legal, and security purposes."
      }
    ]
  },
  pl: {
    eyebrow: "Informacje prawne",
    title: "Polityka prywatności",
    description: "Informacje o prywatności dla strony landingowej i aplikacji Yapper.",
    updatedAt: "22 marca 2026",
    intro:
      "To robocza wersja strony polityki prywatności. Przed publikacją podmień ją na finalny, sprawdzony tekst prawny.",
    sections: [
      {
        heading: "Jakie dane możemy zbierać",
        body:
          "Yapper może zbierać dane konta, wpisy dotyczące posiłków, skany kodów kreskowych, zdjęcia posiłków, informacje o subskrypcji oraz wiadomości do wsparcia potrzebne do działania usługi."
      },
      {
        heading: "Jak wykorzystujemy dane",
        body:
          "Dane służą do uwierzytelniania użytkowników, obsługi logowania posiłków, poprawy działania produktu, obsługi subskrypcji i zapewnienia wsparcia."
      },
      {
        heading: "Udostępnianie i przechowywanie danych",
        body:
          "Yapper powinien udostępniać dane wyłącznie podmiotom potrzebnym do działania aplikacji i przechowywać je tylko tak długo, jak wymaga tego produkt, bezpieczeństwo i obowiązki prawne."
      }
    ]
  }
};

export function getPrivacyContent(locale: Locale) {
  return privacyContent[locale];
}
