# Product scope and release plan

## Product
Name: دليلك الطبي | Your Medical Guide
Languages at launch: Arabic and English.
Initial platform: Android APK. Architecture should not block iOS/web later.

## Core user journeys
1. Select language or follow device language.
2. Search by current location, country/city, provider name, or specialty.
3. Filter hospitals, clinics, and doctors.
4. Open provider profile: address, phone, hours, services, source and verification date.
5. Call provider or open directions.
6. Request/book an appointment only where a verified booking integration exists.
7. Report incorrect information.

## Provider portal (phase 2)
- Provider registration and identity/credential verification.
- Claim an existing listing.
- Submit changes to phone, address, services and opening hours.
- Moderator approval and change history.

## Emergency experience
- Emergency numbers must be country-specific and maintained from authoritative sources.
- Do not infer a universal emergency number.
- Show a clear disclaimer that the app is not an emergency dispatch service.
- A prominent call action must only appear when the user's country and number are confidently resolved.

## Data governance
- Every record needs source, license/permission basis, last-verified timestamp and verification state.
- Never scrape or republish data against provider terms.
- Do not claim worldwide completeness. Coverage varies by country and source.
- Opening hours are not appointment availability. Booking requires provider confirmation/API.
- Phone numbers should be normalized to E.164 where possible.
- Store provider timezone; render opening hours in local time.
- Provide correction and removal workflows.

## Security and privacy
- Request location only when the user invokes nearby search; allow manual country/city search.
- Do not collect patient symptoms or medical records for a directory MVP.
- Use HTTPS, least-privilege service accounts, rate limiting, input validation and audit logs.
- Keep API secrets server-side; restrict map keys by app/package and API.
- Define privacy notices, consent, retention and deletion processes for each target jurisdiction.

## Delivery phases
### P0 — foundation
Flutter bilingual shell, API contract, database schema, CI, design system.
### P1 — MVP directory
Search, geolocation, map, provider detail, click-to-call, report correction.
### P2 — verified provider portal
Provider accounts, verification, moderation, audit trail.
### P3 — appointment integrations
Provider calendar integrations and booking confirmations; no fake availability.
### P4 — scale
Country-by-country data partnerships, localization, monitoring, performance and compliance.

## Release acceptance
- Arabic RTL and English LTR tested on physical Android devices.
- Search works with manual location when GPS is denied.
- No unverified listing is labeled verified.
- Calls and directions open correct native apps.
- Empty, offline, permission-denied and API-error states are handled.
- Privacy/security review and signed release build completed.
