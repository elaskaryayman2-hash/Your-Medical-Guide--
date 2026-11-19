# Initial API contract

`GET /v1/providers`

Query parameters:
- `query`: provider name or free-text search
- `country_code`: ISO 3166-1 alpha-2 country code
- `city`: city/locality
- `provider_type`: hospital | clinic | doctor
- `latitude`, `longitude`, `radius_km`: nearby search
- `language`: requested display language

Production response should include:
- provider id, type, localized name and description
- address, country, city, coordinates and timezone
- public phone and website/booking link
- opening hours and their last-updated time
- verification state, source and last-verified time
- distance (when coordinates supplied)

Do not return private practitioner or patient information.
