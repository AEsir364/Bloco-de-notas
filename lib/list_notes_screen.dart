// lib/list_notes_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'note_edit_screen.dart';
import 'note_view_screen.dart';

class Note {
  String title;
  String content;

  Note({required this.title, required this.content});

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
      };

  factory Note.fromJson(Map<String, dynamic> json) =>
      Note(title: json['title'], content: json['content']);
}

class ListNotesScreen extends StatefulWidget {
  const ListNotesScreen({super.key});

  @override
  State<ListNotesScreen> createState() => _ListNotesScreenState();
}

class _ListNotesScreenState extends State<ListNotesScreen> {
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString('notes');
    if (notesString != null) {
      final List<dynamic> notesJson = jsonDecode(notesString);
      setState(() {
        _notes = notesJson.map((json) => Note.fromJson(json)).toList();
      });
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesString = jsonEncode(_notes.map((note) => note.toJson()).toList());
    prefs.setString('notes', notesString);
  }

  void _navigateToViewScreen({Note? note, int? index}) async {
    if (note == null) {
      final newNote = Note(title: '', content: '');
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NoteEditScreen(
            note: newNote,
            onSave: (newTitle, newContent) {
              if (newTitle.isNotEmpty || newContent.isNotEmpty) {
                _notes.add(Note(title: newTitle, content: newContent));
                _saveNotes();
              }
            },
          ),
        ),
      );
    } else {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NoteViewScreen(
            note: note,
            index: index!,
            onDelete: (deletedIndex) {
              if (deletedIndex != -1) {
                _deleteNote(deletedIndex);
              } else {
                _saveNotes();
              }
            },
          ),
        ),
      );
      
      if (result == true) {
        _deleteNote(index!);
      }
    }
    _loadNotes(); 
  }
  
  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF6F59AB),
        title: const Text(
          'Tem Certeza que deseja deletar a nota?',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              _deleteNote(index);
              Navigator.of(context).pop();
            },
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
    _saveNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Minhas Notas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: _notes.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma nota ainda.',
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.separated(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return ListTile(
                  title: Text(
                    note.title,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  onTap: () => _navigateToViewScreen(note: note, index: index),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: () => _confirmDelete(index),
                  ),
                );
              },
              separatorBuilder: (context, index) =>
                  const Divider(color: Colors.white, height: 1),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6F59AB),
        onPressed: () => _navigateToViewScreen(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}