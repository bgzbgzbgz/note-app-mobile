import 'package:flutter/material.dart';
// Nanti kita akan butuh ApiService di sini juga
import '../services/api_service.dart'; 

class AddNoteScreen extends StatefulWidget {
  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final ApiService apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return; // Keluar jika sudah tidak mounted
      setState(() {
        _isLoading = true;
      });

      try {
        await apiService.createNote(
          _titleController.text,
          _contentController.text,
        );
        
        if (!mounted) return; // Keluar jika sudah tidak mounted
        Navigator.pop(context, true); 
        // Setelah pop, widget ini sudah tidak ada, jadi tidak ada setState lagi di sini.

      } catch (e) {
        if (!mounted) return; // Keluar jika sudah tidak mounted
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan catatan: $e')),
        );
      }
      // Blok kode simulasi di bawah ini seharusnya sudah dihapus atau dikomentari
      /* // --- AKHIR BAGIAN API --- // (Komentar ini juga bisa dihapus)

      // Untuk sekarang, kita simulasi berhasil dan kembali (BLOK INI DIHAPUS/DIKOMENTARI)
      print('Judul: ${_titleController.text}');
      print('Isi: ${_contentController.text}');
      await Future.delayed(Duration(seconds: 1)); // Simulasi delay

      // Pengecekan mounted sebelum setState ini juga baik,
      // tapi jika blok ini dihapus, maka tidak diperlukan lagi.
      if (!mounted) return; 
      setState(() {
        _isLoading = false;
      });
      // Beri tanda kalau ada perubahan data saat kembali (BLOK INI DIHAPUS/DIKOMENTARI)
      if (!mounted) return;
      Navigator.pop(context, true); 
      */
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