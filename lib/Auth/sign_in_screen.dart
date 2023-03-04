import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:labtest/Auth/sign_up_screen.dart';
import 'package:labtest/main.dart';



class SignInScreen extends StatefulWidget {
  const SignInScreen({ Key? key }) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

 Future<String?> mailSignIn(String mail, String pwd) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(email: mail, password: pwd);
    Fluttertoast.showToast(msg: "Sign In Success");
    Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context) =>  MyHomePage(title: 'My TO - DO List'),
        ),
      );
    return null;
  } on FirebaseAuthException catch (ex) {
    print("Error ${ex.code} ${ex.message}");
    return "${ex.code}: ${ex.message}";
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Sign Up"),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Container(
                padding: const EdgeInsets.all(20),
                height: 350,
                width: MediaQuery.of(context).size.width * 0.9 ,              
                decoration: BoxDecoration(                
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Center(
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,                      
                        ),
                      ),                  
                    ),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        hintText: 'Enter Email',
                      ),
                    ),
                    const SizedBox(height: 20,),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        hintText: 'Enter Password',
                      ),
                    ),
                    const SizedBox(height: 20,),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              mailSignIn(emailController.text, passwordController.text);
                              emailController.clear();
                              passwordController.clear();
                            });
                          }, 
                          child: const Text('Sign In')                  
                      ),
                    ),
                    const SizedBox(height: 20,),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () {
                             Navigator.push(
                                context, 
                                MaterialPageRoute(
                                  builder: (context) => const SignUpScreen(),
                                ),
                              );                      
                          }, 
                          child: const Text('Want to Register? Sign Up...')                  
                      ),
                    )
                  ],
                ),
              ),
        ),
    );
  }

}