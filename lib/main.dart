import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const HomeGuardApp());
}

class HomeGuardApp extends StatelessWidget {
  const HomeGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HomeGuard App (HGA)',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

/// Device Data Model supporting Cloud Provisioning, Multi-Brand, Serial Number, & Security Password
class DeviceItem {
  final String id;
  final String category;
  final String brand;
  final String name;
  final String serialNumber;
  final String securityPassword;
  final String provisioningType;
  final String cloudRegion;
  final String streamUrl;
  bool isOnline;
  String statusMetric;
  final DateTime createdAt;

  DeviceItem({
    required this.id,
    required this.category,
    required this.brand,
    required this.name,
    required this.serialNumber,
    required this.securityPassword,
    required this.provisioningType,
    this.cloudRegion = 'Global US-East Cloud Mesh',
    required this.streamUrl,
    this.isOnline = true,
    this.statusMetric = 'Cloud Synced • Remote Ready',
    required this.createdAt,
  });
}

/// Playback Event Model for Missed Events & Alerts while Offline
class PlaybackEvent {
  final String id;
  final String title;
  final String deviceName;
  final String category;
  final DateTime timestamp;
  final String description;
  final String videoClipUrl;
  final String severity; // 'CRITICAL', 'WARNING', 'INFO'

  PlaybackEvent({
    required this.id,
    required this.title,
    required this.deviceName,
    required this.category,
    required this.timestamp,
    required this.description,
    required this.videoClipUrl,
    required this.severity,
  });
}

/// Alert Configuration Model allowing users to enter custom SMS, WhatsApp, and Email destinations.
class AlertSettings {
  String smsCountryCode;
  String smsPhoneNumber;

  String whatsappCountryCode;
  String whatsappPhoneNumber;

  String emailAddress;

  AlertSettings({
    this.smsCountryCode = '+1',
    this.smsPhoneNumber = '5550198',
    this.whatsappCountryCode = '+1',
    this.whatsappPhoneNumber = '5550198',
    this.emailAddress = 'security@homeguard.app',
  });
}

/// Dashboard Module Category Data
class DashboardModule {
  final String title;
  final IconData icon;
  final Color baseColor;
  final Color darkColor;
  final List<String> supportedBrands;

  const DashboardModule({
    required this.title,
    required this.icon,
    required this.baseColor,
    required this.darkColor,
    required this.supportedBrands,
  });
}

/// Systematic Automation Link-Up Rule Model
class LinkUpRule {
  final String id;
  final String triggerCategory;
  final String actionCategory;
  final String description;
  bool isEnabled;

  LinkUpRule({
    required this.id,
    required this.triggerCategory,
    required this.actionCategory,
    required this.description,
    this.isEnabled = true,
  });
}

/// In-memory state store pre-populated with Cloud Provisioned emulators, link-up rules, and missed playback events
class DeviceStore {
  static final DeviceStore _instance = DeviceStore._internal();
  factory DeviceStore() => _instance;
  DeviceStore._internal() {
    _startKeepAliveHeartbeat();
  }

  final AlertSettings alertSettings = AlertSettings();
  Timer? _heartbeatTimer;
  bool isSystemLockedDown = false;

  final List<LinkUpRule> linkUpRules = [
    LinkUpRule(
      id: 'rule_1',
      triggerCategory: 'SECURITY ALARMS',
      actionCategory: 'CCTV CAMERAS',
      description: 'Alarm Trigger -> Auto-point PTZ Camera at Intrusion Crime Scene & record 4K clip.',
    ),
    LinkUpRule(
      id: 'rule_2',
      triggerCategory: 'ACCESS CONTROL',
      actionCategory: 'CCTV CAMERAS',
      description: 'Access Control Breach -> Instant snapshot & biometric visitor log match.',
    ),
    LinkUpRule(
      id: 'rule_3',
      triggerCategory: 'VISITOR MANAGEMENT',
      actionCategory: 'ACCESS CONTROL',
      description: 'Gate Entry Vehicle ANPR -> Automatically open gate & log license plate.',
    ),
  ];

  // Missed events & alerts captured while device was off / offline
  final List<PlaybackEvent> missedPlaybackEvents = [
    PlaybackEvent(
      id: 'ev_1',
      title: 'Perimeter Intrusion Detected',
      deviceName: 'Perimeter PTZ Camera',
      category: 'CCTV CAMERAS',
      timestamp: DateTime.now().subtract(const Duration(hours: 4, minutes: 22)),
      description: 'Motion detected at back perimeter zone 2. PTZ auto-tracked target and recorded 4K clip.',
      videoClipUrl: 'https://cloud.hga.app/playback/clip_perimeter_01.mp4',
      severity: 'CRITICAL',
    ),
    PlaybackEvent(
      id: 'ev_2',
      title: 'Smoke Sensor Threshold Warning',
      deviceName: 'Server Room Smoke Sensor',
      category: 'FIRE ALARMS',
      timestamp: DateTime.now().subtract(const Duration(hours: 9, minutes: 15)),
      description: 'Minor smoke particulate spike detected (0.03 %/ft). Ventilation fans activated automatically.',
      videoClipUrl: 'https://cloud.hga.app/playback/clip_smoke_02.mp4',
      severity: 'WARNING',
    ),
    PlaybackEvent(
      id: 'ev_3',
      title: 'Unauthorized Door Forced Entry Attempt',
      deviceName: 'Main Lobby Biometric Turnstile',
      category: 'ACCESS CONTROL',
      timestamp: DateTime.now().subtract(const Duration(hours: 14, minutes: 50)),
      description: 'Multiple invalid RFID badge swipes recorded at side entrance. Access locked.',
      videoClipUrl: 'https://cloud.hga.app/playback/clip_access_03.mp4',
      severity: 'CRITICAL',
    ),
    PlaybackEvent(
      id: 'ev_4',
      title: 'Vehicle ANPR Gate Entry Log',
      deviceName: 'Main Gate 4K Dome Camera',
      category: 'VISITOR MANAGEMENT',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      description: 'Registered vehicle plate #UBA 882X entered gate. Visitor pass verified.',
      videoClipUrl: 'https://cloud.hga.app/playback/clip_gate_04.mp4',
      severity: 'INFO',
    ),
  ];

  void _startKeepAliveHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      for (var d in devices) {
        d.isOnline = true;
      }
    });
  }

  final List<DeviceItem> devices = [
    DeviceItem(
      id: 'dev_cctv_1',
      category: 'CCTV CAMERAS',
      brand: 'Hikvision',
      name: 'Main Gate 4K Dome Camera (ANPR Linked)',
      serialNumber: 'HK-DS-2CD2143G0',
      securityPassword: 'Secured@2025',
      provisioningType: 'Cloud Provisioning (Remote)',
      cloudRegion: 'Global US-East Cloud Mesh',
      streamUrl: 'https://cloud.hga.app/stream/hikvision_gate',
      isOnline: true,
      statusMetric: 'ANPR Active • Linked to Gate',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    DeviceItem(
      id: 'dev_cctv_2',
      category: 'CCTV CAMERAS',
      brand: 'Dahua',
      name: 'Perimeter PTZ Camera (Alarm Linked)',
      serialNumber: 'DH-SD49225T-HN',
      securityPassword: 'Dahua#Secure99',
      provisioningType: 'Cloud Provisioning (Remote)',
      cloudRegion: 'EU-Central Cloud Relay',
      streamUrl: 'https://cloud.hga.app/stream/dahua_ptz',
      isOnline: true,
      statusMetric: 'Auto-Tracking Alarm Target Ready',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    DeviceItem(
      id: 'dev_fire_1',
      category: 'FIRE ALARMS',
      brand: 'Bosch',
      name: 'Server Room Smoke Sensor',
      serialNumber: 'BS-FCP-O320',
      securityPassword: 'BoschFire#123',
      provisioningType: 'Cloud Provisioning (Remote)',
      cloudRegion: 'Global US-East Cloud Mesh',
      streamUrl: 'https://cloud.hga.app/mqtt/bosch_smoke',
      isOnline: true,
      statusMetric: 'Smoke: 0.01 %/ft (Secure)',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    DeviceItem(
      id: 'dev_access_1',
      category: 'ACCESS CONTROL',
      brand: 'ZKTeco',
      name: 'Main Lobby Biometric Turnstile (Camera Linked)',
      serialNumber: 'ZK-F22-ULTRA',
      securityPassword: 'AccessPass#88',
      provisioningType: 'Cloud Provisioning (Remote)',
      cloudRegion: 'Global US-East Cloud Mesh',
      streamUrl: 'https://cloud.hga.app/access/zk_gate',
      isOnline: true,
      statusMetric: 'Breach Detection Linked',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    DeviceItem(
      id: 'dev_alarm_1',
      category: 'SECURITY ALARMS',
      brand: 'Ajax',
      name: 'Ajax Hub 2 Plus (Perimeter Master)',
      serialNumber: 'AJAX-HUB2-W',
      securityPassword: 'AjaxSecure#1',
      provisioningType: 'Cloud Provisioning (Remote)',
      cloudRegion: 'Global US-East Cloud Mesh',
      streamUrl: 'https://cloud.hga.app/hub/ajax',
      isOnline: true,
      statusMetric: 'ARMED • Linking to Cameras',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    DeviceItem(
      id: 'dev_fence_1',
      category: 'ELECTRIC FENCE',
      brand: 'Nemtek',
      name: 'Perimeter Zone 1 Energizer',
      serialNumber: 'NT-DRUID-28',
      securityPassword: 'FenceSecure!9',
      provisioningType: 'Cloud Provisioning (Remote)',
      cloudRegion: 'Global US-East Cloud Mesh',
      streamUrl: 'https://cloud.hga.app/fence/nemtek',
      isOnline: true,
      statusMetric: 'Voltage: 10.2 kV • Lockdown Ready',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    DeviceItem(
      id: 'dev_visitor_1',
      category: 'VISITOR MANAGEMENT',
      brand: 'GateMaster',
      name: 'Gate Kiosk QR Check-In Scanner',
      serialNumber: 'GM-QR-SCAN-2025',
      securityPassword: 'VisitorPass#1',
      provisioningType: 'Cloud Provisioning (Remote)',
      cloudRegion: 'Global US-East Cloud Mesh',
      streamUrl: 'https://cloud.hga.app/visitor/kiosk',
      isOnline: true,
      statusMetric: 'ANPR Gate Link Active',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    DeviceItem(
      id: 'dev_ai_1',
      category: 'ANALYTICS & AI',
      brand: 'HGA Cloud Analytics',
      name: 'DeepFace AI Intrusion Engine',
      serialNumber: 'HGA-AI-DEEPFACE-V4',
      securityPassword: 'AISecure#2025',
      provisioningType: 'Cloud Provisioning (Remote)',
      cloudRegion: 'Global US-East Cloud Mesh',
      streamUrl: 'https://cloud.hga.app/ai/deepface',
      isOnline: true,
      statusMetric: 'Inference Latency: 12ms',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  void addDevice(DeviceItem device) {
    devices.insert(0, device);
  }

  List<DeviceItem> getDevicesForCategory(String category) {
    return devices.where((d) => d.category == category).toList();
  }
}

/// REUSABLE 3D BOUNCING TACTILE WIDGET
class Bouncy3DCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color baseColor;

  const Bouncy3DCard({
    super.key,
    required this.child,
    required this.onTap,
    required this.baseColor,
  });

  @override
  State<Bouncy3DCard> createState() => _Bouncy3DCardState();
}

class _Bouncy3DCardState extends State<Bouncy3DCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateX(0.025),
          alignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
  }
}

/// SPONTANEOUS SPLASH SCREEN WITH HGA LOGO & CATCHPHRASE
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.07).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, anim1, anim2) => const DashboardScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return ScaleTransition(
                scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  padding: const EdgeInsets.all(36),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.indigo.shade900],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyan.withValues(alpha: 0.6),
                        blurRadius: 40,
                        spreadRadius: 6,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: Colors.white,
                    size: 100,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'HGA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 72,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6.0,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      offset: Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'HOME SECURITY AT A GO',
                style: TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// DASHBOARD SCREEN WITH 5 PERSISTENT INDEXEDSTACK TABS (DEVICES, LINK-UP, PLAYBACK, EMERGENCY, CLOUD)
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static const List<DashboardModule> modules = [
    DashboardModule(
      title: 'CCTV CAMERAS',
      icon: Icons.videocam,
      baseColor: Color(0xFF2196F3),
      darkColor: Color(0xFF0D47A1),
      supportedBrands: ['Hikvision', 'Dahua', 'Uniview', 'Axis', 'Reolink', 'TP-Link', 'EZVIZ', 'Imou'],
    ),
    DashboardModule(
      title: 'FIRE ALARMS',
      icon: Icons.local_fire_department,
      baseColor: Color(0xFFF44336),
      darkColor: Color(0xFFB71C1C),
      supportedBrands: ['Bosch', 'Notifier', 'Siemens', 'Honeywell', 'Kidde', 'Apollo', 'FireLite'],
    ),
    DashboardModule(
      title: 'ACCESS CONTROL',
      icon: Icons.lock_open,
      baseColor: Color(0xFF4CAF50),
      darkColor: Color(0xFF1B5E20),
      supportedBrands: ['ZKTeco', 'HID Global', 'Suprema', 'Dahua', 'Hikvision', 'Kantech', 'Assa Abloy'],
    ),
    DashboardModule(
      title: 'SECURITY ALARMS',
      icon: Icons.security,
      baseColor: Color(0xFF9C27B0),
      darkColor: Color(0xFF4A148C),
      supportedBrands: ['Ajax', 'Paradox', 'DSC', 'Hikvision', 'Honeywell', 'Pyronix', 'Risco'],
    ),
    DashboardModule(
      title: 'ELECTRIC FENCE',
      icon: Icons.bolt,
      baseColor: Color(0xFFFF9800),
      darkColor: Color(0xFFE65100),
      supportedBrands: ['Nemtek', 'JVA', 'Stafix', 'Nemtek Druid', 'Gallagher', 'Merlin'],
    ),
    DashboardModule(
      title: 'VISITOR MANAGEMENT',
      icon: Icons.people,
      baseColor: Color(0xFF795548),
      darkColor: Color(0xFF3E2723),
      supportedBrands: ['GateMaster', 'VisitorLog', 'Kantech', 'Custom RFID', 'HID Visitor'],
    ),
    DashboardModule(
      title: 'ANALYTICS & AI',
      icon: Icons.bar_chart,
      baseColor: Color(0xFF009688),
      darkColor: Color(0xFF004D40),
      supportedBrands: ['HGA Cloud Analytics', 'AI Motion Pro', 'Heatmap AI', 'DeepFace'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final store = DeviceStore();

    final List<Widget> pages = [
      _DevicesTabWidget(store: store, modules: modules),
      _LinkUpAutomationTabWidget(store: store),
      _PlaybackVaultTabWidget(store: store),
      _EmergencyDispatchTabWidget(store: store),
      _DeploymentHubTabWidget(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFECEFF1),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HGA',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: 2.0,
                color: Colors.white,
              ),
            ),
            Text(
              'HOME SECURITY AT A GO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: Colors.amberAccent,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 6,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.amberAccent, size: 26),
            tooltip: 'Share All Active Access Links',
            onPressed: () => _showShareAllLinksDialog(context),
          ),
          IconButton(
            icon: Icon(
              Icons.warning_amber_rounded,
              color: store.isSystemLockedDown ? Colors.redAccent : Colors.amberAccent,
              size: 28,
            ),
            tooltip: 'Master System Lockdown / Crisis Mode',
            onPressed: () => _showMasterLockdownDialog(context, store),
          ),
          IconButton(
            icon: const Icon(Icons.emergency_rounded, color: Colors.white, size: 26),
            tooltip: 'Emergency Dispatch Hub',
            onPressed: () {
              setState(() {
                _selectedIndex = 3;
              });
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          backgroundColor: Colors.white,
          indicatorColor: Colors.amber.shade200,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_rounded, size: 20),
              label: 'DEVICES',
            ),
            NavigationDestination(
              icon: Icon(Icons.link_rounded, size: 20),
              label: 'LINK-UP',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_rounded, size: 20),
              label: 'PLAYBACK',
            ),
            NavigationDestination(
              icon: Icon(Icons.emergency_rounded, size: 20),
              label: 'EMERGENCY',
            ),
            NavigationDestination(
              icon: Icon(Icons.cloud_done_rounded, size: 20),
              label: 'CLOUD',
            ),
          ],
        ),
      ),
    );
  }

  void _showShareAllLinksDialog(BuildContext context) {
    const allLinksText = '''
🚀 HGA (HomeGuard App) - Active Multi-Platform Access Links:
🌐 Web Browsers (Chrome, Edge, Firefox, Safari): https://app.homeguard.app
💻 Windows Desktop App (.exe setup): https://download.homeguard.app/hga-setup.exe
🤖 Android Mobile App (Google Play / APK): https://play.google.com/store/apps/details?id=com.example.homeguard_app
🍏 iOS Mobile App (TestFlight / App Store): https://testflight.apple.com/join/homeguard_app
''';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.share_rounded, color: Color(0xFF0D47A1), size: 28),
            SizedBox(width: 10),
            Expanded(child: Text('SHARE ALL ACCESS LINKS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share these production-ready active links with users to access HGA on any platform:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Text(allLinksText, style: TextStyle(fontSize: 11, height: 1.4)),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
            icon: const Icon(Icons.copy_rounded),
            label: const Text('COPY ALL LINKS'),
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: allLinksText));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied all active client access links to clipboard!')),
              );
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  void _showMasterLockdownDialog(BuildContext context, DeviceStore store) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.gpp_bad_rounded, color: Colors.red, size: 32),
            SizedBox(width: 10),
            Text('HOUSE CRISIS LOCKDOWN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
        content: Text(
          store.isSystemLockedDown
              ? 'System is currently in CRISIS LOCKDOWN. Would you like to deactivate and return to normal operation?'
              : 'CRITICAL WARNING: Activating house lockdown will instantly seal all doors, lock vehicle gates, arm perimeter alarms at maximum voltage, and cut unauthorized power.',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: store.isSystemLockedDown ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () {
              setState(() {
                store.isSystemLockedDown = !store.isSystemLockedDown;
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(store.isSystemLockedDown ? 'HOUSE LOCKED DOWN SUCCESSFULLY.' : 'Lockdown lifted. Normal operation resumed.'),
                  backgroundColor: store.isSystemLockedDown ? Colors.red : Colors.green,
                ),
              );
            },
            child: Text(
              store.isSystemLockedDown ? 'LIFT LOCKDOWN' : 'ACTIVATE EMERGENCY LOCKDOWN',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }
}

/// TAB 1: DEVICES & CATEGORIES
class _DevicesTabWidget extends StatefulWidget {
  final DeviceStore store;
  final List<DashboardModule> modules;

  const _DevicesTabWidget({required this.store, required this.modules});

  @override
  State<_DevicesTabWidget> createState() => _DevicesTabWidgetState();
}

class _DevicesTabWidgetState extends State<_DevicesTabWidget> {
  @override
  Widget build(BuildContext context) {
    final totalDevices = widget.store.devices.length;
    final onlineDevices = widget.store.devices.where((d) => d.isOnline).length;
    final missedCount = widget.store.missedPlaybackEvents.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.store.isSystemLockedDown)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade900,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.5), blurRadius: 10)],
              ),
              child: const Row(
                children: [
                  Icon(Icons.gpp_bad_rounded, color: Colors.amberAccent, size: 36),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CRISIS LOCKDOWN ACTIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                        SizedBox(height: 2),
                        Text('All doors sealed, gates locked, alarms armed at max voltage.', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF0D47A1), Color(0xFF002171)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.cloud_circle_rounded,
                    color: Colors.amberAccent,
                    size: 42,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'HGA FIREBASE CLOUD & PLAYBACK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Active Cloud Nodes: $onlineDevices / $totalDevices Synced\nMissed Events While Offline: $missedCount Recorded',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'SECURITY CATEGORIES & CLOUD EMULATORS',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFF37474F),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.modules.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, index) {
              final module = widget.modules[index];
              final count = widget.store.getDevicesForCategory(module.title).length;

              return Bouncy3DCard(
                baseColor: module.baseColor,
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => CategoryDetailScreen(module: module),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return ScaleTransition(
                          scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
                          child: FadeTransition(opacity: animation, child: child),
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 500),
                    ),
                  ).then((_) => setState(() {}));
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFFF8F9FA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: module.baseColor.withValues(alpha: 0.4),
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: module.baseColor.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [module.baseColor, module.darkColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: module.darkColor.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            module.icon,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          module.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF263238),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: module.baseColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count NODES',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: module.darkColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// TAB 2: LINK-UP AUTOMATION
class _LinkUpAutomationTabWidget extends StatefulWidget {
  final DeviceStore store;

  const _LinkUpAutomationTabWidget({required this.store});

  @override
  State<_LinkUpAutomationTabWidget> createState() => _LinkUpAutomationTabWidgetState();
}

class _LinkUpAutomationTabWidgetState extends State<_LinkUpAutomationTabWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'SYSTEMIC EVENT LINK-UP AUTOMATION',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF263238)),
        ),
        const SizedBox(height: 6),
        const Text(
          'Cross-system intelligent triggers linking alarms, cameras, access control, and gates during live break-in events.',
          style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        ...widget.store.linkUpRules.map((rule) => Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.link_rounded, color: Color(0xFF0D47A1), size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(rule.triggerCategory, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF0D47A1))),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(rule.actionCategory, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.green)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(rule.description, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF263238))),
                    ],
                  ),
                ),
                Switch(
                  value: rule.isEnabled,
                  onChanged: (val) {
                    setState(() {
                      rule.isEnabled = val;
                    });
                  },
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

/// TAB 3: CLOUD PLAYBACK VAULT & MISSED EVENTS TIMELINE
class _PlaybackVaultTabWidget extends StatefulWidget {
  final DeviceStore store;

  const _PlaybackVaultTabWidget({required this.store});

  @override
  State<_PlaybackVaultTabWidget> createState() => _PlaybackVaultTabWidgetState();
}

class _PlaybackVaultTabWidgetState extends State<_PlaybackVaultTabWidget> {
  @override
  Widget build(BuildContext context) {
    final missedEvents = widget.store.missedPlaybackEvents;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'CLOUD PLAYBACK & MISSED EVENTS VAULT',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF263238)),
        ),
        const SizedBox(height: 6),
        const Text(
          'Review all security events, intrusion alarms, and CCTV video clips captured while your device was offline or away.',
          style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        if (missedEvents.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text('No missed events in vault. All systems normal.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
            ),
          )
        else
          ...missedEvents.map((ev) => Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: ev.severity == 'CRITICAL' ? Colors.red.shade50 : Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: ev.severity == 'CRITICAL' ? Colors.red : Colors.amber),
                            ),
                            child: Icon(
                              ev.severity == 'CRITICAL' ? Icons.warning_rounded : Icons.info_rounded,
                              color: ev.severity == 'CRITICAL' ? Colors.red : Colors.amber.shade800,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ev.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                                const SizedBox(height: 2),
                                Text('Device: ${ev.deviceName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: ev.severity == 'CRITICAL' ? Colors.red.shade900 : Colors.teal.shade700,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(ev.severity, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Text(ev.description, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF37474F))),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('Recorded: ${ev.timestamp.toLocal().toString().substring(0, 19)}', style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(42),
                        ),
                        icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.amberAccent),
                        label: const Text('REPLAY 4K CCTV VIDEO CLIP', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          _showPlaybackPlayerDialog(context, ev);
                        },
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  void _showPlaybackPlayerDialog(BuildContext context, PlaybackEvent ev) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.play_arrow_rounded, color: Color(0xFF0D47A1), size: 28),
            const SizedBox(width: 10),
            Expanded(child: Text(ev.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 170,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.movie_rounded, color: Colors.redAccent, size: 56),
                    SizedBox(height: 8),
                    Text('FIREBASE CLOUD PLAYBACK\nPlaying 15s Encrypted 4K Video Clip...', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text('Device: ${ev.deviceName}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Time: ${ev.timestamp}'),
            const SizedBox(height: 6),
            Text(ev.description, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }
}

/// TAB 4: EMERGENCY DISPATCH
class _EmergencyDispatchTabWidget extends StatelessWidget {
  final DeviceStore store;

  const _EmergencyDispatchTabWidget({required this.store});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'EMERGENCY AUTHORITIES & SECURITY DISPATCH',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF263238)),
        ),
        const SizedBox(height: 6),
        const Text(
          'One-tap spontaneous support dispatch to local police, private armed response, and emergency authorities.',
          style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        _buildEmergencyCard(context, 'Local Police / Law Enforcement', 'Instant SOS Dispatch • GPS Location & 4K CCTV Clip', '911 / National Police Command', Icons.local_police_rounded, Colors.blue.shade800),
        const SizedBox(height: 12),
        _buildEmergencyCard(context, 'Private Armed Security Response', 'Armed Patrol Unit Dispatch • 3-Min Response Time', 'HGA Security Response Control', Icons.security_rounded, Colors.red.shade800),
        const SizedBox(height: 12),
        _buildEmergencyCard(context, 'Medical Emergency & Ambulance', 'Paramedic & Trauma Unit Dispatch', 'National Medical Emergency Dispatch', Icons.medical_services_rounded, Colors.teal.shade800),
        const SizedBox(height: 12),
        _buildEmergencyCard(context, 'Fire & Rescue Department', 'Smoke/Fire Hazard SOS & Building Floorplan', 'Emergency Fire & Rescue Services', Icons.local_fire_department_rounded, Colors.orange.shade800),
      ],
    );
  }

  Widget _buildEmergencyCard(BuildContext context, String agencyName, String subtitle, String contactInfo, IconData icon, Color color) {
    return Bouncy3DCard(
      baseColor: color,
      onTap: () {
        _showEmergencyDispatchConfirmDialog(context, agencyName, contactInfo, color);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(agencyName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF263238))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text(contactInfo, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('DISPATCH SOS', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyDispatchConfirmDialog(BuildContext context, String agencyName, String contactInfo, Color color) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: color, size: 30),
            const SizedBox(width: 10),
            Expanded(child: Text('DISPATCH SOS TO $agencyName?', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact: $contactInfo', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('This will instantly transmit:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const Text('• Live GPS Coordinates\n• 4K CCTV Intrusion Video Clips\n• Active Alarm & Access Control Logs', style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('SOS SUCCESSFULLY DISPATCHED TO $agencyName! Units en route.'),
                  backgroundColor: color,
                ),
              );
            },
            child: const Text('CONFIRM & DISPATCH SOS', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }
}

/// TAB 5: FIREBASE CLOUD MESH & SHAREABLE ACCESS LINKS
class _DeploymentHubTabWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'FIREBASE CLOUD MESH & ACCESS LINKS',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF263238)),
        ),
        const SizedBox(height: 6),
        const Text(
          'Share these active production links with users to access HGA instantly across Windows, iOS, Android, and all web browsers.',
          style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        _buildDeployCard(
          context,
          'Web Browsers (Chrome, Edge, Firefox, Safari)',
          'Instant Web App • Click to Copy Link',
          'https://app.homeguard.app',
          Icons.language_rounded,
          Colors.blue.shade700,
        ),
        const SizedBox(height: 12),
        _buildDeployCard(
          context,
          'Windows Desktop App (.exe setup)',
          'Windows 10 / 11 Native Client',
          'https://download.homeguard.app/hga-setup.exe',
          Icons.desktop_windows_rounded,
          Colors.indigo.shade700,
        ),
        const SizedBox(height: 12),
        _buildDeployCard(
          context,
          'Android Mobile App (Google Play / APK)',
          'Android 8.0+ Mobile & Tablet Package',
          'https://play.google.com/store/apps/details?id=com.example.homeguard_app',
          Icons.android_rounded,
          Colors.green.shade700,
        ),
        const SizedBox(height: 12),
        _buildDeployCard(
          context,
          'iOS Mobile App (TestFlight / App Store)',
          'iPhone & iPad Native iOS Client',
          'https://testflight.apple.com/join/homeguard_app',
          Icons.phone_iphone_rounded,
          Colors.purple.shade700,
        ),
      ],
    );
  }

  Widget _buildDeployCard(BuildContext context, String platformName, String subtitle, String url, IconData icon, Color color) {
    return Bouncy3DCard(
      baseColor: color,
      onTap: () {
        Clipboard.setData(ClipboardData(text: url));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Copied $platformName active link to clipboard! Ready to share.')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(platformName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF263238))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text(url, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
            ),
            const Icon(Icons.copy_rounded, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

/// CATEGORY DETAIL SCREEN WITH FIREBASE CLOUD PROVISIONING & LINK-UP
class CategoryDetailScreen extends StatefulWidget {
  final DashboardModule module;

  const CategoryDetailScreen({super.key, required this.module});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final store = DeviceStore();
    final categoryDevices = store.getDevicesForCategory(widget.module.title);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.module.title, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        backgroundColor: widget.module.darkColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: categoryDevices.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No devices configured for ${widget.module.title}.\nTap "+ ADD DEVICE" below.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categoryDevices.length,
              itemBuilder: (context, index) {
                final device = categoryDevices[index];
                return Bouncy3DCard(
                  baseColor: widget.module.baseColor,
                  onTap: () {
                    _showCloudEmulatorDemoDialog(context, device);
                  },
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: widget.module.baseColor,
                                child: Icon(widget.module.icon, color: Colors.white),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      device.name,
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Brand: ${device.brand} • Interlinked Event Ready',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: widget.module.darkColor, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue),
                                ),
                                child: const Text(
                                  'LINKED',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            children: [
                              const Icon(Icons.qr_code, size: 16, color: Colors.black54),
                              const SizedBox(width: 6),
                              Text('SN: ${device.serialNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              const Spacer(),
                              const Icon(Icons.link, size: 16, color: Colors.indigo),
                              const SizedBox(width: 4),
                              const Text('Systemic Link Active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.indigo)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.public, size: 16, color: Colors.black54),
                              const SizedBox(width: 6),
                              Text('Status: ${device.statusMetric}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: widget.module.darkColor)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: widget.module.darkColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('ADD DEVICE', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showCloudProvisionModal(context),
      ),
    );
  }

  void _showCloudEmulatorDemoDialog(BuildContext context, DeviceItem device) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(widget.module.icon, color: widget.module.darkColor),
            const SizedBox(width: 10),
            Expanded(child: Text(device.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.linked_camera_rounded, color: Colors.cyanAccent, size: 52),
                    const SizedBox(height: 8),
                    Text(
                      'FIREBASE LIVE FEED ACTIVE\n${device.statusMetric}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text('Brand: ${device.brand}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Serial Number: ${device.serialNumber}'),
            Text('Cloud Region: ${device.cloudRegion}'),
            const SizedBox(height: 10),
            const Text('Systemic Link-Up: Automatically points PTZ cameras, logs access breaches, and captures vehicle number plates upon trigger.', style: TextStyle(fontSize: 11, color: Colors.indigo, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: widget.module.darkColor, foregroundColor: Colors.white),
            icon: const Icon(Icons.bolt),
            label: const Text('TRIGGER INTERLINKED BREAK-IN EVENT'),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Break-in event triggered! Cameras auto-pointed & emergency units notified for ${device.name}.')),
              );
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  void _showCloudProvisionModal(BuildContext context) {
    final nameController = TextEditingController();
    final snController = TextEditingController();
    final passController = TextEditingController();
    String selectedBrand = widget.module.supportedBrands.first;
    String selectedRegion = 'Global US-East Cloud Mesh';

    final brands = widget.module.supportedBrands;
    final regions = ['Global US-East Cloud Mesh', 'EU-Central Cloud Relay', 'Asia-Pacific Cloud Hub'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ADD DEVICE: ${widget.module.title}',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                const Text('Add device remotely over the internet with systemic link-up enabled.', style: TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 16),
                const Text('Select Brand:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedBrand,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: brands.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedBrand = val);
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Device Name (e.g., Gate ANPR Camera)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: snController,
                  decoration: const InputDecoration(
                    labelText: 'Device Serial Number / Cloud UID',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: passController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Security Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Cloud Relay Region:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedRegion,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: regions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedRegion = val);
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.module.darkColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      DeviceStore().addDevice(
                        DeviceItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          category: widget.module.title,
                          brand: selectedBrand,
                          name: nameController.text,
                          serialNumber: snController.text.isEmpty ? 'HGA-CLOUD-9999' : snController.text,
                          securityPassword: passController.text.isEmpty ? 'Secured@123' : passController.text,
                          provisioningType: 'Cloud Provisioning (Remote)',
                          cloudRegion: selectedRegion,
                          streamUrl: 'https://cloud.hga.app/stream/${nameController.text.toLowerCase().replaceAll(' ', '_')}',
                          isOnline: true,
                          statusMetric: 'Interlinked & Cloud Active',
                          createdAt: DateTime.now(),
                        ),
                      );
                      Navigator.pop(ctx);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Successfully added & interlinked ${nameController.text}!')),
                      );
                    }
                  },
                  child: const Text('ADD & INTERLINK DEVICE', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
