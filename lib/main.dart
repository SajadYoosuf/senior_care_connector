import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:alarm/alarm.dart';
import 'dart:async';

import 'core/app_constants.dart';
import 'core/app_localizations.dart';
import 'theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/presentation/pages/main_screen.dart';
import 'package:app/presentation/pages/volunteer/volunteer_main_screen.dart';
import 'package:app/presentation/pages/login_screen.dart';
import 'package:app/presentation/pages/role_selection_screen.dart';
import 'package:app/presentation/pages/admin/admin_main_screen.dart';

import 'package:provider/provider.dart';
import 'package:app/data/repositories/firebase_auth_repository.dart';
import 'package:app/data/repositories/firebase_task_repository.dart';
import 'package:app/presentation/providers/auth_provider.dart';
import 'package:app/presentation/providers/locale_provider.dart';
import 'package:app/presentation/providers/task_provider.dart';
import 'package:app/presentation/providers/admin_provider.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
  fcm.RemoteMessage message,
) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");

  final type = message.data['type'];
  final majorTypes = ['sos', 'chat', 'task_accepted', 'task_completed'];

  if (majorTypes.contains(type)) {
    await Alarm.init();

    String title = message.notification?.title ?? 'Alert';
    String body = message.notification?.body ?? 'Major update received';
    int alarmId = 9999;
    bool loop = true;

    if (type == 'sos') {
      alarmId = 9991;
      final userName = message.data['userName'] ?? 'Someone';
      title = '🚨 SOS EMERGENCY: $userName';
      body = 'Requires immediate help! Tap to view location.';
    } else if (type == 'chat') {
      alarmId = 9992;
      loop = false; // Chat maybe doesn't need to loop forever
    } else if (type == 'task_accepted') {
      alarmId = 9993;
    } else if (type == 'task_completed') {
      alarmId = 9994;
    }

    // Try to get user's preferred tone
    String? tonePath;
    bool vibrate = true;

    try {
      final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .get();
        if (userDoc.exists) {
          tonePath = userDoc.data()?['alarmTone'];
          vibrate = userDoc.data()?['vibrationEnabled'] ?? true;
        }
      }
    } catch (e) {
      debugPrint('Error fetching user tone in background: $e');
    }

    final alarmSettings = AlarmSettings(
      id: alarmId,
      dateTime: DateTime.now().add(const Duration(seconds: 1)),
      assetAudioPath: tonePath,
      loopAudio: loop,
      vibrate: vibrate,
      volumeSettings: const VolumeSettings.fixed(volume: 1.0),
      notificationSettings: NotificationSettings(
        title: title,
        body: body,
        stopButton: 'Stop',
        icon: 'ic_launcher',
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  fcm.FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  // Create Android Notification Channel for high-priority SOS
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'sos_alerts',
    'SOS Emergency Alerts',
    description: 'Critical alerts for seniors needing immediate help',
    importance: Importance.max,
    playSound: true,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  // Setup FCM Foreground handling
  fcm.FirebaseMessaging.onMessage.listen((fcm.RemoteMessage message) {
    debugPrint('Got a message whilst in the foreground!');
    if (message.notification != null) {
      flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  });

  // Handle tap on notification when app is in background/terminated
  fcm.FirebaseMessaging.onMessageOpenedApp.listen((
    fcm.RemoteMessage message,
  ) async {
    if (message.data['locationUrl'] != null &&
        message.data['locationUrl'].toString().isNotEmpty) {
      final url = Uri.parse(message.data['locationUrl']);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  });

  await Alarm.init();

  tz.initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestNotificationsPermission();

  await Hive.initFlutter();
  await Hive.openBox('medicines');
  await Hive.openBox('tasks');

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final String? role = prefs.getString('userRole');

  final authProvider = AuthProvider(FirebaseAuthRepository());
  if (isLoggedIn) {
    await authProvider.loadCurrentUser();
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final taskRepository = FirebaseTaskRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider(taskRepository)),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MyApp(
        isLoggedIn: isLoggedIn,
        initialRole: role,
        navigatorKey: navigatorKey,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final String? initialRole;
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    this.initialRole,
    required this.navigatorKey,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static StreamSubscription<AlarmSettings>? ringSubscription;

  @override
  void initState() {
    super.initState();
    _setupAlarmListeners();
  }

  void _setupAlarmListeners() {
    ringSubscription ??= Alarm.ringStream.stream.listen((alarmSettings) {
      _showAlarmDialog(alarmSettings);
    });
  }

  void _showAlarmDialog(AlarmSettings alarmSettings) {
    final context = widget.navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(alarmSettings.notificationSettings.title),
        content: Text(alarmSettings.notificationSettings.body),
        actions: [
          TextButton(
            onPressed: () async {
              await Alarm.stop(alarmSettings.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Stop'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    ringSubscription?.cancel();
    ringSubscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocaleProvider, AuthProvider>(
      builder: (context, localeProvider, authProvider, child) {
        Widget home;

        if (!authProvider.isAuthenticated && !widget.isLoggedIn) {
          home = const LoginScreen();
        } else {
          final baseRole = authProvider.user?.role ?? widget.initialRole;
          final role = baseRole == 'both'
              ? authProvider.activeRoleMode
              : baseRole;

          if (role == null || role.isEmpty) {
            home = const RoleSelectionScreen(isPostAuth: true);
          } else if (role == 'admin') {
            home = const AdminMainScreen();
          } else if (role == 'volunteer') {
            home = const VolunteerMainScreen();
          } else {
            home = const MainScreen();
          }
        }

        return MaterialApp(
          navigatorKey: widget.navigatorKey,
          title: AppStrings.appName,
          theme: AppTheme.lightTheme,
          locale: localeProvider.locale,
          supportedLocales: const [
            Locale('en'),
            Locale('ml'),
            Locale('ta'),
            Locale('hi'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          home: home,
        );
      },
    );
  }
}
