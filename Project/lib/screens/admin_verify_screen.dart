// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:my_diary/services/auth_service.dart';
import 'admin_login_screen.dart';

class AdminVerifyScreen extends StatefulWidget {
  final String username;
  const AdminVerifyScreen({super.key, required this.username});

  @override
  _AdminVerifyScreenState createState() => _AdminVerifyScreenState();
}

class _AdminVerifyScreenState extends State<AdminVerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  String _code = '';
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await AuthService.adminVerify(
      username: widget.username,
      code: _code,
    );
    setState(() {
      _loading = false;
    });
    if (res == null || res['error'] != null) {
      setState(() {
        _error = res != null && res['error'] != null
            ? (res['error'] as String)
            : 'Xác thực thất bại';
      });
      return;
    }
    // verified, navigate to admin login
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xác thực đăng ký quản trị')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Mã đã được gửi tới email: ${widget.username}'),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Mã xác thực',
                          prefixIcon: Icon(Icons.vpn_key),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Nhập mã' : null,
                        onSaved: (v) => _code = v ?? '',
                      ),
                      const SizedBox(height: 16),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Xác thực và hoàn tất đăng ký'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
