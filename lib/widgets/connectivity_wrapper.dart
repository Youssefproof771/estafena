import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../screens/no_internet_screen.dart';

class ConnectivityWrapper extends StatelessWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      // connectivity_plus v5+ returns a List of results
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink(); // Loading state
        }

        final results = snapshot.data ?? [ConnectivityResult.none];
        final isOffline = results.contains(ConnectivityResult.none);

        if (isOffline) {
          return const NoInternetScreen();
        }

        return child;
      },
    );
  }
}
