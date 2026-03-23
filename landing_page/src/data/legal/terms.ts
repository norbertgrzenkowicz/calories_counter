import type { Locale } from "../site";

type LegalSection = {
  heading: string;
  body: string;
};

type TermsContent = {
  eyebrow: string;
  title: string;
  description: string;
  updatedAt: string;
  intro: string;
  sections: LegalSection[];
};

const termsContent: Record<Locale, TermsContent> = {
  en: {
    eyebrow: "Legal",
    title: "Terms of Service",
    description: "Terms of Service for Yapper's marketing site and app access.",
    updatedAt: "March 22, 2026",
    intro:
      "This placeholder page defines the structure for final Terms of Service. Replace the copy with reviewed legal text before public release.",
    sections: [
      {
        heading: "Use of the Service",
        body:
          "Users may access Yapper for personal food tracking and nutrition logging subject to product availability, subscription status, and applicable law."
      },
      {
        heading: "Subscriptions and Billing",
        body:
          "Paid plans should describe billing cadence, renewal terms, cancellation options, and any platform-specific purchase handling."
      },
      {
        heading: "Disclaimers",
        body:
          "Nutrition estimates and AI outputs should not be represented as medical advice. Users remain responsible for health decisions and verifying important information."
      }
    ]
  },
  pl: {
    eyebrow: "Informacje prawne",
    title: "Regulamin",
    description: "Regulamin korzystania ze strony i aplikacji Yapper.",
    updatedAt: "22 marca 2026",
    intro:
      "To robocza wersja regulaminu przygotowana jako miejsce na finalny tekst prawny. Przed publikacją uzupełnij ją zatwierdzoną treścią.",
    sections: [
      {
        heading: "Korzystanie z usługi",
        body:
          "Z Yappera można korzystać do osobistego śledzenia posiłków i żywienia, z uwzględnieniem dostępności produktu, statusu subskrypcji i obowiązujących przepisów."
      },
      {
        heading: "Subskrypcje i rozliczenia",
        body:
          "Płatne plany powinny jasno opisywać okres rozliczeniowy, zasady odnowienia, sposób anulowania oraz obsługę zakupów zależną od platformy."
      },
      {
        heading: "Zastrzeżenia",
        body:
          "Szacunki żywieniowe i odpowiedzi AI nie stanowią porady medycznej. Użytkownik odpowiada za decyzje zdrowotne i weryfikację istotnych informacji."
      }
    ]
  }
};

export function getTermsContent(locale: Locale) {
  return termsContent[locale];
}
