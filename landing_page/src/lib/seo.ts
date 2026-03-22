import { siteConfig } from "../data/site";

export type MetaInput = {
  title?: string;
  description?: string;
  pathname?: string;
};

export function buildMeta(input: MetaInput = {}) {
  const title = input.title ? `${input.title} | ${siteConfig.name}` : siteConfig.title;
  const description = input.description ?? siteConfig.description;
  const canonical = new URL(input.pathname ?? "/", siteConfig.url).toString();

  return {
    title,
    description,
    canonical
  };
}
