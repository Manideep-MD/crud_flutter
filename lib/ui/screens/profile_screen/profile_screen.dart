import 'package:crud_operations/ui/components/common_text_form_field/common_text_form_field.dart';
import 'package:crud_operations/source/local/db_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _store = FirebaseFirestore.instance;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();

  bool editMode = true; // true => view mode, false => edit mode
  bool _loading = false;
  Map<String, dynamic>? currentUser;

  @override
  void initState() {
    super.initState();
    handleCurrentUserDetails();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> handleCurrentUserDetails() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _loading = true);
    try {
      final snapshot = await _store.collection('users').doc(user.uid).get();

      if (!snapshot.exists) {
        currentUser = {};
      } else {
        currentUser = snapshot.data() as Map<String, dynamic>?;
      }
      _fullNameController.text = '${currentUser?['fullName'] ?? ''}';
      _emailController.text = '${currentUser?['email'] ?? ''}';
      _mobileController.text = '${currentUser?['mobile'] ?? ''}';

      await DBHelper.instance.insetUser({
        'name': currentUser?['fullName'] ?? '',
        'email': currentUser?['email'] ?? ''
      });

      List users = await DBHelper.instance.getUser();
      print('$users \n users are printed---------->');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
      print('$e \n Failed to load profile---------->');

    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> handleUpdateProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Simple validation
    final fullName = _fullNameController.text.trim();
    final mobile = _mobileController.text.trim();

    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Full name cannot be empty')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _store.collection('users').doc(user.uid).update({
        'fullName': fullName,
        'mobile': mobile,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      setState(() {
        editMode = true;
      });

      await handleCurrentUserDetails();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _auth.signOut();
      // Optionally navigate to login screen:
      // Navigator.of(context).pushReplacement(...);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = (_fullNameController.text.isNotEmpty)
        ? _fullNameController.text
        : 'User';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile header card with avatar and name
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              (displayName.isNotEmpty)
                                  ? displayName.trim()[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Name + email
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _emailController.text.isNotEmpty
                                      ? _emailController.text
                                      : 'No email',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Edit button (toggles edit mode)
                          IconButton(
                            onPressed: () {
                              setState(() {
                                editMode = !editMode;
                              });
                            },
                            icon: Icon(editMode ? Icons.edit : Icons.close),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Form area with text above fields (no built-in labels)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Full Name",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      CommonTextFormField(
                        controller: _fullNameController,
                        hint: 'Enter full name',
                        keyboardType: TextInputType.name,
                        readOnly: editMode,
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        "Email",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      CommonTextFormField(
                        controller: _emailController,
                        hint: 'Enter email',
                        keyboardType: TextInputType.emailAddress,
                        readOnly: true,
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        "Mobile Number",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      CommonTextFormField(
                        controller: _mobileController,
                        hint: 'Enter mobile number',
                        keyboardType: TextInputType.phone,
                        readOnly: editMode,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Submit button (visible when editing)
                  if (!editMode)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : handleUpdateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Logout button (visible when not editing)
                  if (editMode)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _handleLogout,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.orange.shade700),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
