import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {

  @override
  State createState() => _State();
}

class _State extends State {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  String? validateEmail(String? value){
    String pattern = r'.+@.+\..+';

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
    return null;
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

  void navigateToHomePage(){
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (builder) => HomePage()),
          (route) => false
    );
  }

  void navigateToSignUpPage(){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (builder) => SignUpPage()),
    );
  }

  void onPressedLoginButton() async {
    if(_formKey.currentState!.validate()){
      try {
        String email = emailController.text;
        String password = passwordController.text;
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email, password: password);
        navigateToHomePage();
      }
      on FirebaseAuthException catch(e){
        if(e.code == 'user-not-found'){
          showSnackBar('That Email is not registered');
        }
        else if(e.code == 'wrong-password'){
          showSnackBar("Wrong password.");
        }
        else{
          print(e.code);
          showSnackBar("Can't connect, please try again later.");
        }
      }
    }
  }


  Form loginForm(){
    return Form(
      key: _formKey,
      child: Column(
        children: [

          // Email Form Field
          TextFormField(
            controller: emailController,
            validator: validateEmail,
            decoration: const InputDecoration(
                labelText: "Email",
                hintText: "user@example.com"
            ),
          ),

          // password Form Field
          TextFormField(
            controller: passwordController,
            validator: validatePassword,
            obscureText: true,
            decoration: const InputDecoration(
                labelText: "Password",
                hintText: "Password"
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Login button
              ElevatedButton(
                  onPressed: onPressedLoginButton,
                  child: const Text("Login")
              ),

              // Sign Up button
              ElevatedButton(
                  onPressed: navigateToSignUpPage,
                  child: const Text("Sign Up")
              ),

            ],
          ),


        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Text(
                "HealthSmart",
                style: Theme.of(context).textTheme.displayMedium,
              ),

              const Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Image(
                  image: AssetImage("assets/logo.png"),
                  width: 250,
                  height: 250,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: loginForm(),
              ),

            ],
          )
        ),
      )
    );
  }

}
