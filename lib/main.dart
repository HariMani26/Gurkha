import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/routes/app.route.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
  MapboxOptions.setAccessToken("pk.eyJ1IjoicHJvaW5kaWEiLCJhIjoiY202dDV3N2wyMDVnZTJtcjYwM3U0bHZueSJ9.e6v6wcivuFYyT4t1P2wRJA");

    return GetMaterialApp(
      title: 'Ghurka',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!),
      // navigatorKey: navigatorKey,
      getPages: routesPages,
    );
  }
}
