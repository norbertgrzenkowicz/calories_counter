import type { Locale } from "./site";

export type NavItem = {
  href: string;
  label: string;
};

export type Metric = {
  label: string;
  value: string;
};

export type Problem = {
  title: string;
  body: string;
  icon: "search" | "timer" | "layers";
};

export type Step = {
  number: string;
  title: string;
  body: string;
  icon: "camera" | "brain" | "spark";
};

export type Feature = {
  title: string;
  body: string;
  eyebrow: string;
  icon: "camera" | "barcode" | "voice" | "chart";
};

export type Plan = {
  name: string;
  price: string;
  cadence: string;
  badge?: string;
  emphasis?: "standard" | "highlight";
  features: string[];
  cta: string;
  note: string;
};

export type LandingContent = {
  navItems: NavItem[];
  hero: {
    eyebrow: string;
    title: string;
    description: string;
    primaryCta: {
      href: string;
      label: string;
    };
    secondaryCta: {
      href: string;
      label: string;
    };
    proof: string;
    topLineLabel: string;
    metrics: Metric[];
  };
  problemSection: {
    label: string;
    title: string;
    items: Problem[];
  };
  howItWorksSection: {
    label: string;
    title: string;
    steps: Step[];
  };
  featuresSection: {
    label: string;
    title: string;
    items: Feature[];
  };
  pricingSection: {
    label: string;
    title: string;
    plans: Plan[];
    footnote: string;
  };
  finalCta: {
    title: string;
    body: string;
    href: string;
    label: string;
  };
};

const landingContent: Record<Locale, LandingContent> = {
  en: {
    navItems: [
      { href: "#features", label: "Features" },
      { href: "#how-it-works", label: "How It Works" },
      { href: "#pricing", label: "Pricing" }
    ],
    hero: {
      eyebrow: "AI Food Tracking for iOS",
      title: "Snap a Meal. Know Your Macros.",
      description:
        "Yapper reads your food from a photo in seconds, then backs it up with voice, text, and barcode logging when life gets messy.",
      primaryCta: {
        href: "#",
        label: "Download on App Store"
      },
      secondaryCta: {
        href: "#how-it-works",
        label: "See How It Works"
      },
      proof: "★★★★★ 4.8 · Used by 2,400+ users · Free to start",
      topLineLabel: "Today",
      metrics: [
        { label: "Kcal left", value: "1,420" },
        { label: "Protein", value: "82 / 150g" },
        { label: "Carbs", value: "128 / 210g" },
        { label: "Fat", value: "41 / 70g" }
      ]
    },
    problemSection: {
      label: "The Problem",
      title: "Logging should not feel like admin.",
      items: [
        {
          icon: "search",
          title: "Searching databases kills motivation",
          body: "Endless variants and weak search make calorie tracking feel like data entry instead of progress."
        },
        {
          icon: "timer",
          title: "Manual logging steals your time",
          body: "Typing every meal adds up fast, especially when all you want is a quick answer after you eat."
        },
        {
          icon: "layers",
          title: "Most apps are bloated by default",
          body: "Feeds, ads, and overbuilt dashboards get in the way. Yapper stays focused on the only job that matters."
        }
      ]
    },
    howItWorksSection: {
      label: "How Yapper Works",
      title: "Zero to logged in three beats.",
      steps: [
        {
          number: "01",
          icon: "camera",
          title: "Take a photo of your food",
          body: "Capture the meal as it is, with no need to pre-select ingredients or serving sizes."
        },
        {
          number: "02",
          icon: "brain",
          title: "AI identifies ingredients and portions",
          body: "Yapper turns the image into structured nutrition data and keeps the interaction short."
        },
        {
          number: "03",
          icon: "spark",
          title: "Calories and macros log instantly",
          body: "Your day updates immediately so the rest of the app feels like review, not admin work."
        }
      ]
    },
    featuresSection: {
      label: "Capabilities",
      title: "Purpose-built tools for fast logging.",
      items: [
        {
          eyebrow: "Vision",
          icon: "camera",
          title: "Photo Analysis",
          body: "Use AI-assisted image analysis to estimate what is on the plate without database hunting."
        },
        {
          eyebrow: "Barcode",
          icon: "barcode",
          title: "Barcode Scanner",
          body: "Handle packaged foods fast with scan-based lookup when the meal is not homemade."
        },
        {
          eyebrow: "Natural Input",
          icon: "voice",
          title: "Voice & Text Logging",
          body: "Type or say what you ate naturally and let Yapper do the parsing in the background."
        },
        {
          eyebrow: "Progress",
          icon: "chart",
          title: "Weight Trends",
          body: "Track body weight and nutrition history in a cleaner interface built around signal instead of clutter."
        }
      ]
    },
    pricingSection: {
      label: "Simple Pricing",
      title: "Invest in accuracy, not subscription fatigue.",
      footnote: "No credit card required to start.",
      plans: [
        {
          name: "Free",
          price: "Forever free",
          cadence: "",
          note: "Start without a card.",
          emphasis: "standard",
          cta: "Get Started",
          features: [
            "Photo logging",
            "Manual entry",
            "Basic history",
            "Weight tracking"
          ]
        },
        {
          name: "Pro",
          price: "$2.49",
          cadence: "/month or $29.99/year",
          note: "Most value for active tracking.",
          badge: "Most Popular",
          emphasis: "highlight",
          cta: "Go Pro",
          features: [
            "Full AI analysis",
            "Barcode scanning",
            "Voice and text logging",
            "Data exports",
            "Priority support"
          ]
        }
      ]
    },
    finalCta: {
      title: "Track smarter. Eat better.",
      body: "Join thousands who ditched the database and made food logging feel fast again.",
      href: "#",
      label: "Download Free on iOS"
    }
  },
  pl: {
    navItems: [
      { href: "#features", label: "Funkcje" },
      { href: "#how-it-works", label: "Jak to działa" },
      { href: "#pricing", label: "Cennik" }
    ],
    hero: {
      eyebrow: "AI do liczenia jedzenia na iOS",
      title: "Zrób zdjęcie. Ogarnij makro.",
      description:
        "Yapper rozpoznaje, co masz na talerzu w kilka sekund, a gdy trzeba, pozwala dodać posiłek głosem, tekstem albo skanem kodu kreskowego.",
      primaryCta: {
        href: "#",
        label: "Pobierz w App Store"
      },
      secondaryCta: {
        href: "#how-it-works",
        label: "Zobacz, jak to działa"
      },
      proof: "★★★★★ 4.8 · Ponad 2 400 użytkowników · Zacznij za darmo",
      topLineLabel: "Dzisiaj",
      metrics: [
        { label: "Kcal zostało", value: "1,420" },
        { label: "Białko", value: "82 / 150g" },
        { label: "Węglowodany", value: "128 / 210g" },
        { label: "Tłuszcz", value: "41 / 70g" }
      ]
    },
    problemSection: {
      label: "Problem",
      title: "Logowanie posiłków nie powinno przypominać roboty biurowej.",
      items: [
        {
          icon: "search",
          title: "Przekopywanie się przez bazy zabija chęci",
          body: "Setki wariantów i kiepskie wyszukiwarki sprawiają, że liczenie kalorii bardziej męczy, niż pomaga trzymać rytm."
        },
        {
          icon: "timer",
          title: "Ręczne wpisywanie kradnie czas",
          body: "Każdy posiłek to kolejne minuty stukania w telefon, chociaż chcesz po prostu szybko dodać jedzenie i wrócić do dnia."
        },
        {
          icon: "layers",
          title: "Większość aplikacji jest niepotrzebnie przekombinowana",
          body: "Feedy, reklamy i przeładowane dashboardy tylko przeszkadzają. Yapper skupia się na tym, co naprawdę ma znaczenie."
        }
      ]
    },
    howItWorksSection: {
      label: "Jak działa Yapper",
      title: "Od zdjęcia do wpisu w trzech prostych krokach.",
      steps: [
        {
          number: "01",
          icon: "camera",
          title: "Zrób zdjęcie posiłku",
          body: "Po prostu zrób zdjęcie talerza, bez wybierania składników i zgadywania porcji na starcie."
        },
        {
          number: "02",
          icon: "brain",
          title: "AI rozpoznaje składniki i porcje",
          body: "Yapper zamienia obraz w sensowne dane żywieniowe i skraca cały proces do minimum."
        },
        {
          number: "03",
          icon: "spark",
          title: "Kalorie i makro zapisują się od razu",
          body: "Twój dzienny bilans aktualizuje się natychmiast, więc aplikacja pomaga ogarniać jedzenie, a nie dokłada pracy."
        }
      ]
    },
    featuresSection: {
      label: "Możliwości",
      title: "Funkcje stworzone po to, żeby logować szybciej.",
      items: [
        {
          eyebrow: "Obraz",
          icon: "camera",
          title: "Analiza zdjęcia",
          body: "Dodawaj posiłki ze zdjęcia bez przekopywania bazy produktów i ręcznego składania całego talerza."
        },
        {
          eyebrow: "Kod kreskowy",
          icon: "barcode",
          title: "Skaner kodów",
          body: "W przypadku produktów paczkowanych wystarczy szybki skan i gotowe."
        },
        {
          eyebrow: "Naturalny input",
          icon: "voice",
          title: "Logowanie głosem i tekstem",
          body: "Powiedz albo wpisz, co zjadłeś, a Yapper ogarnie resztę w tle."
        },
        {
          eyebrow: "Postęp",
          icon: "chart",
          title: "Trendy wagi",
          body: "Śledź wagę i historię żywienia w prostszym interfejsie, który pokazuje to, co ważne."
        }
      ]
    },
    pricingSection: {
      label: "Prosty cennik",
      title: "Płać za wygodę, nie za kolejną zbędną subskrypcję.",
      footnote: "Na start nie potrzebujesz karty.",
      plans: [
        {
          name: "Free",
          price: "Darmowy na stałe",
          cadence: "",
          note: "Wejdź bez zobowiązań.",
          emphasis: "standard",
          cta: "Zacznij",
          features: [
            "Dodawanie zdjęciem",
            "Ręczne wpisywanie",
            "Podstawowa historia",
            "Śledzenie wagi"
          ]
        },
        {
          name: "Pro",
          price: "$2.49",
          cadence: "/miesiąc lub $29.99/rok",
          note: "Najlepsza opcja, jeśli logujesz regularnie.",
          badge: "Najczęściej wybierany",
          emphasis: "highlight",
          cta: "Przejdź na Pro",
          features: [
            "Pełna analiza AI",
            "Skanowanie kodów kreskowych",
            "Logowanie głosem i tekstem",
            "Eksport danych",
            "Priorytetowe wsparcie"
          ]
        }
      ]
    },
    finalCta: {
      title: "Licz sprytniej. Jedz świadomiej.",
      body: "Dołącz do tysięcy osób, które porzuciły ręczne wyszukiwanie i w końcu zaczęły logować posiłki bez tarcia.",
      href: "#",
      label: "Pobierz za darmo na iOS"
    }
  }
};

export function getLandingContent(locale: Locale) {
  return landingContent[locale];
}
