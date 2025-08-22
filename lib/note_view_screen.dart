import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'list_notes_screen.dart';
import 'note_edit_screen.dart';

class NoteViewScreen extends StatefulWidget {
  final Note note;
  final int index;
  final Function(int) onDelete;

  const NoteViewScreen({
    super.key,
    required this.note,
    required this.index,
    required this.onDelete,
  });

  @override
  State<NoteViewScreen> createState() => _NoteViewScreenState();
}

class _NoteViewScreenState extends State<NoteViewScreen> {
  final GlobalKey _noteKey = GlobalKey();

  void _shareNoteAsImage() async {
    try {
      final RenderRepaintBoundary boundary =
          _noteKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/note.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)], text: '${widget.note.title}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao compartilhar a nota.')),
      );
    }
  }

  void _navigateToEditScreen() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditScreen(
          note: widget.note,
          onSave: (newTitle, newContent) {
            setState(() {
              widget.note.title = newTitle;
              widget.note.content = newContent;
            });
            widget.onDelete(-1);
          },
        ),
      ),
    );

    if (result == true) {
      widget.onDelete(widget.index);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          widget.note.title.isEmpty ? 'Nova Nota' : widget.note.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareNoteAsImage,
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _navigateToEditScreen,
          ),
        ],
      ),
      body: RepaintBoundary(
        key: _noteKey,
        // --- ADICIONADO CONTAINER COM COR DE FUNDO ---
        child: Container(
          color: Colors.black,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.note.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const Divider(color: Colors.white),
                const SizedBox(height: 8.0),
                Text(
                  widget.note.content,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}