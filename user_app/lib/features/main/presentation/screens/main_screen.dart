import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';
import '../cubit/main_navigation_cubit.dart';
import '../cubit/main_navigation_state.dart';
import 'home_screen.dart';
import 'my_activity_screen.dart';
import 'category_screen.dart';
import 'profile_tab_screen.dart';
import '../../../home/presentation/cubit/home_cubit.dart';
import '../../../home/di/home_injection.dart';

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
  late final HomeCubit _homeCubit;

  @override
  void initState() {
    super.initState();
    _homeCubit = sl<HomeCubit>();
  }

  @override
  void dispose() {
    _homeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainNavigationCubit, MainNavigationState>(
      builder: (context, state) {
        final cubit = context.read<MainNavigationCubit>();

        // Get current tab title
        String getCurrentTitle() {
          switch (cubit.currentIndex) {
            case 0:
              return 'home'.tr();
            case 1:
              return 'my_activity'.tr();
            case 2:
              return 'category'.tr();
            case 3:
              return 'profile'.tr();
            default:
              return 'home'.tr();
          }
        }

        return PopScope(
          canPop: false, // منع الرجوع للخلف
          child: Scaffold(
            appBar: AppBar(
              title: Text(getCurrentTitle()),
              centerTitle: true,
              automaticallyImplyLeading: false, // إزالة زر الرجوع
            ),
            body: IndexedStack(
              index: cubit.currentIndex,
              children: [
                BlocProvider.value(
                  value: _homeCubit,
                  child: const HomeScreen(),
                ),
                const MyActivityScreen(),
                const CategoryScreen(),
                const ProfileTabScreen(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index) => cubit.changeTab(index),
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 8,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.home),
                  activeIcon: Icon(Iconsax.home_15),
                  label: 'home'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.activity),
                  activeIcon: Icon(Iconsax.activity),
                  label: 'my_activity'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.category),
                  activeIcon: Icon(Iconsax.category),
                  label: 'category'.tr(),
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
  }
}
