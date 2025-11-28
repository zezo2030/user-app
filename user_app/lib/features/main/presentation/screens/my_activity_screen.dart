import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../activities/presentation/activities_page.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../../core/routes/app_route_generator.dart';

class MyActivityScreen extends StatelessWidget {
  const MyActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        // Check if user is guest
        if (authState is Guest) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamed(context, AppRoutes.login);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('login_required'.tr()),
                backgroundColor: Colors.orange,
              ),
            );
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return const ActivitiesPage();
      },
    );
  }
}
