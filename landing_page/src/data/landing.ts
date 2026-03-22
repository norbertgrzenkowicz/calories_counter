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

export const navItems: NavItem[] = [
  { href: "#features", label: "Features" },
  { href: "#how-it-works", label: "How It Works" },
  { href: "#pricing", label: "Pricing" }
];

export const hero = {
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
  metrics: [
    { label: "Kcal left", value: "1,420" },
    { label: "Protein", value: "82 / 150g" },
    { label: "Carbs", value: "128 / 210g" },
    { label: "Fat", value: "41 / 70g" }
  ] satisfies Metric[]
} as const;

export const problems: Problem[] = [
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
];

export const steps: Step[] = [
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
];

export const features: Feature[] = [
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
];

export const pricing: Plan[] = [
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
];

export const finalCta = {
  title: "Track smarter. Eat better.",
  body: "Join thousands who ditched the database and made food logging feel fast again.",
  href: "#",
  label: "Download Free on iOS"
} as const;
