import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:isro/providers/userProvider.dart';
import 'package:isro/screens/homePage.dart';
import 'package:isro/screens/splashScreen.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => userProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ISRO Quiz',
        theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 52, 168, 83)),
          useMaterial3: true,
        ),
        home: Consumer<userProvider>(
          builder: (context, userProvider, child) {
            return StartPage();
            // return userProvider.email != null ? HomePage() : SplashScreen();
          },
        ),
        routes: {
          '/home': (context) => HomePage(),
        },
      ),
    );
  }
}
