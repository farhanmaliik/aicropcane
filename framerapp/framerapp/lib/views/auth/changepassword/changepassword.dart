// ignore_for_file: use_build_context_synchronously, unused_field

import 'package:flutter/material.dart';
import 'package:framerapp/provider/authprovider.dart';
import 'package:framerapp/utils/appcolors.dart';

import '../../home/home.dart';

import 'package:provider/provider.dart';

class ChangePassordScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ChangePassordScreen({super.key, required this.userData});

  @override
  State<ChangePassordScreen> createState() => _ChangePassordScreenState();
}

class _ChangePassordScreenState extends State<ChangePassordScreen> {
  final _formKey = GlobalKey<FormState>();
  String _oldpassword = "";
  String _password = "";

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  SizedBox(height: constraints.maxHeight * 0.1),
                  Image.asset("assets/logo/ts_logo.png", height: 150),
                  SizedBox(height: constraints.maxHeight * 0.1),
                  Text(
                    "Change Password",
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.05),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Old Password',
                            filled: true,
                            fillColor: Color(0xFFF5FCF9),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.all(
                                Radius.circular(50),
                              ),
                            ),
                          ),
                          onSaved: (val) => _oldpassword = val ?? "",
                          validator: (val) =>
                              val!.isEmpty ? "Old Password" : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: TextFormField(
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: 'Password',
                              filled: true,
                              fillColor: Color(0xFFF5FCF9),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(50),
                                ),
                              ),
                            ),
                            onSaved: (val) => _password = val ?? "",
                            validator: (val) =>
                                val!.isEmpty ? "Enter password" : null,
                          ),
                        ),
                        authProvider.isLoading
                            ? const CircularProgressIndicator(
                                color: primaryColor,
                                strokeWidth: 2.0,
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState!.save();
                                      try {
                                        bool success = await authProvider
                                            .changepassword(
                                              username:
                                                  widget.userData["username"],
                                              email: widget.userData["email"],
                                              oldPassword: _oldpassword,
                                              password: _password,
                                            );
                                        if (success) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Password Changed Successful",
                                              ),
                                            ),
                                          );

                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const Home(),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text(e.toString())),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(
                                      double.infinity,
                                      48,
                                    ),
                                    shape: const StadiumBorder(),
                                  ),
                                  child: const Text("Change Password"),
                                ),
                              ),
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
