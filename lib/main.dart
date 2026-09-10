import 'package:flutter/material.dart';

void main() {
  runApp(const NamazVaktiApp());
}

class NamazVaktiApp extends StatelessWidget {
  const NamazVaktiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Namaz Vaxtı',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0F5132),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F5132),
          secondary: const Color(0xFFD4AF37),
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const DhikrScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Namaz Vaxtı'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Vaxtlar'),
          BottomNavigationBarItem(icon: Icon(Icons.touch_app), label: 'Zikrmatik'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ayarlar'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              Card(child: ListTile(title: Text('İmsak'), trailing: Text('04:52'))),
              Card(child: ListTile(title: Text('Zöhr'), trailing: Text('12:51'))),
              Card(child: ListTile(title: Text('Əsr'), trailing: Text('16:24'))),
              Card(child: ListTile(title: Text('Məğrib'), trailing: Text('19:18'))),
              Card(child: ListTile(title: Text('İşa'), trailing: Text('20:41'))),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey.shade200,
          child: Row(
            children: [
              Checkbox(value: true, onChanged: (val) {}),
              const Text('Azan oxunsun'),
            ],
          ),
        ),
      ],
    );
  }
}

class DhikrScreen extends StatefulWidget {
  const DhikrScreen({super.key});

  @override
  State<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends State<DhikrScreen> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$_counter', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(30)),
            onPressed: () => setState(() => _counter++),
            child: const Icon(Icons.add, size: 40),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.nightlight_round),
          title: const Text('Gecə Namazı Xatırlatması'),
          subtitle: const Text('02:30'),
          trailing: Switch(value: true, onChanged: (val) {}),
        ),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.language),
          title: Text('Tətbiq Dili'),
          trailing: Text('Azərbaycan'),
        ),
      ],
    );
  }
}
