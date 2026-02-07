import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'core/theme/theme_cubit.dart';
import 'core/theme/app_dark_theme.dart';
import 'presentation/blocs/auth_bloc.dart';
import 'presentation/blocs/chat_bloc.dart';
import 'presentation/blocs/dashboard_bloc.dart';
import 'presentation/blocs/goal_bloc.dart';
import 'presentation/blocs/settings_bloc.dart';
import 'presentation/blocs/transaction_bloc.dart';
import 'presentation/pages/chat_page.dart';
import 'presentation/pages/dashboard_page.dart';
import 'presentation/pages/goals_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/settings_page.dart';
import 'presentation/pages/transactions_page.dart';
import 'services/ai_service.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';

/// Main application widget
class AntigravityApp extends StatelessWidget {
  const AntigravityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ThemeCubit(),
        ),
        BlocProvider(
          create: (context) => AuthBloc(
            authService: AuthService(),
            storageService: StorageService(),
          )..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (context) => DashboardBloc(
            storageService: StorageService(),
            aiService: AIService(),
          ),
        ),
        BlocProvider(
          create: (context) => TransactionBloc(
            storageService: StorageService(),
          ),
        ),
        BlocProvider(
          create: (context) => GoalBloc(
            storageService: StorageService(),
            aiService: AIService(),
          ),
        ),
        BlocProvider(
          create: (context) => ChatBloc(
            storageService: StorageService(),
            aiService: AIService(),
          ),
        ),
        BlocProvider(
          create: (context) => SettingsBloc(
            storageService: StorageService(),
            aiService: AIService(),
          ),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Antigravity',
            debugShowCheckedModeBanner: false,
            theme: context.read<ThemeCubit>().getThemeData(context),
            darkTheme: darkTheme,
            themeMode: themeMode,
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthInitial || state is AuthLoading) {
                  return const _SplashScreen();
                }

                if (state is Authenticated) {
                  return const MainNavigation();
                }

                return const LoginPage();
              },
            ),
          );
        },
      ),
    );
  }
}

/// Splash screen shown during initial loading
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                LucideIcons.wallet,
                size: 50,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Antigravity',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Main navigation with bottom navigation bar
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const TransactionsPage(),
    const GoalsPage(),
    const ChatPage(),
    const SettingsPage(),
  ];

  final List<NavigationItem> _items = [
    NavigationItem(icon: LucideIcons.layoutDashboard, label: 'Home'),
    NavigationItem(icon: LucideIcons.arrowLeftRight, label: 'Transactions'),
    NavigationItem(icon: LucideIcons.target, label: 'Goals'),
    NavigationItem(icon: LucideIcons.messageSquare, label: 'Assistant'),
    NavigationItem(icon: LucideIcons.settings, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        destinations: _items.map((item) {
          return NavigationDestination(
            icon: Icon(item.icon),
            label: item.label,
            selectedIcon: Icon(
              item.icon,
              color: colorScheme.onPrimaryContainer,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;

  NavigationItem({required this.icon, required this.label});
}
