import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  TextEditingController emailController;
  TextEditingController passwordController;
  FocusNode _focusNodePassword = FocusNode();
  FocusNode _focusNodeEmail = FocusNode();

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void _signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    print(googleUser);
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.getCredential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    var result = await _firebaseAuth.signInWithCredential(credential);

    if (result != null) {
      setState(() {
        isAuth = true;
      });
    }
  }

  void logUserOut() async {
    await _firebaseAuth.signOut();

    setState(() {
      isAuth = false;
    });
  }

  @override
  void initState() {
    super.initState();
    checkUserAlreadyLoggedIn();
  }

  void checkUserAlreadyLoggedIn() {
    _firebaseAuth.onAuthStateChanged.listen((user) {
      if (user != null) {
        setState(() {
          isAuth = true;
        });
      } else {
        setState(() {
          isAuth = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthenticated();
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes Home"),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.exit_to_app,
                size: 40,
              ),
              onPressed: () {
                logUserOut();
              })
        ],
      ),
      body: Center(
        child: Text("You have Logged In"),
      ),
    );
  }

  Scaffold buildUnAuthenticated() {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.teal, Colors.purple])),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Firebase NotesApp",
              style: GoogleFonts.lato(
                  textStyle: TextStyle(
                      fontSize: 40.0, color: Colors.white, letterSpacing: .5)),
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () {
                _signInWithGoogle();
              },
              child: Container(
                width: 260,
                height: 60,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image:
                          AssetImage("assets/images/google_signin_button.png"),
                      fit: BoxFit.cover),
                ),
                child: Text(""),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: emailController,
                    focusNode: _focusNodeEmail,
                    decoration: InputDecoration(hintText: "User Email"),
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(_focusNodePassword);
                    },
                  ),
                  TextFormField(
                    controller: passwordController,
                    focusNode: _focusNodePassword,
                    decoration: InputDecoration(hintText: "Password"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
