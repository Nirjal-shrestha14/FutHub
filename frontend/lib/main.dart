import 'package:flutter/material.dart';
import 'package:futhub2/screens/splash_page.dart';
import 'package:khalti/khalti.dart';
import 'package:khalti_flutter/khalti_flutter.dart';

import 'pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Khalti.init(
    publicKey: 'test_public_key_d5d9f63743584dc38753056b0cc737d5',
    enabledDebugging: false,
  );
  KhaltiService.publicKey = 'test_public_key_d5d9f63743584dc38753056b0cc737d5';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return KhaltiScope(
      publicKey: KhaltiService.publicKey,
      builder: (context, navKey) {
        return MaterialApp(
          title: 'Futhub2',
          debugShowCheckedModeBanner: false,
          navigatorKey: navKey,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('ne', 'NP'),
          ],
          localizationsDelegates: const [
            KhaltiLocalizations.delegate,
          ],
          routes: {
            '/': (context) => const SplashPage(),
            '/landing': (context) => const LandingPage(),
            '/register': (context) => const RegisterPage(),
            '/login': (context) => const LoginPage(),
            '/admin_dashboard': (context) => const AdminDashboard(),
            '/admin-players': (context) => const AdminPlayersPage(),
            '/futsal_owner_dashboard': (context) =>
                const FutsalOwnerDashboard(),
            '/add_futsal': (context) => const AddFutsalPage(),
            '/browse_futsals': (context) => const PlayerHomePage(),
            '/futsal_details': (context) => const FutsalDetailsPage(),
            '/payment': (context) => const PaymentPage(),
            '/player-team-search': (context) => const PlayerTeamSearchPage(),
            '/player_booking_details': (context) =>
                const PlayerBookingDetailsPage(),
          },
          //home: const MyHomePage(title: 'Flutter Demo Home Page'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
