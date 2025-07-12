import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


final apiUrl = dotenv.env['API_URL'];
class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState> confirmPasswordKey = GlobalKey<FormFieldState>();

  final usernameController = TextEditingController();
  final emailController    = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController  = TextEditingController();

  final usernameFocus = FocusNode();
  final emailFocus    = FocusNode();
  final passwordFocus = FocusNode();
  final confirmFocus  = FocusNode();

  bool isLoading = false;
  bool isFormValid = false;

  final Map<String, bool> touchedFields = {
    'username': false,
    'email': false,
    'password': false,
    'confirm': false,
  };

  @override
  void initState() {
    super.initState();
    usernameController.addListener(_updateFormState);
    emailController.addListener(_updateFormState);
    passwordController.addListener(_updateFormState);
    confirmController.addListener(() {
      _updateFormState();
      confirmPasswordKey.currentState?.validate(); // ✅ Revalidate on every character
    });
  }

  void _updateFormState() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (valid != isFormValid) {
      setState(() {
        isFormValid = valid;
      });
    }
  }

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final username = usernameController.text.trim();
    final email    = emailController.text.trim();
    final password = passwordController.text;
    final confirm  = confirmController.text;

    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'confirm_password': confirm,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showMessage(context, 'Registration successful! Please log in.');
        Navigator.pop(context);
      } else {
        final error = jsonDecode(response.body);
        if (error.containsKey('detail')) {
          _showMessage(context, error['detail']);
        } else {
          final firstError = error.values.first[0];
          _showMessage(context, firstError ?? 'Registration failed.');
        }
      }
    } catch (e) {
      _showMessage(context, 'Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showMessage(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    usernameFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    confirmFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SingleChildScrollView(

            padding: const EdgeInsets.all(24.0),

            child: Form(
              key: _formKey,
              child: Column(

                children: [
                  TextFormField(
                    controller: usernameController,
                    focusNode: usernameFocus,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (!touchedFields['username']!) return null;
                      if (value == null || value.trim().isEmpty) return 'Username is required';
                      return null;
                    },
                    onTap: () => setState(() => touchedFields['username'] = true),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: emailController,
                    focusNode: emailFocus,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (!touchedFields['email']!) return null;
                      if (value == null || value.trim().isEmpty) return 'Email is required';
                      if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value)) return 'Invalid email';
                      return null;
                    },
                    onTap: () => setState(() => touchedFields['email'] = true),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: passwordController,
                    focusNode: passwordFocus,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (!touchedFields['password']!) return null;
                      if (value == null || value.length < 6) return 'Minimum 6 characters required';
                      return null;
                    },
                    onTap: () => setState(() => touchedFields['password'] = true),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    key: confirmPasswordKey,
                    controller: confirmController,
                    focusNode: confirmFocus,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (!touchedFields['confirm']!) return null;
                      if (value == null || value.isEmpty) return 'Please confirm your password';
                      if (value != passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                    onTap: () => setState(() => touchedFields['confirm'] = true),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (!isFormValid || isLoading) ? null : registerUser,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text('REGISTER', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?'),
                      TextButton(
                        onPressed: isLoading ? null : () => Navigator.pop(context),
                        child: const Text(
                          'Login',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
