import { getSiteCopy, siteConfig, type Locale } from "../data/site";
import { getAlternateLinks, getLocalizedPath, type RouteKey } from "./i18n";

export type MetaInput = {
  locale: Locale;
  routeKey: RouteKey;
  title?: string;
  description?: string;
};

export function buildMeta(input: MetaInput) {
  const localeCopy = getSiteCopy(input.locale);
  const title = input.title ? `${input.title} | ${siteConfig.name}` : localeCopy.title;
  const description = input.description ?? localeCopy.description;
  const pathname = getLocalizedPath(input.locale, input.routeKey);
  const canonical = new URL(pathname, siteConfig.url).toString();
  const alternates = getAlternateLinks(input.routeKey).map((entry) => ({
    hreflang: entry.locale,
    href: new URL(entry.href, siteConfig.url).toString()
  }));

  return {
    title,
    description,
    canonical,
    alternates,
    xDefault: new URL(getLocalizedPath("en", input.routeKey), siteConfig.url).toString()
  };
}
