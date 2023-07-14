import 'package:flutter/material.dart';
import 'package:socialmedia/components/my_list_tile.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onWritingTap;
  final void Function()? onSignOut;
  final void Function()? onSettingsTap;
  const MyDrawer(
      {super.key,
      required this.onProfileTap,
      required this.onWritingTap,
      required this.onSignOut,
      required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // header
              const DrawerHeader(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 64,
                ),
              ),
              // home list title
              MyListTile(
                icon: Icons.home,
                text: 'H O M E',
                onTap: () => Navigator.pop(context),
              ),
              // writing title
              MyListTile(
                icon: Icons.edit_note,
                text: 'W R I T I N G',
                onTap: onWritingTap,
              ),
              // profile list title
              MyListTile(
                icon: Icons.person,
                text: 'P R O F I L E',
                onTap: onProfileTap,
              ),
              MyListTile(
                icon: Icons.settings,
                text: 'S E T T I N G S',
                onTap: onSettingsTap,
              ),
            ],
          ),
          // logout list title
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: MyListTile(
              icon: Icons.logout,
              text: 'L O G O U T',
              onTap: onSignOut,
            ),
          ),
        ],
      ),
    );
  }
}
