import { siteConfig } from "../site";
import type { Locale } from "../site";

type ContactChannel = {
  label: string;
  value: string;
  href: string;
};

type ContactContent = {
  eyebrow: string;
  title: string;
  description: string;
  updatedAt: string;
  intro: string;
  channels: ContactChannel[];
};

const contactContent: Record<Locale, ContactContent> = {
  en: {
    eyebrow: "Contact",
    title: "Contact",
    description: "Support and partnership contact details for Yapper.",
    updatedAt: "March 22, 2026",
    intro:
      "Use this page as the simple support and partnership contact entry point until a dedicated help workflow exists.",
    channels: [
      {
        label: "General support",
        value: siteConfig.contactEmail,
        href: siteConfig.contactHref
      },
      {
        label: "Press and partnerships",
        value: siteConfig.partnerEmail,
        href: siteConfig.partnerHref
      }
    ]
  },
  pl: {
    eyebrow: "Kontakt",
    title: "Kontakt",
    description: "Dane kontaktowe do wsparcia i współpracy w Yapperze.",
    updatedAt: "22 marca 2026",
    intro:
      "Ta strona działa jako prosty punkt kontaktu dla wsparcia i współpracy, dopóki nie powstanie osobny proces obsługi zgłoszeń.",
    channels: [
      {
        label: "Wsparcie",
        value: siteConfig.contactEmail,
        href: siteConfig.contactHref
      },
      {
        label: "Media i partnerstwa",
        value: siteConfig.partnerEmail,
        href: siteConfig.partnerHref
      }
    ]
  }
};

export function getContactContent(locale: Locale) {
  return contactContent[locale];
}
