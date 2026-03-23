import { DEFAULT_LOCALE, SUPPORTED_LOCALES, type Locale, type RouteKey } from "../data/site";

const routeSegments: Record<RouteKey, string> = {
  home: "",
  privacy: "privacy",
  terms: "terms",
  contact: "contact"
};

export { DEFAULT_LOCALE, SUPPORTED_LOCALES };
export type { Locale, RouteKey };

export function isLocale(value: string | undefined): value is Locale {
  return SUPPORTED_LOCALES.includes(value as Locale);
}

export function getLocalizedPath(locale: Locale, routeKey: RouteKey) {
  const segment = routeSegments[routeKey];
  return segment ? `/${locale}/${segment}` : `/${locale}`;
}

export function getHomeAnchorPath(locale: Locale, anchor: string) {
  return `${getLocalizedPath(locale, "home")}${anchor}`;
}

export function getAlternateLinks(routeKey: RouteKey) {
  return SUPPORTED_LOCALES.map((locale) => ({
    locale,
    href: getLocalizedPath(locale, routeKey)
  }));
}

export function getOtherLocale(locale: Locale) {
  return locale === "en" ? "pl" : "en";
}
