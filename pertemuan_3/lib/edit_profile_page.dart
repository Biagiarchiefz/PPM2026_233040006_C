import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditResult {
  final String name;
  final String about;
  final String pendidikan;
  final String lokasi;
  final String kontak;
  final List<String> skills;
  final Uint8List? imageBytes;

  const ProfileEditResult({
    required this.name,
    required this.about,
    required this.pendidikan,
    required this.lokasi,
    required this.kontak,
    required this.skills,
    this.imageBytes,
  });
}

class EditProfilePage extends StatefulWidget {
  final String name;
  final String about;
  final String pendidikan;
  final String lokasi;
  final String kontak;
  final List<String> skills;
  final Uint8List? imageBytes;

  const EditProfilePage({
    super.key,
    required this.name,
    required this.about,
    required this.pendidikan,
    required this.lokasi,
    required this.kontak,
    required this.skills,
    this.imageBytes,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _aboutController;
  late final TextEditingController _pendidikanController;
  late final TextEditingController _lokasiController;
  late final TextEditingController _kontakController;
  late final TextEditingController _skillsController;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _aboutController = TextEditingController(text: widget.about);
    _pendidikanController = TextEditingController(text: widget.pendidikan);
    _lokasiController = TextEditingController(text: widget.lokasi);
    _kontakController = TextEditingController(text: widget.kontak);
    _skillsController = TextEditingController(text: widget.skills.join(', '));
    _imageBytes = widget.imageBytes;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _pendidikanController.dispose();
    _lokasiController.dispose();
    _kontakController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama tidak boleh kosong')),
      );
      return;
    }
    final skills = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    Navigator.pop(
      context,
      ProfileEditResult(
        name: _nameController.text.trim(),
        about: _aboutController.text.trim(),
        pendidikan: _pendidikanController.text.trim(),
        lokasi: _lokasiController.text.trim(),
        kontak: _kontakController.text.trim(),
        skills: skills,
        imageBytes: _imageBytes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        actions: [
          TextButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: const Text('Simpan'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Foto Profil',
              style: TextStyle(
                color: Colors.lightBlue.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageBytes != null
                      ? MemoryImage(_imageBytes!)
                      : const AssetImage('assets/images/biagi.jpg')
                            as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.lightBlue,
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Ganti Foto dari Galeri'),
            ),
            const Divider(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Informasi Profil',
                style: TextStyle(
                  color: Colors.lightBlue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap *',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _aboutController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Tentang',
                prefixIcon: Icon(Icons.info_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pendidikanController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Pendidikan',
                prefixIcon: Icon(Icons.school_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lokasiController,
              decoration: const InputDecoration(
                labelText: 'Lokasi',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _kontakController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Kontak',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _skillsController,
              decoration: const InputDecoration(
                labelText: 'Skills (pisahkan dengan koma)',
                prefixIcon: Icon(Icons.star_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Simpan Perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
