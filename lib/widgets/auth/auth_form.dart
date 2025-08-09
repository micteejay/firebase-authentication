import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthForm extends StatefulWidget {
  const AuthForm(this.submitFn, this.isLoading,
      {super.key, this.isLogin = true, this.onModeChanged});

  final bool isLoading;
  final bool isLogin;
  final void Function(bool isLogin)? onModeChanged;
  final void Function(
    String email,
    String password,
    String userName,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  late bool _isLogin;
  var _userEmail = '';
  var _userName = '';
  var _userPassword = '';
  final _secureStorage = const FlutterSecureStorage();
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLogin;
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
    if (widget.onModeChanged != null) {
      widget.onModeChanged!(_isLogin);
    }
  }

  void _trySubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState?.save();
      widget.submitFn(_userEmail.trim(), _userPassword.trim(), _userName.trim(),
          _isLogin, context);
      // Store credentials securely after successful login
      if (_isLogin) {
        await _secureStorage.write(key: 'email', value: _userEmail.trim());
        await _secureStorage.write(
            key: 'password', value: _userPassword.trim());
        if (!mounted) return;
      }
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Enter your email'),
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: emailController.text.trim());
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Email Sent'),
                      content: const Text(
                          'A password recovery email has been sent. Please check your inbox.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: \n${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _authenticateWithBiometrics() async {
    final LocalAuthentication auth = LocalAuthentication();
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to sign in',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (!mounted) return;
      if (didAuthenticate) {
        // Retrieve credentials and auto-login
        final email = await _secureStorage.read(key: 'email');
        final password = await _secureStorage.read(key: 'password');
        if (!mounted) return;
        if (email != null && password != null) {
          widget.submitFn(email, password, '', true, context);
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('No Credentials'),
              content: const Text(
                  'No saved credentials found. Please login manually first.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Biometric authentication failed: \n${e.toString()}')),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
    });
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() {
          _isGoogleLoading = false;
        });
        return; // User cancelled
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      try {
        await FirebaseAuth.instance.signInWithCredential(credential);
        // After successful sign-in, pop all dialogs/overlays if any
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          final email = e.email;
          final pendingCred = e.credential;
          // ignore: deprecated_member_use
          final methods =
              await FirebaseAuth.instance.fetchSignInMethodsForEmail(email!);
          if (methods.contains('password')) {
            // Prompt user to sign in with email/password
            String password = '';
            await showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  title: const Text('Link Google Account'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          'An account already exists with this email. Please enter your password to link your Google account.'),
                      const SizedBox(height: 16),
                      TextField(
                        obscureText: true,
                        decoration:
                            const InputDecoration(labelText: 'Password'),
                        onChanged: (val) => password = val,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          final userCred = await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                  email: email, password: password);
                          await userCred.user?.linkWithCredential(pendingCred!);
                          if (!mounted) return;
                          Navigator.of(ctx).pop();
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Failed to link account: \n${e.toString()}')),
                          );
                        }
                      },
                      child: const Text('Link'),
                    ),
                  ],
                );
              },
            );
          } else {
            // Handle other providers (e.g., Facebook)
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Please sign in with your existing provider to link Google.')),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Google sign-in failed: \n${e.toString()}')),
            );
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: \n${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isLogin ? 'Hello\nSign in!' : 'Create Your Account',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB31217),
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 24),
          TextFormField(
            key: const ValueKey('email'),
            decoration: InputDecoration(
              labelText: 'Email',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textCapitalization: TextCapitalization.none,
            enableSuggestions: false,
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            onSaved: (value) {
              _userEmail = value ?? '';
            },
          ),
          if (!_isLogin) ...[
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('username'),
              decoration: InputDecoration(
                labelText: 'Full Name',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              autocorrect: true,
              textCapitalization: TextCapitalization.words,
              enableSuggestions: false,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
              onSaved: (value) {
                _userName = value ?? '';
              },
            ),
          ],
          const SizedBox(height: 16),
          TextFormField(
            key: const ValueKey('password'),
            decoration: InputDecoration(
              labelText: 'Password',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 7) {
                return 'Password must be at least 7 characters';
              }
              return null;
            },
            onSaved: (value) {
              _userPassword = value ?? '';
            },
          ),
          if (_isLogin)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.fingerprint,
                      size: 36, color: Color(0xFFB31217)),
                  onPressed: _authenticateWithBiometrics,
                  tooltip: 'Login with fingerprint',
                ),
              ),
            ),
          if (_isLogin)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showForgotPasswordDialog,
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(color: Color(0xFFB31217)),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Image.asset(
                  'assets/images/google_logo.png',
                  height: 24,
                  width: 24,
                ),
                label: const Flexible(
                  child: Text(
                    'Continue with Google',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  side: const BorderSide(color: Colors.black12),
                ),
                onPressed: _isGoogleLoading ? null : _signInWithGoogle,
              ),
            ),
          ),
          const SizedBox(height: 16),
          widget.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB31217),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _trySubmit,
                    child: Text(
                      _isLogin ? 'SIGN IN' : 'SIGN UP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isLogin
                    ? "Don't have an account?"
                    : "Already have an account?",
                style: const TextStyle(color: Colors.black54),
              ),
              TextButton(
                onPressed: _toggleMode,
                child: Text(
                  _isLogin ? 'Sign up' : 'Sign in',
                  style: const TextStyle(color: Color(0xFFB31217)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
