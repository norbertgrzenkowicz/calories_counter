# Yapper Email Templates

Source-of-truth email templates for Yapper transactional email.

## Structure

```text
emails/
  tokens/brand.json
  templates/
    en/
    pl/
```

## Current Template Set

- `auth-confirm-email.html`
- `billing-trial-started.html`
- `billing-payment-failed.html`
- `billing-cancel-scheduled.html`

## Design Rules

- Match the current Yapper product brand: near-black background, soft charcoal card, neon green accent.
- Keep layout restrained: one card, one headline, short body copy, one primary CTA.
- Avoid multi-column sections, heavy gradients, large hero images, and decorative complexity.
- Use email-safe fonts and simple table layout for broad client compatibility.

## Variable Conventions

### Supabase auth template

`auth-confirm-email.html` is designed to be pasted into the Supabase confirmation email template.

Supabase variables used:

- `{{ .ConfirmationURL }}`
- `{{ .Email }}`
- `{{ .SiteURL }}`

These variables are documented by Supabase in its Auth email templates docs:
- https://supabase.com/docs/guides/auth/auth-email-templates

### Billing templates

Billing templates use provider-agnostic placeholders so they can be rendered later by the backend or an email provider:

- `{{app_name}}`
- `{{user_email}}`
- `{{plan_name}}`
- `{{trial_end_date}}`
- `{{subscription_end_date}}`
- `{{manage_subscription_url}}`
- `{{update_billing_url}}`
- `{{support_email}}`
- `{{site_url}}`

## Suggested Subjects

### English

- `auth-confirm-email`: `Confirm your Yapper email`
- `billing-trial-started`: `Your Yapper trial has started`
- `billing-payment-failed`: `Update your billing details`
- `billing-cancel-scheduled`: `Your Yapper plan will end soon`

### Polish

- `auth-confirm-email`: `Potwierdź swój adres e-mail w Yapper`
- `billing-trial-started`: `Twój okres próbny Yapper już trwa`
- `billing-payment-failed`: `Zaktualizuj dane płatności`
- `billing-cancel-scheduled`: `Twój plan Yapper wkrótce się zakończy`

## Integration Notes

- Keep Stripe-managed invoice and receipt emails enabled in Stripe Dashboard.
- Use the `auth-confirm-email` templates in Supabase first.
- Use the billing templates once Yapper adds backend-driven outbound email sending.
