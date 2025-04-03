import 'package:flutter/material.dart';
import 'package:Lucerna/ecolight/lamp_stat.dart';
import 'package:Lucerna/calculator/carbon_footprint.dart';
import 'package:Lucerna/home/dashboard.dart';
import 'package:Lucerna/chat/chat.dart';
import 'package:Lucerna/profile/user_profile.dart';

enum BottomTab { ecolight, tracker, dashboard, chat, profile }

class CommonBottomNavigationBar extends StatelessWidget {
  final BottomTab selectedTab;

  const CommonBottomNavigationBar({Key? key, required this.selectedTab})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Theme.of(context)
          .colorScheme
          .secondary, //Color.fromRGBO(173, 191, 127, 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildIcon(context, Icons.lightbulb, BottomTab.ecolight, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ecolight_stat()),
            );
          }),
          _buildIcon(context, Icons.edit, BottomTab.tracker, () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CarbonFootprintTracker()));
          }),
          _buildIcon(context, Icons.pie_chart, BottomTab.dashboard, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => dashboard()),
            );
          }),
          _buildImageIcon(context, 'assets/chat-w.png', BottomTab.chat, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      chat(carbonFootprint: '10', showAddRecordButton: false)),
            );
          }),
          _buildIcon(context, Icons.person, BottomTab.profile, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserProfile()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildIcon(
      BuildContext context, IconData icon, BottomTab tab, VoidCallback onTap) {
    return IconButton(
      icon: Icon(
        icon,
        color: selectedTab == tab ? Colors.black : Colors.white,
      ),
      onPressed: onTap,
    );
  }

  Widget _buildImageIcon(BuildContext context, String assetPath, BottomTab tab,
      VoidCallback onTap) {
    return IconButton(
      icon: ColorFiltered(
        colorFilter: ColorFilter.mode(
          selectedTab == tab ? Colors.black : Colors.white,
          BlendMode.srcIn,
        ),
        child: Image.asset(assetPath),
      ),
      onPressed: onTap,
    );
  }
}

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CommonAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .headlineLarge!
            .copyWith(color: Colors.white),
      ),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      centerTitle: true,
      toolbarHeight: kToolbarHeight + 10,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 10);
}
