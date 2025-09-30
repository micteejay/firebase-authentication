# App Entry (main.dart, MyApp)

The `main.dart` file initializes platform settings, Firebase, and the notification system, then launches `MyApp`.

## App Startup
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp();
  await NotificationService().initialize();
  runApp(const MyApp());
}
```

- Locks orientation to portrait
- Initializes Firebase and OneSignal
- Starts the Flutter app

## MyApp
`MyApp` configures theme, title, and the home widget using `FirebaseAuth.instance.authStateChanges()` to select the initial screen.

### Behavior
- While auth state is loading → `SplashScreen`
- If user is signed in → `DashboardScreen`
- If no user → `StartScreen`

### Navigator Key
`MaterialApp` is provided a global `navigatorKey` from `NavigationService` to support navigation outside widget context.