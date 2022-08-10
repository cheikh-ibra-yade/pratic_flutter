import 'package:flutter/material.dart';

List<Widget> MyAppBarActions(context) => [
      PopupMenuButton<Menu>(
        onSelected: (menuSelected) {
          switch (menuSelected) {
            case Menu.Login:
              break;
            case Menu.LogOut:
              break;
            case Menu.Settings:
              break;
            case Menu.Exit:
              break;
          }
        },
        itemBuilder: (context) => <PopupMenuEntry<Menu>>[
          PopupMenuItem(
            value: Menu.Login,
            child: Text("Login"),
          ),
          PopupMenuItem(
            child: Text("LogOut"),
            value: Menu.LogOut,
          ),
          PopupMenuItem(
            child: Text("Settings"),
            value: Menu.Settings,
          ),
          PopupMenuItem(
            child: Text("Exit"),
            value: Menu.Exit,
          ),
        ],
      )
    ];

enum Menu { Login, LogOut, Settings, Exit }
