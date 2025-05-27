// lib/screens/edit_note_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/note.dart'; // Kita butuh model Note

class EditNoteScreen extends StatefulWidget {
  final Note note; // Menerima note yang akan diedit

  EditNoteScreen({required this.note}); // Constructor

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final ApiService apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Isi controller dengan data note yang ada
    _titleController.text = widget.note.title;
    _contentController.text = widget.note.content;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _updateNote() async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });

      try {
        // Panggil updateNote dari ApiService
        await apiService.updateNote(
          widget.note.id, // Kirim ID catatan yang akan diupdate
          _titleController.text, // Kirim judul baru
          _contentController.text, // Kirim konten baru
        );
        
        if (!mounted) return; // Cek lagi sebelum pop
        Navigator.pop(context, true); // Kirim true untuk refresh list di NotesScreen

      } catch (e) {
        if (!mounted) return; // Cek lagi sebelum setState dan SnackBar
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui catatan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Catatan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Judul Catatan'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Isi Catatan'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Isi catatan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.0),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _updateNote,
                      child: Text('Simpan Perubahan'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}