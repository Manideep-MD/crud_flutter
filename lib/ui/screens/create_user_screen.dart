import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateUserScreen extends StatefulWidget {
  final bool isEdit;
  final String name;
  final String email;
  final String mobile;
  final String id;
  const CreateUserScreen({
    super.key,
    required this.isEdit,
    required this.name,
    required this.email,
    required this.mobile,
    required this.id,
  });

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final FirebaseFirestore _store = FirebaseFirestore.instance;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();

  String? nameError;
  String? emailError;
  String? mobileError;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _nameController.text = widget.name;
      _emailController.text = widget.email;
      _mobileController.text = widget.mobile;
    }
  }

  checkValidation() {
    bool isValid = true;
    if (_nameController.text.isEmpty) {
      nameError = 'name is required';
      isValid = false;
    } else {
      nameError = null;
    }

    if (_emailController.text.isEmpty) {
      emailError = 'email is required';
      isValid = false;
    } else if (!_emailController.text.contains('@')) {
      emailError = 'enter a valid email';
      isValid = false;
    } else {
      emailError = null;
    }

    if (_mobileController.text.isEmpty) {
      mobileError = 'mobile number is required';
      isValid = false;
    } else {
      mobileError = null;
    }

    setState(() {});
    return isValid;
  }

  handleSubmit() async {
    if (!checkValidation()) {
      return;
    }
    if (widget.isEdit) {
      await _store.collection('users').doc(widget.id).update({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'mobile': _mobileController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('data updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      await _store.collection('users').doc().set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'mobile': _mobileController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('data added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }

    _emailController.clear();
    _mobileController.clear();
    _nameController.clear();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Hero(
          tag: 'hero1-box',
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,

                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  errorText: nameError,
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.red),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  errorText: emailError,
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.red),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              TextFormField(
                controller: _mobileController,
                decoration: InputDecoration(
                  hintText: 'Enter your mobile number',
                  errorText: mobileError,
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.red),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              IconButton(
                onPressed: () {
                  handleSubmit();
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SUBMIT',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
