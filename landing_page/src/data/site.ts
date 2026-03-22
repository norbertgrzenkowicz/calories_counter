export const siteConfig = {
  name: "Yapper",
  title: "Yapper | Snap a Meal. Know Your Macros.",
  description:
    "AI-powered food tracking for iOS. Log meals by photo, voice, text, or barcode without wrestling with bloated calorie apps.",
  url: "https://yapper.app",
  appStoreUrl: "#",
  contactEmail: "hello@yapper.app",
  contactHref: "mailto:hello@yapper.app",
  privacyPath: "/privacy",
  termsPath: "/terms",
  contactPath: "/contact",
  socialProof: "4.8 average rating · Used by 2,400+ users · Free to start",
  footerTagline: "Built with AI for humans who eat food."
} as const;

export type SiteConfig = typeof siteConfig;
