import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moa_final_project/main.dart';


class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),

      body: const LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _authentication = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              onChanged: (value){
                email = value;
              },
            ),
            const SizedBox(height: 20.0,),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              onChanged: (value){
                password = value;
              },
            ),
            const SizedBox(height: 20.0,),
            ElevatedButton(
                onPressed: () async {
                  try{
                    final currentUser = await _authentication.signInWithEmailAndPassword(
                        email: email,
                        password: password
                    );
                    if (currentUser.user != null){
                      _formKey.currentState!.reset();
                      if (!mounted) return;
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Week_MonthHome()));
                    }
                  } catch(e){
                    print(e);
                    String message = '사용자가 존재하지 않거나, 틀린 비밀번호입니다.';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: Colors.deepOrange,
                      ),
                    );
                  }
                },
                child: const Text('Enter')
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('If you did not register,'),
                TextButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                    },
                    child: const Text('Register your email')
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),

      body: const RegisterForm(),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _authentication = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              onChanged: (value){
                email = value;
              },
            ),
            const SizedBox(height: 20.0,),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              onChanged: (value){
                password = value;
              },
            ),
            const SizedBox(height: 20.0,),
            ElevatedButton(
                onPressed: () async {
                  try{
                    final newUser = await _authentication.createUserWithEmailAndPassword(
                        email: email,
                        password: password
                    );

                    if (newUser.user != null){
                      _formKey.currentState!.reset();
                      if (!mounted) return;
                      String message = '회원가입에 성공했습니다.';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          backgroundColor: Colors.lightBlue,
                        ),
                      );
                    }
                  }
                  catch (e){
                    print(e);
                  }
                },
                child: const Text('Enter')
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('If you already registered,'),
                TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: const Text('Log in with your email')
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}