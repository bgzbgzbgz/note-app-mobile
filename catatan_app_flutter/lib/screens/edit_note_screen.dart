// lib/screens/edit_note_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/note.dart';

class EditNoteScreen extends StatefulWidget {
  final Note note;
  EditNoteScreen({required this.note});

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
        Note updatedNote = await apiService.updateNote(
          widget.note.id,
          _titleController.text,
          _contentController.text,
        );
        
        if (!mounted) return;
        Navigator.pop(context, updatedNote); // Kembalikan objek Note yang sudah diupdate

      } catch (e) {
        if (!mounted) return;
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
        actions: [ // Tombol simpan di AppBar agar lebih mirip contoh
          IconButton(
            icon: Icon(Icons.save_outlined),
            tooltip: 'Simpan Perubahan',
            onPressed: _isLoading ? null : _updateNote, // Nonaktifkan saat loading
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0), // Kurangi padding bawah di sini
        child: Form(
          key: _formKey,
          // Gunakan Column yang bisa expand
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Judul',
                  // Hilangkan border agar lebih seamless seperti contoh
                  border: InputBorder.none, 
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ), // Style judul
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              // Divider(), // Mungkin tambahkan divider tipis
              SizedBox(height: 8),
              Expanded( // TextField untuk konten akan mengisi sisa ruang
                child: TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: 'Tulis catatanmu di sini...', // Gunakan hintText
                    border: InputBorder.none, // Hilangkan border
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                  maxLines: null, // TextField bisa banyak baris tidak terbatas
                  keyboardType: TextInputType.multiline,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16, // Sesuaikan ukuran font konten
                    height: 1.6, // Atur jarak antar baris
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Isi catatan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),
              if (_isLoading) // Tampilkan loading di bawah jika sedang menyimpan
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              // Tombol ElevatedButton dihilangkan karena sudah ada di AppBar
            ],
          ),
        ),
      ),
      // FloatingActionButton atau BottomAppBar bisa jadi alternatif tombol simpan
      // jika tidak ingin di AppBar. Untuk sekarang, kita pakai AppBar.
    );
  }
}