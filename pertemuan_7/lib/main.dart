import 'package:flutter/material.dart';
import 'catatan.dart';
import 'api_client.dart';

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
      routes: {'/': (context) => const HomePage()},
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/form':
            final initial = settings.arguments as Catatan?;
            return MaterialPageRoute(
              builder: (_) => CatatanFormPage(initial: initial),
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

// ─── Home ─────────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Catatan>> _futureCatatan;

  @override
  void initState() {
    super.initState();
    _futureCatatan = ApiClient.instance.getAll();
  }

  void _muatUlang() {
    setState(() {
      _futureCatatan = ApiClient.instance.getAll();
    });
  }

  Future<void> _bukaTambahCatatan() async {
    await Navigator.pushNamed(context, '/form');
    _muatUlang();
  }

  Future<void> _hapusCatatan(Catatan catatan) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: Text('Hapus catatan "${catatan.judul}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi != true) return;
    try {
      await ApiClient.instance.delete(catatan.id!);
      if (!mounted) return;
      _muatUlang();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${catatan.judul}" dihapus')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Mahasiswa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _muatUlang,
          ),
        ],
      ),
      body: FutureBuilder<List<Catatan>>(
        future: _futureCatatan,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final e = snapshot.error;
            final pesan =
                e is ApiException ? e.message : 'Terjadi kesalahan: $e';
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 8),
                  Text(pesan, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _muatUlang,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }
          final list = snapshot.data!;
          if (list.isEmpty) return const _EmptyState();
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final c = list[i];
              return ListTile(
                title: Text(c.judul),
                subtitle: Text(
                  '${c.kategori} · ${_formatTanggal(c.dibuatPada)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Hapus',
                  onPressed: () => _hapusCatatan(c),
                ),
                onTap: () async {
                  await Navigator.pushNamed(context, '/detail', arguments: c);
                  _muatUlang();
                },
              );
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

// ─── Empty State ──────────────────────────────────────────────────────────────

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

// ─── Form (Create & Edit) ─────────────────────────────────────────────────────

class CatatanFormPage extends StatefulWidget {
  final Catatan? initial;
  const CatatanFormPage({super.key, this.initial});

  @override
  State<CatatanFormPage> createState() => _CatatanFormPageState();
}

class _CatatanFormPageState extends State<CatatanFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _isiCtrl = TextEditingController();

  String _kategori = 'Kuliah';
  final _kategoriOpsi = const ['Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];
  bool _menyimpan = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _judulCtrl.text = widget.initial!.judul;
      _isiCtrl.text = widget.initial!.isi;
      _kategori = widget.initial!.kategori;
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _menyimpan = true);
    try {
      if (_isEdit) {
        final updated = widget.initial!.copyWith(
          judul: _judulCtrl.text.trim(),
          isi: _isiCtrl.text.trim(),
          kategori: _kategori,
        );
        await ApiClient.instance.update(updated);
      } else {
        final baru = Catatan(
          judul: _judulCtrl.text.trim(),
          isi: _isiCtrl.text.trim(),
          kategori: _kategori,
          dibuatPada: DateTime.now(),
        );
        await ApiClient.instance.insert(baru);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'Catatan diperbarui' : 'Catatan ditambahkan'),
        ),
      );
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _menyimpan = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Catatan' : 'Tambah Catatan')),
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
              initialValue: _kategori,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: _kategoriOpsi
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
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Isi wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _menyimpan ? null : _simpan,
              icon: _menyimpan
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isEdit ? 'Perbarui' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Detail ───────────────────────────────────────────────────────────────────

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
    await Navigator.pushNamed(context, '/form', arguments: _catatan);
    final fresh = await ApiClient.instance.getById(_catatan.id!);
    if (mounted) setState(() => _catatan = fresh);
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
