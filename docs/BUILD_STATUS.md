# Build and integration status — v0.3

- Flutter Android/iOS source: shared Flutter application; platform folders are generated with `flutter create --platforms=android,ios .`.
- Database: Docker Compose PostGIS service; SQL initialization includes core schema and provider-submission workflow.
- API: FastAPI reads verified providers from PostGIS and persists new submissions as pending review.
- Map: Flutter map uses OpenStreetMap tiles and API-backed verified-provider markers; route action opens Google Maps directions.
- Not completed: no compiled APK/AAB/IPA, no production hosting, no real provider dataset, no Apple signing, no production tile-provider contract, no production security audit.
