import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/di/injection.dart';

import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/analytics/presentation/cubit/analytics_cubit.dart';
import 'features/analytics/presentation/pages/analytics_dashboard_page.dart';
import 'features/alert/presentation/cubit/alert_cubit.dart';
import 'features/alert/presentation/pages/alert_list_page.dart';
import 'features/cctv/presentation/cubit/cctv_list_cubit.dart';
import 'features/cctv/presentation/pages/cctv_stream_page.dart';
import 'features/statistics/presentation/cubit/statistics_cubit.dart';
import 'features/statistics/presentation/pages/statistics_page.dart';
import 'features/store/presentation/cubit/store_cubit.dart';
import 'features/store/presentation/pages/store_list_page.dart';
import 'features/traffic/presentation/cubit/traffic_cubit.dart';
import 'features/traffic/presentation/pages/traffic_page.dart';
import 'features/visitor/presentation/cubit/visitor_cubit.dart';
import 'features/visitor/presentation/pages/visitor_list_page.dart';
import 'features/stream/presentation/cubit/stream_status_cubit.dart';
import 'features/stream/presentation/pages/stream_control_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const VernonStoreApp());
}

/// Root widget aplikasi Vernon Store Analytics.
class VernonStoreApp extends StatelessWidget {
  const VernonStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => getIt<AuthCubit>()..checkSession(),
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const _AuthGate(),
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 2,
      ),
    );
  }
}

/// Gate yang menentukan apakah tampilkan LoginPage atau Dashboard.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoaded) {
          return const _DashboardShell();
        }
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const LoginPage();
      },
    );
  }
}

/// Shell utama dashboard dengan navigation rail (web/tablet) atau bottom nav (mobile).
class _DashboardShell extends StatefulWidget {
  const _DashboardShell();

  @override
  State<_DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<_DashboardShell> {
  int _selectedIndex = 0;

  static const int _defaultStoreId = 1;

  late final List<_NavDestination> _destinations;

  @override
  void initState() {
    super.initState();
    _destinations = [
      _NavDestination(
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        label: AppStrings.navDashboard,
        page: BlocProvider(
          create: (_) => getIt<StoreCubit>()..loadStores(),
          child: const StoreListPage(),
        ),
      ),
      _NavDestination(
        icon: Icons.videocam_outlined,
        selectedIcon: Icons.videocam,
        label: AppStrings.navCctv,
        page: BlocProvider(
          create: (_) => getIt<CCTVListCubit>()..loadCCTVList(_defaultStoreId),
          child: CCTVStreamPage(storeId: _defaultStoreId, cameraId: 1),
        ),
      ),
      _NavDestination(
        icon: Icons.bar_chart_outlined,
        selectedIcon: Icons.bar_chart,
        label: AppStrings.navAnalytics,
        page: BlocProvider(
          create: (_) =>
              getIt<AnalyticsCubit>()..loadDashboard(_defaultStoreId),
          child: AnalyticsDashboardPage(storeId: _defaultStoreId),
        ),
      ),
      _NavDestination(
        icon: Icons.people_outline,
        selectedIcon: Icons.people,
        label: AppStrings.navVisitors,
        page: BlocProvider(
          create: (_) => getIt<VisitorCubit>()..loadVisitors(_defaultStoreId),
          child: VisitorListPage(storeId: _defaultStoreId),
        ),
      ),
      _NavDestination(
        icon: Icons.warning_amber_outlined,
        selectedIcon: Icons.warning_amber,
        label: AppStrings.navAlerts,
        page: BlocProvider(
          create: (_) => getIt<AlertCubit>()..loadAlerts(_defaultStoreId),
          child: AlertListPage(storeId: _defaultStoreId),
        ),
      ),
      _NavDestination(
        icon: Icons.insights_outlined,
        selectedIcon: Icons.insights,
        label: AppStrings.navStatistics,
        page: BlocProvider(
          create: (_) => getIt<StatisticsCubit>()..loadAll(_defaultStoreId),
          child: StatisticsPage(storeId: _defaultStoreId),
        ),
      ),
      _NavDestination(
        icon: Icons.traffic_outlined,
        selectedIcon: Icons.traffic,
        label: AppStrings.navTraffic,
        page: BlocProvider(
          create: (_) => getIt<TrafficCubit>()..loadTraffic(_defaultStoreId),
          child: TrafficPage(storeId: _defaultStoreId),
        ),
      ),
      _NavDestination(
        icon: Icons.sensors_outlined,
        selectedIcon: Icons.sensors,
        label: 'Stream',
        page: BlocProvider(
          create: (_) => getIt<StreamStatusCubit>()..loadStatus(),
          child: const StreamControlPage(),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      body: isWide
          ? _buildWideLayout()
          : _destinations[_selectedIndex].page,
      bottomNavigationBar: isWide ? null : _buildBottomNav(),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          labelType: NavigationRailLabelType.all,
          backgroundColor: AppColors.primary,
          selectedIconTheme: const IconThemeData(color: Colors.white),
          unselectedIconTheme:
              const IconThemeData(color: Colors.white54),
          selectedLabelTextStyle:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          unselectedLabelTextStyle:
              const TextStyle(color: Colors.white54),
          destinations: _destinations
              .map(
                (d) => NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: Text(d.label),
                ),
              )
              .toList(),
          trailing: Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white54),
                  tooltip: AppStrings.logout,
                  onPressed: () =>
                      context.read<AuthCubit>().logout(),
                ),
              ),
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: _destinations[_selectedIndex].page),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.onSurfaceVariant,
      items: _destinations
          .map(
            (d) => BottomNavigationBarItem(
              icon: Icon(d.icon),
              activeIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
          )
          .toList(),
    );
  }
}

class _NavDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Widget page;

  const _NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.page,
  });
}
