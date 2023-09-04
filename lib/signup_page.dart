import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home_page.dart';

class SignUpPage extends StatefulWidget {

  @override
  State createState() => _State();
}

class _State extends State {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController = TextEditingController();

  String eulaText = "";

  bool submitLock = false;

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  void navigateToHomeScreen(){
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (builder) => HomePage()),
            (route) => false
    );
  }

  void showSnackBar(String message){
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.yellow,
            onPressed: (){ ScaffoldMessenger.of(context).hideCurrentSnackBar(); } ,
          ),
        )
    );
  }


  String? validateEmail(String? value){
    String pattern = r'.+@.+\..';
    if(value == null || value.isEmpty){
      return "Please enter your Email";
    }
    else if ( ! RegExp(pattern).hasMatch(value) ){
      return "Please enter a valid Email";
    }
    return null;
  }


  String? validatePassword(String? value){
    if(value == null || value.isEmpty){
      return "Please enter your Password";
    }
    else if( value.length < 6 || value.length > 18 ) {
      return "Please enter a password between 6 and 18 characters";
    }
    return null;
  }


  String? validateConfirmPassword(String? value){
    if(value == null || value.isEmpty){
      return "Please enter your Password";
    }
    else if( value != passwordController.text ) {
      return "Your passwords do not match";
    }
    return null;
  }


  Future<void> loadEULAtext() async {
    eulaText = await rootBundle.loadString('assets/eula.txt');
  }


  Future<void> showEulaDialog() async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: const Text("End-User License Agreement (EULA)"),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text(eulaText)
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('No'),
                onPressed: (){ Navigator.of(context).pop(); },
              ),
              TextButton(
                child: const Text('Agree'),
                onPressed: signUpToFirebase,
              )
            ],
          );
        }
    );
  }

  Future<void> createUserData(String uid) async {
    String path = "user_data/$uid";
    DatabaseReference ref = FirebaseDatabase.instance.ref(path);

    // age: -1 means unspecified
    // sex: -1 unspecified, 0 male, 1 female
    var userData = {
      "age": -1,
      "sex": -1,
      "ethnicity": "unspecified",
      "race": "unspecified",
    };
    await ref.update(userData);
  }

  void signUpToFirebase() async {
    String email = emailController.text;
    String password = passwordController.text;

    try {
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await createUserData(userCred.user!.uid);

      navigateToHomeScreen();
    }
    on FirebaseAuthException catch (e){
      if(e.code == "weak-password"){
        showSnackBar("The provided password is too weak.");
      }
      else if (e.code == 'email-already-in-use') {
        showSnackBar("That email is already in use.");
      }
      else if (e.code == 'invalidEmail') {
        showSnackBar("The provided email is invalid.");
      }
      else{
        print(e.code);
        showSnackBar("Unknown Error.");
      }
      Navigator.of(context).pop();
    }
  }

  void onPressSignUpButton() async {
    if(submitLock) { return; }

    submitLock = true;

    if( _formKey.currentState!.validate() ){
      await loadEULAtext();
      await showEulaDialog();
    }

    submitLock = false;
  }

  Widget signUpForm(){
    return Form(
      key: _formKey,
      child: Column(
        children: [

          // Email Input
          TextFormField(
            controller: emailController,
            validator: validateEmail,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'user@example.com',
              prefixIcon: Icon(Icons.email),
            ),
          ),

          // Password Input
          TextFormField(
            controller: passwordController,
            validator: validatePassword,
            obscureText: !_showPassword,
            decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                      Icons.remove_red_eye,
                      color: _showPassword ? Theme.of(context).primaryColor : Colors.grey
                  ),
                  onPressed: (){
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                )
            ),
          ),

          // Confirm Password Input
          TextFormField(
            controller: passwordConfirmController,
            validator: validateConfirmPassword,
            obscureText: !_showConfirmPassword,
            decoration: InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                      Icons.remove_red_eye,
                      color: _showConfirmPassword ? Theme.of(context).primaryColor : Colors.grey
                  ),
                  onPressed: (){
                    setState(() {
                      _showConfirmPassword = !_showConfirmPassword;
                    });
                  },
                )
            ),
          ),

          ElevatedButton(
              onPressed: onPressSignUpButton,
              child: const Text("Sign Up")
          )

        ],
      ),
    );
  }

  @override
  Widget build(context){
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sign Up'),
        ),
        body: signUpForm()
    );
  }

}