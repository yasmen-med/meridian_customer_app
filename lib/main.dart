import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/localization/locale_controller.dart';
import 'features/home/home_screen.dart';
import 'features/cart/controllers/cart_controller.dart';
import 'features/orders/controllers/order_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable Edge-to-Edge for Android 15+
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // Initialize notification service and request permissions
  await NotificationService().init();

  runApp(const MeridianApp());
}

class MeridianApp extends StatelessWidget {
  const MeridianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartController()),
        ChangeNotifierProvider(create: (_) => OrderController()),
        ChangeNotifierProvider(create: (_) => LocaleController()),
      ],
      // Check Android version and automatically assign colors
      child: DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          return Consumer<LocaleController>(
            builder: (context, localeController, _) {
              return MaterialApp(
                title: 'Meridian',
                debugShowCheckedModeBanner: false,
                locale: localeController.locale,
                supportedLocales: const [Locale('en'), Locale('ar')],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                // Light and Dark mode
                theme: AppTheme.lightTheme(lightDynamic),
                darkTheme: AppTheme.darkTheme(darkDynamic),
                // Auto mode based on user's settings
                themeMode: ThemeMode.system,
                home: const HomeScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
