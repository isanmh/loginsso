import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(const MyApp());
}

// variable global untuk menyimpan instance dari GoogleSignIn
GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // kita sudah punya kelas google sign in
  GoogleSignInAccount? _currentUser;

  // method untuk handle sign in
  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
      // snackbar jika berhasil sign in
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign in success'),
        ),
      );
    } catch (error) {
      print(error);
    }
  }

  // init state untuk mengecek apakah user sudah sign in
  @override
  void initState() {
    _googleSignIn.onCurrentUserChanged.listen(
      (event) {
        setState(() {
          _currentUser = event;
        });
        // sign in silently jika user sudah sign in
        _googleSignIn.signInSilently();
      },
      onError: (error) {
        print(error);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // jika user belum sign in, maka tampilkan login
        title: _currentUser == null ? Text('Login') : Text('Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      // jika user belum sign in, maka tampilkan button login
      body: _currentUser == null
          ? Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _handleSignIn();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.network(
                          'https://developers.google.com/identity/images/g-logo.png',
                          height: 30,
                        ),
                        const SizedBox(width: 10),
                        Text('Sign in with Google '),
                      ],
                    ),
                  ),
                ],
              ),
            )
          // jika user sudah sign in, maka tampilkan data user
          : Center(
              child: ListTile(
                leading: GoogleUserCircleAvatar(
                  identity: _currentUser!,
                ),
                title: Text(_currentUser!.displayName ?? ''),
                subtitle: Text(_currentUser!.email),
                trailing: IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () {
                    _googleSignIn.signOut();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sign out success'),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
