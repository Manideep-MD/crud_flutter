import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_operations/ui/components/common_text_form_field/common_text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? emailError;
  String? passError;
  String? nameError;

  checkValidation() {
    bool isValid = true;

    // full name
    if (_fullNameController.text.isEmpty) {
      nameError = 'This field is required';
      isValid = false;
    } else {
      nameError = null;
    }

    // email
    if (_emailController.text.isEmpty) {
      emailError = 'This field is required';
      isValid = false;
    } else if (!_emailController.text.contains('@')) {
      emailError = 'Enter a valid email address';
      isValid = false;
    } else {
      emailError = null;
    }

    // password
    if (_passwordController.text.isEmpty) {
      passError = 'This field is required';
      isValid = false;
    } else {
      passError = null;
    }

    setState(() {});
    return isValid;
  }

  handleRegister() async {
    if (!checkValidation()) return;

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': DateTime.now(),
        'id': uid,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registration Successful')));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.5,
                          color: Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 20),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Sign up with one of the following',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        'Full Name*',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CommonTextFormField(
                        controller: _fullNameController,
                        keyboardType: TextInputType.name,
                        hint: "John Doe",
                        suffixIcon: nameError == null
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : null,
                        validator: (_) => nameError,
                      ),
                      if (nameError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 5, left: 4),
                          child: Text(
                            nameError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      const Text(
                        'Email*',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CommonTextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        hint: "joe.doe@gmail.com",
                        suffixIcon: emailError == null
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : null,
                        validator: (_) => emailError,
                      ),
                      if (emailError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 5, left: 4),
                          child: Text(
                            emailError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      const Text(
                        'Password*',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CommonTextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        hint: "Enter password",
                        suffixIcon: const Icon(Icons.visibility_outlined),
                        validator: (_) => passError,
                      ),
                      if (passError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 5, left: 4),
                          child: Text(
                            passError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            handleRegister();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign in for free',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
