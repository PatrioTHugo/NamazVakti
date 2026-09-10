import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

void main() {
  runApp(const NamazApp());
}

class NamazApp extends StatefulWidget {
  const NamazApp({super.key});

  @override
  State<NamazApp> createState() => _NamazAppState();
}

class _NamazAppState extends State<NamazApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    const darkBg = Color(0xFF052A3D);
    const darkCard = Color(0xFF117192);
    const accentCyan = Color(0xFF19D1E6);
    const lightBg = Color(0xFFB3CDD7);
    const accentBrown = Color(0xFF614943);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Namaz Vaxtı',
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: lightBg,
        colorSchemeSeed: accentBrown,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black87,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBg,
        colorSchemeSeed: accentCyan,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
      ),
      home: HomePage(onToggleTheme: _toggleTheme, currentMode: _themeMode),
    );
  }
}

class HomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode currentMode;

  const HomePage({super.key, required this.onToggleTheme, required this.currentMode});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Coordinates _coordinates = Coordinates(40.4093, 49.8671);
  String _locationName = "Bakı / Sumqayıt";
  late PrayerTimes _prayerTimes;
  Timer? _timer;
  Duration _timeDifference = Duration.zero;
  String _nextPrayerName = "";

  @override
  void initState() {
    super.initState();
    _calculatePrayerTimes();
    _startTimer();
    _determinePosition();
  }

  void _calculatePrayerTimes() {
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.hanafi;
    _prayerTimes = PrayerTimes.today(_coordinates, params);
    _updateNextPrayer();
  }

  void _updateNextPrayer() {
    final now = DateTime.now();
    final next = _prayerTimes.nextPrayer();
    DateTime? nextTime = _prayerTimes.timeForPrayer(next);

    if (next == Prayer.none || nextTime == null) {
      final tomorrow = now.add(const Duration(days: 1));
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.hanafi;
      final tomorrowPrayerTimes = PrayerTimes(_coordinates, DateComponents.from(tomorrow), params);
      nextTime = tomorrowPrayerTimes.fajr;
      _nextPrayerName = "Sübh";
    } else {
      _nextPrayerName = _getPrayerNameAz(next);
    }

    setState(() {
      _timeDifference = nextTime!.difference(now);
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateNextPrayer();
    });
  }

  String _getPrayerNameAz(Prayer p) {
    switch (p) {
      case Prayer.fajr: return "Sübh";
      case Prayer.sunrise: return "Günəş";
      case Prayer.dhuhr: return "Zöhr";
      case Prayer.asr: return "Əsr";
      case Prayer.maghrib: return "Məğrib";
      case Prayer.isha: return "İşa";
      default: return "";
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _coordinates = Coordinates(position.latitude, position.longitude);
      _locationName = "Cari Məkan";
      _calculatePrayerTimes();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.currentMode == ThemeMode.dark;
    final timeFormat = DateFormat('HH:mm');
    final hours = _timeDifference.inHours.toString().padLeft(2, '0');
    final minutes = (_timeDifference.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_timeDifference.inSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const AppLogo(size: 32),
            const SizedBox(width: 10),
            Text(_locationName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _determinePosition,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                      ? [const Color(0xFF117192), const Color(0xFF19D1E6)] 
                      : [const Color(0xFF614943), const Color(0xFF8D6E63)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Text(
                    "Növbəti: $_nextPrayerName",
                    style: const TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$hours:$minutes:$seconds",
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildTimeTile("Sübh", timeFormat.format(_prayerTimes.fajr), isDark),
                  _buildTimeTile("Günəş", timeFormat.format(_prayerTimes.sunrise), isDark),
                  _buildTimeTile("Zöhr", timeFormat.format(_prayerTimes.dhuhr), isDark),
                  _buildTimeTile("Əsr", timeFormat.format(_prayerTimes.asr), isDark),
                  _buildTimeTile("Məğrib", timeFormat.format(_prayerTimes.maghrib), isDark),
                  _buildTimeTile("İşa", timeFormat.format(_prayerTimes.isha), isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeTile(String title, String time, bool isDark) {
    return Card(
      color: isDark ? const Color(0xFF117192).withOpacity(0.4) : Colors.white.withOpacity(0.8),
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(
          title, 
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87, 
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Text(
          time,
          style: TextStyle(
            color: isDark ? const Color(0xFF19D1E6) : const Color(0xFF614943), 
            fontSize: 18, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF19D1E6), Color(0xFF117192)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.mosque,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
}
