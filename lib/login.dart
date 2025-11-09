import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import './services/api_config.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final String _baseUrl = 'http://10.5.32.174:81/SimasPerbanas/api';

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog('NIM dan password harus diisi');
      return;
    }

    setState(() => _isLoading = true);

    try {
      debugPrint('Mencoba login ke: $_baseUrl/login.php');

      final response = await http.post(
        Uri.parse('$_baseUrl/login.php'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'nim': username.trim(),
          'password': password,
        }),
      );


      // _showErrorDialog(username); // Hapus baris ini, ini hanya untuk debugging yang tidak perlu
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          final userData = data['data'];

          // ==============================================================
          // ✨ BAGIAN INI SUDAH BENAR & MENGGUNAKAN AWAIT UNTUK PENYIMPANAN
          // ==============================================================
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setInt('loginTime', DateTime.now().millisecondsSinceEpoch);
          await prefs.setInt('sessionDuration', 30);
          await prefs.setString('id', userData['id_user']?.toString() ?? '');
          await prefs.setString('nim', userData['nim'] ?? '');
          await prefs.setString('nama', userData['nama'] ?? '');
          await prefs.setString('email', userData['email'] ?? '');
          await prefs.setString('role', 'mahasiswa');

          // Opsional: Coba reload setelah simpan (untuk memastikan sinkronisasi)
          await prefs.reload();
          // ==============================================================

          _showSuccessDialog('Login berhasil!\nSelamat datang, ${userData['nama']}!');
        } else {
          _showErrorDialog(data['message'] ?? 'Login gagal');
        }
      } else {
        _showErrorDialog('Error HTTP ${response.statusCode}: Gagal terhubung ke server');
      }
    } on http.ClientException catch (e) {
      debugPrint('ClientException: $e');
      _showErrorDialog('Tidak dapat terhubung ke server. Pastikan:\n• Server XAMPP berjalan\n• URL benar: $_baseUrl\n• Port 80 tidak digunakan aplikasi lain\n\nDetail: $e');
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException: $e');
      _showErrorDialog('$e');
    } catch (e, st) {
      debugPrint('ERROR saat login: $e');
      debugPrintStack(stackTrace: st);
      _showErrorDialog('Terjadi kesalahan: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi navigasi ke halaman utama setelah login
  void _navigateToMainApp() {
    // Navigasi ke HalamanSatu (Halaman Utama)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HalamanSatu()),
          (route) => false,
    );
  }

  // ... (Sisanya adalah widget dan dialog yang tidak perlu diubah) ...

  // 🔹 Dialog error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Gagal'),
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // 🔹 Dialog sukses
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Berhasil'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Panggil navigasi ke halaman utama
              _navigateToMainApp();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.shade100, width: 2),
                  ),
                  child: Icon(
                    Icons.school,
                    size: 60,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Sistem Akademik',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Masuk ke akun Anda',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'NIM',
                          hintText: 'Masukkan NIM Anda',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Masukkan password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : const Text(
                            'MASUK',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 🔹 Info koneksi
                      Text(
                        'API: $_baseUrl',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}