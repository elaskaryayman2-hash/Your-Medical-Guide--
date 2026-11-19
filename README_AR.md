# دليلك الطبي | Your Medical Guide — الإصدار 0.3

مشروع Flutter متعدد المنصات (Android وiOS) مع API باستخدام FastAPI وقاعدة PostgreSQL/PostGIS وخرائط OpenStreetMap.

> **حالة التنفيذ:** أضيف الربط البرمجي الفعلي بين API وقاعدة البيانات، وواجهة خريطة تقرأ المنشآت الموثقة من API. لم يتم بناء APK/IPA في بيئة إعداد هذه الحزمة، ولم تُضف بيانات منشآت حقيقية أو مفاتيح استضافة. لن تظهر علامات منشآت حتى تُدخل بيانات موثقة وتُعتمد في قاعدة البيانات.

## 1) المتطلبات على Windows
- Flutter SDK حديث وDart المتوافق معه.
- Android Studio مع Android SDK وAndroid Emulator.
- Git وDocker Desktop (Linux containers).

تحقق من الإعداد:
```powershell
flutter doctor -v
```

## 2) إنشاء ملفات منصات Flutter
افتح PowerShell داخل مجلد `your_medical_guide_starter`:
```powershell
flutter create --platforms=android,ios .
flutter pub get
```
هذا ينشئ مجلدات المنصات القياسية. بناء Android يتم على Windows. مجلد iOS موجود للتحضير، لكن بناء/توقيع IPA يتطلب macOS وXcode (جهاز Mac أو خدمة CI تعمل على macOS).

## 3) تشغيل قاعدة البيانات وواجهة API
تأكد أن Docker Desktop يعمل، ثم:
```powershell
Copy-Item .env.example .env
# افتح .env وغيّر DB_PASSWORD إلى كلمة مرور قوية
 docker compose up --build -d
```
تحقق من API:
- `http://localhost:8000/health`
- `http://localhost:8000/docs`

لإيقاف الخدمات:
```powershell
docker compose down
```
ولحذف قاعدة البيانات التجريبية نهائياً (تحذير: يحذف البيانات):
```powershell
docker compose down -v
```

> ملفات SQL في `docker-entrypoint-initdb.d` تعمل عند إنشاء volume جديد فقط. إذا كان لديك volume قديم، طبّق ملف migration الجديد يدوياً بعد أخذ نسخة احتياطية.

## 4) تشغيل التطبيق على Android Emulator
شغّل المحاكي من Android Studio ثم من PowerShell:
```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```
للهاتف الحقيقي، اجعل الهاتف والكمبيوتر على شبكة Wi-Fi واحدة، واستخدم عنوان IPv4 المحلي للكمبيوتر بدلاً من `10.0.2.2`، مع السماح بمنفذ 8000 في جدار الحماية. لا تفتح API أو قاعدة البيانات للعامة بهذا الإعداد التجريبي.

## 5) بناء APK وAAB
```powershell
flutter build apk --release --dart-define=API_BASE_URL=https://YOUR-API-DOMAIN
flutter build appbundle --release --dart-define=API_BASE_URL=https://YOUR-API-DOMAIN
```
النواتج:
- `build/app/outputs/flutter-apk/app-release.apk`
- `build/app/outputs/bundle/release/app-release.aab`

استبدل `YOUR-API-DOMAIN` بعنوان API منشور مع HTTPS قبل إصدار إنتاجي. إعداد توقيع Android للنشر يجب أن يتم بمفتاح خاص محفوظ خارج المستودع.

## 6) الخرائط والبيانات
- التطبيق يعرض خريطة OpenStreetMap ويضع علامات فقط للمنشآت التي ترجعها API.
- مصدر الخريطة يحتاج اتصال إنترنت. احترم سياسة خوادم بلاطات OSM ونسبة الإسناد؛ لا تعتبر خادم البلاطات المجاني استضافة إنتاجية مضمونة أو غير محدودة. للإطلاق الواسع اختر مزود بلاطات/خرائط بعقد مناسب أو استضف البلاطات وفق الترخيص.
- API لا تعرض إلا `verification_status='verified'`، وتُحفظ اقتراحات المنشآت في `pending_review` ولا تُنشر تلقائياً.
- لا توجد حالياً قاعدة بيانات منشآت مصرية حقيقية محملة. يجب إدخال بيانات من مصدر مرخص والتحقق من التراخيص والعناوين والهواتف وساعات العمل قبل نشرها.

## 7) نشر iOS من Windows
لا يمكن إنشاء أو توقيع ملف IPA محلياً على Windows. استخدم جهاز Mac مع Xcode أو خدمة بناء CI ذات macOS، ثم أضف شهادات وتوقيع Apple Developer وارفع إلى App Store Connect/TestFlight.

## 8) قبل الإطلاق العام
يلزم إضافة المصادقة والصلاحيات ولوحة مراجعة إدارية، حماية API ومعدل الطلبات، HTTPS، النسخ الاحتياطي، مراقبة الأعطال، سياسة الخصوصية والموافقة، واختبارات على أجهزة حقيقية. لا تضع كلمات مرور أو مفاتيح API في Git.
