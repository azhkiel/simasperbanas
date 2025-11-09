import 'package:flutter/material.dart';

const primaryBlue = Color(0xFF1E88E5);

class JobPreparationPage extends StatefulWidget {
  const JobPreparationPage({super.key});

  @override
  State<JobPreparationPage> createState() => _JobPreparationPageState();
}

class _JobPreparationPageState extends State<JobPreparationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _nim = TextEditingController();
  final _email = TextEditingController();
  final _tempatLahir = TextEditingController();
  final _alamatSby = TextEditingController();
  final _alamatLuar = TextEditingController();
  final _provinsi = TextEditingController();
  final _kewarganegaraan = TextEditingController();
  final _noHp = TextEditingController();
  final _tanggalLahir = TextEditingController();

  String? _jk;
  String? _agama;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      _tanggalLahir.text = '${picked.day}-${picked.month}-${picked.year}';
      setState(() {});
    }
  }

  InputDecoration _dec([String? hint]) => InputDecoration(
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  );

  Widget _field(String label, TextEditingController c, {int maxLines = 1, TextInputType? type}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(controller: c, maxLines: maxLines, keyboardType: type, decoration: _dec()),
      ],
    );
  }

  Widget _dropdown(String label, String? value, List<String> opts, void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          decoration: _dec(),
          items: opts.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colGap = const SizedBox(height: 12);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (_, c) {
            final isWide = c.maxWidth >= 760;

            final left = [
              _field('Nama Lengkap', _nama),
              colGap,
              _field('NIM', _nim, type: TextInputType.number),
              colGap,
              _field('Email', _email, type: TextInputType.emailAddress),
              colGap,
              _field('Tempat Lahir', _tempatLahir),
              colGap,
              _field('Alamat Surabaya', _alamatSby, maxLines: 2),
              colGap,
              _field('Alamat Luar Surabaya', _alamatLuar, maxLines: 2),
              colGap,
              _field('Provinsi', _provinsi),
              colGap,
              _dropdown('Jenis Kelamin', _jk, ['Laki-laki', 'Perempuan'], (v) => setState(() => _jk = v)),
              colGap,
              _dropdown('Agama', _agama, ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Konghucu'], (v) => setState(() => _agama = v)),
              colGap,
              _field('Kewarganegaraan', _kewarganegaraan),
            ];

            final right = [
              _field('No. Hp / Telp', _noHp, type: TextInputType.phone),
              colGap,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tanggal Lahir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _tanggalLahir,
                    readOnly: true,
                    onTap: _pickDate,
                    decoration: _dec('dd-mm-yyyy').copyWith(suffixIcon: const Icon(Icons.calendar_today, size: 18)),
                  ),
                ],
              ),
            ];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Identitas Pribadi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Card(
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: isWide
                        ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Column(children: left)),
                        const SizedBox(width: 20),
                        Expanded(child: Column(children: right)),
                      ],
                    )
                        : Column(children: [...left, const SizedBox(height: 10), ...right]),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.save, size: 16),
                    label: const Text('Simpan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
