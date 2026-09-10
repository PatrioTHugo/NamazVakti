import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'dart me:async';

void main() {
  runApp(const NamazApp());
}

class NamazApp extends StatelessWidget {
  const NamazApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Namaz Vaxtı',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorSchemeSeed: const Color(0xFF10B981),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Coordinates _coordinates = Coordinates(40.4093, 49.8671); // Baku / Sumqayit default
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
      final tomorrowPrayerTimes = PrayerTimes(
        _coordinates,
        DateComponents.from(tomorrow),
        params,
      );
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
    final timeFormat = DateFormat('HH:mm');
    final hours = _timeDifference.inHours.toString().padLeft(2, '0');
    final minutes = (_timeDifference.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_timeDifference.inSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.location_on, color: Color(0xFF10B981)),
            const SizedBox(width: 8),
            Text(_locationName, style: const TextStyle(fontSize: 18, color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white),
            onPressed: _determinePosition,
          )
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
                gradient: const LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF10B981)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
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
                  _buildTimeTile("Sübh", timeFormat.format(_prayerTimes.fajr)),
                  _buildTimeTile("Günəş", timeFormat.format(_prayerTimes.sunrise)),
                  _buildTimeTile("Zöhr", timeFormat.format(_prayerTimes.dhuhr)),
                  _buildTimeTile("Əsr", timeFormat.format(_prayerTimes.asr)),
                  _buildTimeTile("Məğrib", timeFormat.format(_prayerTimes.maghrib)),
                  _buildTimeTile("İşa", timeFormat.format(_prayerTimes.isha)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeTile(String title, String time) {
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        trailing: Text(
          time,
          style: const TextStyle(color: Color(0xFF10B981), fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
