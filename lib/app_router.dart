import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/identify_vehicle/ui/identify_screen.dart';
import 'features/result/ui/vin_result_screen.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => IdentifyScreen(),
    ),
    GoRoute(
      path: '/result',
      builder: (context, state) => ResultScreen(),
    ),
  ],
);