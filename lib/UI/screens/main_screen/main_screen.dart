import 'package:calculadora_unet/UI/app_theme.dart';
import 'package:calculadora_unet/UI/screens/convert_screen/convert_screen.dart';
import 'package:calculadora_unet/UI/screens/total_screen/total_screen.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PersistentTabController controller = PersistentTabController();

    List<Widget> buildScreens() {
      return [
        const TotalScreen(),
        const ConvertScreen(),
      ];
    }

    List<PersistentBottomNavBarItem> navBarsItems() {
      return [
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.calculate),
          title: "Calculadora",
          activeColorPrimary: AppTheme.nearlyBlue,
          inactiveColorPrimary: Colors.grey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.sync),
          title: "Conversión",
          activeColorPrimary: AppTheme.nearlyBlue,
          inactiveColorPrimary: Colors.grey,
        ),
      ];
    }

    return PersistentTabView(
      context,
      controller: controller,
      screens: buildScreens(),
      items: navBarsItems(),
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      navBarStyle: NavBarStyle.style9,
    );
  }
}
