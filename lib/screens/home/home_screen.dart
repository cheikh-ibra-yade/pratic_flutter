import 'package:flutter/material.dart';
import 'package:thick_app/components/drawer/custom_drawer.dart';
import 'package:thick_app/screens/categories/list-categories.dart';
import 'package:thick_app/screens/notes/main-note.dart';
import 'package:thick_app/views/top/popup-menu.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0,
          backgroundColor: Colors.transparent,
          title:Text("nkb"),
          actions: MyAppBarActions(context)),
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: NoteView(),
      ),
    );
  }
}
