import 'package:flutter/material.dart';
// Nanti kita akan butuh ApiService di sini juga
import '../services/api_service.dart'; 

class AddNoteScreen extends StatefulWidget {
  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>(); // Untuk validasi form
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final ApiService apiService = ApiService();
  // final ApiService apiService = ApiService(); // Nanti untuk panggil API
  bool _isLoading = false; // Untuk indikator loading saat menyimpan

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Fungsi untuk menyimpan catatan (nanti akan panggil API)
  void _saveNote() async {
    if (_formKey.currentState!.validate()) { // Validasi form
      setState(() {
        _isLoading = true; // Mulai loading
      });

      // --- INI BAGIAN UNTUK MEMANGGIL API (BELUM DIIMPLEMENTASIKAN) ---
      try {
      // Panggil createNote dari ApiService
      await apiService.createNote(
        _titleController.text,
        _contentController.text,
      );
      // Jika berhasil, kembali ke layar sebelumnya dan kirim 'true'
      // 'true' ini akan ditangkap oleh NotesScreen untuk me-refresh daftar
      if (mounted) { // Pastikan widget masih ada di tree sebelum panggil Navigator
        Navigator.pop(context, true); 
      }
    } catch (e) {
      // Jika gagal, tampilkan SnackBar dengan pesan error
      if (mounted) { // Pastikan widget masih ada di tree
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan catatan: $e')),
        );
      }
    }
      // --- AKHIR BAGIAN API ---

      // Untuk sekarang, kita simulasi berhasil dan kembali
      print('Judul: ${_titleController.text}');
      print('Isi: ${_contentController.text}');
      await Future.delayed(Duration(seconds: 1)); // Simulasi delay

      setState(() {
        _isLoading = false;
      });
      // Beri tanda kalau ada perubahan data saat kembali
      Navigator.pop(context, true); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Catatan Baru'),
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
                maxLines: 5, // Biar bisa input lebih panjang
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
                      onPressed: _saveNote,
                      child: Text('Simpan Catatan'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}