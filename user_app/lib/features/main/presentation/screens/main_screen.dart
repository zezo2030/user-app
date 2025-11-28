import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';
import '../cubit/main_navigation_cubit.dart';
import '../cubit/main_navigation_state.dart';
import '../../../home/presentation/pages/home_tabs_page.dart';
import 'my_activity_screen.dart';
import 'category_screen.dart';
import 'profile_tab_screen.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainNavigationCubit(),
      child: const MainScreenView(),
    );
  }
}

class MainScreenView extends StatefulWidget {
  const MainScreenView({super.key});

  @override
  State<MainScreenView> createState() => _MainScreenViewState();
}

class _MainScreenViewState extends State<MainScreenView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (authContext, authState) {
        final isGuest = authState is Guest;
        
        return BlocBuilder<MainNavigationCubit, MainNavigationState>(
          builder: (context, state) {
            final cubit = context.read<MainNavigationCubit>();

            // Get current tab title
            String getCurrentTitle() {
              if (isGuest) {
                // For guests, only show home and branches
                switch (cubit.currentIndex) {
                  case 0:
                    return 'home'.tr();
                  case 1:
                    return 'branches'.tr();
                  default:
                    return 'home'.tr();
                }
              } else {
                switch (cubit.currentIndex) {
                  case 0:
                    return 'home'.tr();
                  case 1:
                    return 'my_bookings'.tr();
                  case 2:
                    return 'branches'.tr();
                  case 3:
                    return 'profile'.tr();
                  default:
                    return 'home'.tr();
                }
              }
            }

        return PopScope(
          canPop: false, // منع الرجوع للخلف
          child: Scaffold(
            appBar: cubit.currentIndex == 0
                ? null // No AppBar for home tab (HomeTabsPage has its own UI)
                : AppBar(
                    title: Text(getCurrentTitle()),
                    centerTitle: true,
                    automaticallyImplyLeading: false,
                  ),
            body: IndexedStack(
              index: cubit.currentIndex,
              children: isGuest
                  ? [
                      const HomeTabsPage(),
                      const CategoryScreen(),
                    ]
                  : [
                      const HomeTabsPage(),
                      const MyActivityScreen(),
                      const CategoryScreen(),
                      const ProfileTabScreen(),
                    ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                if (isGuest) {
                  // For guests, only allow access to home (0) and branches (1)
                  if (index == 0 || index == 1) {
                    cubit.changeTab(index);
                  } else {
                    // Redirect to login if trying to access protected tabs
                    Navigator.pushNamed(context, '/login');
                  }
                } else {
                  cubit.changeTab(index);
                }
              },
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 8,
              selectedLabelStyle: TextStyle(fontSize: 11),
              unselectedLabelStyle: TextStyle(fontSize: 9),
              items: isGuest
                  ? [
                      BottomNavigationBarItem(
                        icon: Icon(Iconsax.home),
                        activeIcon: Icon(Iconsax.home_15),
                        label: 'home'.tr(),
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Iconsax.category),
                        activeIcon: Icon(Iconsax.category),
                        label: 'branches'.tr(),
                      ),
                    ]
                  : [
                      BottomNavigationBarItem(
                        icon: Icon(Iconsax.home),
                        activeIcon: Icon(Iconsax.home_15),
                        label: 'home'.tr(),
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Iconsax.ticket),
                        activeIcon: Icon(Iconsax.ticket),
                        label: 'my_bookings'.tr(),
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Iconsax.category),
                        activeIcon: Icon(Iconsax.category),
                        label: 'branches'.tr(),
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Iconsax.profile_circle),
                        activeIcon: Icon(Iconsax.profile_circle),
                        label: 'profile'.tr(),
                      ),
                    ],
            ),
          ),
        );
          },
        );
      },
    );
  }
}
