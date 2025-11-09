import 'package:flutter/material.dart';

const kGradA = Color(0xFF667EEA);
const kGradB = Color(0xFF764BA2);
TextStyle poppins(double s, {FontWeight w = FontWeight.w500, Color? c}) => TextStyle(fontFamily: 'Poppins', fontSize: s, fontWeight: w, color: c);

class PanduanSoftSkillPage extends StatefulWidget {
  const PanduanSoftSkillPage({super.key});
  @override
  State<PanduanSoftSkillPage> createState() => _PanduanSoftSkillPageState();
}

class _PanduanSoftSkillPageState extends State<PanduanSoftSkillPage> {
  String? selectedUnsur = 'Pilih Unsur';
  final unsurList = const ['Pilih Unsur','Bakat & Minat','penalaran','Pengabdian Masyarakat'];

  InputDecoration _dec() => InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Panduan Soft Skill', style: poppins(16, w: FontWeight.w700, c: Colors.grey[800])),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 5))],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Row(children: [
              const SizedBox(width: 80, child: Text('Unsur :', style: TextStyle(fontWeight: FontWeight.w600))),
              const SizedBox(width: 8),
              Expanded(child: DropdownButtonFormField<String>(
                value: selectedUnsur, decoration: _dec(),
                items: unsurList.map((e)=>DropdownMenuItem(value:e, child: Text(e))).toList(),
                onChanged: (v)=>setState(()=>selectedUnsur = v),
              )),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [kGradA, kGradB]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: kGradA.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 6))],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {}, // TODO: load panduan
                  icon: const Icon(Icons.search, size: 18),
                  label: Text('Cari Data', style: poppins(14, w: FontWeight.w600, c: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Container(
          height: 220,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 5))],
          ),
          child: Center(child: Text('Data panduan soft skill akan ditampilkan di sini', style: poppins(13, c: Colors.grey))),
        ),
      ]),
    );
  }
}
