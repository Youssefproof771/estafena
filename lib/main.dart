import 'package:estafena/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // NEW IMPORT
import 'widgets/connectivity_wrapper.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // NEW: Initialize Supabase
  await Supabase.initialize(
    url: 'https://jjxcogznffcpjhpchnsr.supabase.co', // Paste your URL[cite: 1]
    anonKey:
        'sb_publishable_zwt88H2UwyyHwyJd8MMiwQ_X4s7M8pQ', // Paste your Anon Key[cite: 1]
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final provider = AppProvider();
  await provider.init();

  runApp(
    ChangeNotifierProvider.value(value: provider, child: const EstafenaApp()),
  );
}

class EstafenaApp extends StatelessWidget {
  const EstafenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<AppProvider>().locale;

    return MaterialApp(
      title: 'Estafena',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const ConnectivityWrapper(child: HomeScreen()),
    );
  }
}
