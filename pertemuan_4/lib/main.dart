import 'package:flutter/material.dart';

String _formatTanggal(DateTime dt) {
  const bulan = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${dt.day} ${bulan[dt.month]} ${dt.year}';
}

class Catatan {
  final String judul;
  final String isi;
  final String kategori;
  final DateTime dibuatPada;

  Catatan({
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.dibuatPada,
  });
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/tambah':
            return MaterialPageRoute(
              builder: (_) => const TambahCatatanPage(),
            );
          case '/edit':
            final catatan = settings.arguments as Catatan;
            return MaterialPageRoute(
              builder: (_) => TambahCatatanPage(catatanAwal: catatan),
            );
          case '/detail':
            final catatan = settings.arguments as Catatan;
            return MaterialPageRoute(
              builder: (_) => DetailCatatanPage(catatan: catatan),
            );
        }
        return null;
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Catatan> _catatan = [
    Catatan(
      judul: 'Belajar Flutter',
      isi: 'Mempelajari Stateful Widget, Form, dan Navigation.',
      kategori: 'Kuliah',
      dibuatPada: DateTime.now(),
    ),
  ];

  Future<void> _bukaTambahCatatan() async {
    final hasil = await Navigator.pushNamed(context, '/tambah');

    if (hasil is Catatan) {
      setState(() => _catatan.add(hasil));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Catatan "${hasil.judul}" ditambahkan')),
      );
    }
  }

  void _hapusCatatan(int index) {
    final judul = _catatan[index].judul;
    setState(() => _catatan.removeAt(index));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Catatan "$judul" dihapus')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catatan Mahasiswa')),
      body:
          _catatan.isEmpty
              ? const _EmptyState()
              : ListView.builder(
                itemCount: _catatan.length,
                itemBuilder: (context, i) {
                  final c = _catatan[i];
                  return ListTile(
                    title: Text(c.judul),
                    subtitle: Text(
                      '${c.kategori} · ${_formatTanggal(c.dibuatPada)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Hapus',
                      onPressed: () => _hapusCatatan(i),
                    ),
                    onTap: () async {
                      final hasil = await Navigator.pushNamed(
                        context,
                        '/detail',
                        arguments: c,
                      );
                      if (hasil is Catatan) {
                        final idx = _catatan.indexOf(c);
                        if (idx != -1) {
                          setState(() => _catatan[idx] = hasil);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Catatan "${hasil.judul}" diperbarui',
                              ),
                            ),
                          );
                        }
                      }
                    },
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _bukaTambahCatatan,
        tooltip: 'Tambah Catatan',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada catatan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tekan tombol + untuk menambah catatan baru',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class TambahCatatanPage extends StatefulWidget {
  final Catatan? catatanAwal;
  const TambahCatatanPage({super.key, this.catatanAwal});

  @override
  State<TambahCatatanPage> createState() => _TambahCatatanPageState();
}

class _TambahCatatanPageState extends State<TambahCatatanPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _isiCtrl = TextEditingController();

  String _kategori = 'Kuliah';
  final _kategoriOpsi = const ['Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  bool get _isEdit => widget.catatanAwal != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _judulCtrl.text = widget.catatanAwal!.judul;
      _isiCtrl.text = widget.catatanAwal!.isi;
      _kategori = widget.catatanAwal!.kategori;
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final catatanBaru = Catatan(
      judul: _judulCtrl.text.trim(),
      isi: _isiCtrl.text.trim(),
      kategori: _kategori,
      // Saat edit, pertahankan tanggal asli; saat tambah baru, pakai waktu sekarang
      dibuatPada:
          _isEdit ? widget.catatanAwal!.dibuatPada : DateTime.now(),
    );

    Navigator.pop(context, catatanBaru);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Catatan' : 'Tambah Catatan'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judulCtrl,
              decoration: const InputDecoration(
                labelText: 'Judul',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Judul wajib diisi';
                if (v.trim().length < 3) return 'Minimal 3 karakter';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _kategori,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items:
                  _kategoriOpsi
                      .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
              onChanged: (v) => setState(() => _kategori = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _isiCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Isi',
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
              ),
              validator:
                  (v) =>
                      (v == null || v.trim().isEmpty) ? 'Isi wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _simpan,
              icon: const Icon(Icons.save),
              label: Text(_isEdit ? 'Perbarui' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailCatatanPage extends StatefulWidget {
  final Catatan catatan;
  const DetailCatatanPage({super.key, required this.catatan});

  @override
  State<DetailCatatanPage> createState() => _DetailCatatanPageState();
}

class _DetailCatatanPageState extends State<DetailCatatanPage> {
  late Catatan _catatan;

  @override
  void initState() {
    super.initState();
    _catatan = widget.catatan;
  }

  Future<void> _bukaEdit() async {
    final hasil = await Navigator.pushNamed(
      context,
      '/edit',
      arguments: _catatan,
    );
    if (hasil is Catatan) {
      setState(() => _catatan = hasil);
      if (!mounted) return;
      // Kirim data yang sudah diedit kembali ke HomePage
      Navigator.pop(context, hasil);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: _bukaEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _catatan.judul,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(label: Text(_catatan.kategori)),
                const SizedBox(width: 8),
                Text(
                  _formatTanggal(_catatan.dibuatPada),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              _catatan.isi,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}