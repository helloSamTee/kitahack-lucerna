import 'dart:math';

import 'package:Lucerna/calculator/carbon_footprint.dart';
import 'package:Lucerna/common_widget.dart';
import 'package:Lucerna/ecolight/lamp_stat.dart';
import 'package:Lucerna/home/dashboard.dart';
import 'package:Lucerna/login/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Lucerna/auth_provider.dart' as LucernaAuthProvider;
import 'package:Lucerna/calculator/common_widget.dart';
import 'package:Lucerna/chat/chat.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _geminiApiKeyController = TextEditingController();
  final TextEditingController _carbonSutraApiKeyController =
      TextEditingController();

  bool _isApiKeyVisible = false;
  bool _isEditingApiKeys = false; // Flag to control edit mode for API keys
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final authProvider =
        Provider.of<LucernaAuthProvider.AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      _usernameController.text = authProvider.user!.username;
      _emailController.text = authProvider.user!.email;

      FirebaseFirestore.instance
          .collection('users')
          .doc(authProvider.user!.uid)
          .get()
          .then((userDoc) {
        if (userDoc.exists) {
          final data = userDoc.data();
          setState(() {
            _geminiApiKeyController.text = data?['geminiApiKey'] ?? '';
            _carbonSutraApiKeyController.text =
                data?['carbonSutraApiKey'] ?? '';
          });
        }
      }).catchError((error) {
        print("Error fetching user data: $error");
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _geminiApiKeyController.dispose();
    _carbonSutraApiKeyController.dispose();
    super.dispose();
  }

  void _showEditProfileDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 16,
          right: 16,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Edit Profile",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "Username",
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUpdating
                  ? null
                  : () async {
                      setState(() {
                        _isUpdating = true;
                      });
                      final newUsername = _usernameController.text.trim();
                      final newEmail = _emailController.text.trim();

                      final authProvider =
                          Provider.of<LucernaAuthProvider.AuthProvider>(context,
                              listen: false);
                      final uid = FirebaseAuth.instance.currentUser?.uid;

                      if (uid != null) {
                        bool updateResult =
                            await authProvider.updateEmail(newEmail);
                        if (updateResult) {
                          // Also update username in Firestore if needed:
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .update({
                            'username': newUsername,
                          });
                          // Optionally update local state in AuthProvider if you have an updateUser method.
                          setState(() {
                            _usernameController.text = newUsername;
                            _emailController.text = newEmail;
                            _isUpdating = false;
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Profile Updated"),
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                            ),
                          );
                        } else {
                          setState(() {
                            _isUpdating = false;
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error updating profile")),
                          );
                        }
                      } else {
                        setState(() {
                          _isUpdating = false;
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("User not found")),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                minimumSize: Size(double.infinity, 50),
              ),
              child: _isUpdating
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPasswordDialog() {
    final TextEditingController _newPasswordController =
        TextEditingController();
    final TextEditingController _confirmPasswordController =
        TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Use StatefulBuilder to hold local state for error messages.
        String errorMessage = "";
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 16,
                right: 16,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Change Password",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _newPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "New Password",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 12),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final newPassword = _newPasswordController.text.trim();
                      final confirmPassword =
                          _confirmPasswordController.text.trim();

                      if (newPassword.isEmpty || confirmPassword.isEmpty) {
                        setModalState(() {
                          errorMessage = "Password fields cannot be empty";
                        });
                        return;
                      }

                      if (newPassword != confirmPassword) {
                        setModalState(() {
                          errorMessage = "Passwords do not match";
                        });
                        return;
                      }

                      setModalState(() {
                        errorMessage = "";
                      });

                      try {
                        // Call the AuthProvider to update the password.
                        bool result =
                            await Provider.of<LucernaAuthProvider.AuthProvider>(
                          context,
                          listen: false,
                        ).updatePassword(newPassword);

                        if (result) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Password Updated Successfully"),
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                            ),
                          );
                        } else {
                          setModalState(() {
                            errorMessage = "Failed to update password";
                          });
                        }
                      } catch (e) {
                        setModalState(() {
                          errorMessage = e.toString();
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text("Save Password"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "My Profile"),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).colorScheme.secondary,
            labelColor: Theme.of(context).colorScheme.secondary,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(icon: Icon(Icons.person), text: "Profile"),
              Tab(icon: Icon(Icons.vpn_key), text: "API Keys"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildApiKeysTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          CommonBottomNavigationBar(selectedTab: BottomTab.profile),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Block for Username
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, size: 24, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Username",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _usernameController.text,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Block for Email
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.email, size: 24, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Email",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _emailController.text,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Row for Action Buttons (Edit Profile & Change Password)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit Profile"),
                  onPressed: _showEditProfileDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.lock),
                  label: const Text("Change Password"),
                  onPressed: _showEditPasswordDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          // divider line
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.8),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Logout Button
          ElevatedButton.icon(
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text("Logout", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () async {
              await Provider.of<LucernaAuthProvider.AuthProvider>(context, listen: false)
                  .logout();

              // Navigate to the LoginPage
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false, // Remove all previous routes
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeysTab() {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Gemini API Key Field
          TextField(
            controller: _geminiApiKeyController,
            obscureText: !_isApiKeyVisible,
            readOnly: !_isEditingApiKeys,
            decoration: InputDecoration(
              labelText: "Gemini API Key",
              labelStyle: const TextStyle(fontSize: 18),
              floatingLabelStyle: const TextStyle(fontSize: 25),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _isApiKeyVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _isApiKeyVisible = !_isApiKeyVisible),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Carbon Sutra API Key Field
          // TextField(
          //   controller: _carbonSutraApiKeyController,
          //   obscureText: !_isApiKeyVisible,
          //   readOnly: !_isEditingApiKeys,
          //   decoration: InputDecoration(
          //     labelText: "Carbon Sutra API Key",
          //     labelStyle: const TextStyle(fontSize: 18),
          //     floatingLabelStyle: const TextStyle(fontSize: 25),
          //     border: const OutlineInputBorder(),
          //     suffixIcon: IconButton(
          //       icon: Icon(
          //         _isApiKeyVisible ? Icons.visibility_off : Icons.visibility,
          //       ),
          //       onPressed: () =>
          //           setState(() => _isApiKeyVisible = !_isApiKeyVisible),
          //     ),
          //   ),
          // ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              if (_isEditingApiKeys) {
                final geminiApiKey = _geminiApiKeyController.text.trim();
                final carbonSutraApiKey =
                    _carbonSutraApiKeyController.text.trim();

                try {
                  // Call AuthProvider to update API keys
                  await Provider.of<LucernaAuthProvider.AuthProvider>(
                    context,
                    listen: false,
                  ).updateApiKeys(geminiApiKey, carbonSutraApiKey);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("API Keys Updated Successfully"),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed to update API keys: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }

              setState(() {
                _isEditingApiKeys = !_isEditingApiKeys;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isEditingApiKeys
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).colorScheme.secondary,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(_isEditingApiKeys ? "Save Keys" : "Edit Keys"),
          ),
        ],
      ),
    ));
  }
}
