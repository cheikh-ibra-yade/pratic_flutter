import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:thick_app/services/note-service.dart';

class NoteView extends StatefulWidget {
  const NoteView({Key? key}) : super(key: key);

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  final String email = "yadecheikhibra@gmail.com";
  late final noteService;

  @override
  void initState() {
    noteService = NoteService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: noteService.getOrCreateUser(email: email),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return StreamBuilder(
                stream: noteService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return const Text("Santeer");
                    case ConnectionState.waiting:
                      return const CircularProgressIndicator();
                    case ConnectionState.active:
                      return const Text("Santev");
                    case ConnectionState.done:
                      return const Text("Sante");
                  }
                });
            break;
          case ConnectionState.waiting:
            return const Text("sasntWa");
            break;
          case ConnectionState.active:
            return const Text("sasntH");
            break;
          case ConnectionState.none:
            return const Text("sasntQ");
            break;
        }
      },
    );
  }
}
