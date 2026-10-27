import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/group_provider.dart';
import 'screens/groups/groups_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SplitMateApp());
}

class SplitMateApp extends StatelessWidget {
  const SplitMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GroupProvider(),
      child: MaterialApp(
        title: 'SplitMate',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        home: const GroupsScreen(),
      ),
    );
  }
}
