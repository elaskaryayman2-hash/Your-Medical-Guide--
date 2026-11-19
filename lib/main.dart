import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const MedicalGuideApp());
}

class MedicalGuideApp extends StatefulWidget {
  const MedicalGuideApp({super.key});

  @override
  State<MedicalGuideApp> createState() => _MedicalGuideAppState();
}

class _MedicalGuideAppState extends State<MedicalGuideApp> {
  Locale _locale = const Locale('ar');

  void _setLocale(Locale locale) => setState(() => _locale = locale);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) =>
          AppLocalizations.of(context)?.appTitle ?? 'Your Medical Guide',
      locale: _locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF087E8B),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6FAFB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6FAFB),
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: HomeScreen(onLocaleChanged: _setLocale, locale: _locale),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onLocaleChanged,
    required this.locale,
  });

  final ValueChanged<Locale> onLocaleChanged;
  final Locale locale;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = widget.locale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.health_and_safety, color: Color(0xFF087E8B)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n.appTitle,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: isArabic ? 'الخريطة' : 'Map',
            icon: const Icon(Icons.map_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ProviderMapScreen(isArabic: isArabic),
            )),
          ),
          TextButton(
            onPressed: () => widget.onLocaleChanged(
              isArabic ? const Locale('en') : const Locale('ar'),
            ),
            child: Text(isArabic ? 'English' : 'العربية'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              l10n.heroTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.heroSubtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black54,
                  ),
            ),
            const SizedBox(height: 22),
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: l10n.search,
                  onPressed: () => FocusScope.of(context).unfocus(),
                  icon: const Icon(Icons.arrow_forward),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.browseByCategory,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _categoryChip(l10n.all, 'all'),
                _categoryChip(l10n.hospitals, 'hospital'),
                _categoryChip(l10n.clinics, 'clinic'),
                _categoryChip(l10n.doctors, 'doctor'),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE4F3F2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.public, size: 34, color: Color(0xFF087E8B)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.globalSearchTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(l10n.globalSearchSubtitle),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(
              l10n.nearbySection,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            _placeholderCard(
              icon: Icons.location_searching,
              title: l10n.locationNeededTitle,
              subtitle: l10n.locationNeededSubtitle,
            ),
            const SizedBox(height: 18),
            Text(
              l10n.importantNote,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(String label, String value) {
    final selected = _selectedCategory == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _selectedCategory = value),
    );
  }

  Widget _placeholderCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE4F3F2),
          child: Icon(icon, color: const Color(0xFF087E8B)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}


class ProviderMapScreen extends StatefulWidget {
  const ProviderMapScreen({super.key, required this.isArabic});
  final bool isArabic;

  @override
  State<ProviderMapScreen> createState() => _ProviderMapScreenState();
}

class _ProviderMapScreenState extends State<ProviderMapScreen> {
  static const _apiBase = String.fromEnvironment(
    'API_BASE_URL', defaultValue: 'http://10.0.2.2:8000',
  );
  final _mapController = MapController();
  List<Map<String, dynamic>> _providers = [];
  bool _loading = true;
  String? _error;
  String _type = '';

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    setState(() { _loading = true; _error = null; });
    try {
      final uri = Uri.parse('$_apiBase/v1/providers').replace(queryParameters: {
        if (_type.isNotEmpty) 'provider_type': _type,
        'limit': '100',
      });
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (body['items'] as List).cast<Map<String, dynamic>>();
      if (!mounted) return;
      setState(() { _providers = items; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _loading = false; _error = widget.isArabic
        ? 'تعذر الاتصال بالخادم. تأكد من تشغيل قاعدة البيانات وواجهة API.'
        : 'Could not reach the API. Check that the database and API are running.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = _providers.isNotEmpty
      ? LatLng((_providers.first['latitude'] as num).toDouble(), (_providers.first['longitude'] as num).toDouble())
      : const LatLng(26.8206, 30.8025);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isArabic ? 'الخريطة الطبية' : 'Medical map'),
        actions: [IconButton(onPressed: _loadProviders, icon: const Icon(Icons.refresh))],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Wrap(spacing: 8, children: [
            _filterChip(widget.isArabic ? 'الكل' : 'All', ''),
            _filterChip(widget.isArabic ? 'مستشفيات' : 'Hospitals', 'hospital'),
            _filterChip(widget.isArabic ? 'عيادات' : 'Clinics', 'clinic'),
            _filterChip(widget.isArabic ? 'أطباء' : 'Doctors', 'doctor'),
          ]),
        ),
        Expanded(child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(initialCenter: center, initialZoom: 5.2),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.yourmedicalguide.app',
            ),
            MarkerLayer(markers: _providers.map((p) => Marker(
              point: LatLng((p['latitude'] as num).toDouble(), (p['longitude'] as num).toDouble()),
              width: 44, height: 44,
              child: IconButton(
                icon: const Icon(Icons.location_on, color: Color(0xFF087E8B), size: 38),
                onPressed: () => _showProvider(p),
              ),
            )).toList()),
            RichAttributionWidget(attributions: [
              TextSourceAttribution('OpenStreetMap contributors',
                onTap: () => launchUrl(Uri.parse('https://www.openstreetmap.org/copyright'))),
            ]),
          ],
        )),
        if (_loading) const LinearProgressIndicator(),
        if (_error != null) Padding(
          padding: const EdgeInsets.all(12),
          child: Text(_error!, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red)),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(_providers.isEmpty
            ? (widget.isArabic ? 'لا توجد منشآت موثقة في قاعدة البيانات بعد.' : 'No verified providers in the database yet.')
            : (widget.isArabic ? 'النتائج المعروضة موثقة فقط: ${_providers.length}' : 'Verified results only: ${_providers.length}'),
          ),
        ),
      ]),
    );
  }

  Widget _filterChip(String label, String value) => ChoiceChip(
    label: Text(label), selected: _type == value,
    onSelected: (_) { setState(() => _type = value); _loadProviders(); },
  );

  void _showProvider(Map<String, dynamic> p) {
    final lat = (p['latitude'] as num).toDouble();
    final lon = (p['longitude'] as num).toDouble();
    showModalBottomSheet(context: context, builder: (_) => SafeArea(child: Padding(
      padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${p['name']}', style: Theme.of(context).textTheme.titleLarge),
          Text('${p['address'] ?? ''} — ${p['city'] ?? ''}'),
          if (p['phone_e164'] != null) Text('${p['phone_e164']}'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => launchUrl(Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lon')),
            icon: const Icon(Icons.directions),
            label: Text(widget.isArabic ? 'الاتجاهات' : 'Directions'),
          ),
        ],
      ),
    )));
  }
}
