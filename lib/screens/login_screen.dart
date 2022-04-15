import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hostessrestaurant/api/login_api.dart';
import 'package:hostessrestaurant/global/colors.dart';
import 'package:hostessrestaurant/models/user.dart';
import 'package:hostessrestaurant/notifier/auth_notifier.dart';
import 'package:provider/provider.dart';

enum AuthMode { Login }

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscure1 = true;
  bool _enter = false;
  User _user = User();

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    initializeCurrentUser(authNotifier);
    super.initState();
  }

  _login(User user, AuthNotifier authNotifier) async {
    AuthResult authResult = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: user.email, password: user.password)
        .catchError((error) {
      print(error.code);
      setState(() => _enter = !_enter);
      _showErrorLogin(error.code);
    });

    if (authResult != null) {
      FirebaseUser firebaseUser = authResult.user;

      if (firebaseUser != null) {
        print("Log In: $firebaseUser");
        authNotifier.setUser(firebaseUser);
      }
    }
  }

  _submitForm() {
    if (!_formKey.currentState.validate()) {
      return;
    }
    setState(() => _enter = !_enter);

    _formKey.currentState.save();

    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);

    _login(_user, authNotifier);
  }

  _showErrorLogin(String error) {
    Widget okButton = FlatButton(
      child: Text('OK'),
      onPressed: () => Navigator.pop(context),
    );
    AlertDialog alert = AlertDialog(
      title: Text('Ошибка'),
      content: Text(
        error == 'ERROR_WRONG_PASSWORD'
            ? 'Неверный Email или Пароль. Проверьте правильность ввода.'
            : 'Аккаунта с таким Email ещё не существует.',
      ),
      actions: [okButton],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildEmailField() {
      return TextFormField(
        decoration: InputDecoration(
          labelText: "Email",
          labelStyle: TextStyle(color: Colors.black54),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black12),
          ),
        ),
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(fontSize: 18, color: t_primary),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Email обязателен';
          }

          if (!RegExp(
                  r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
              .hasMatch(value)) {
            return 'Пожалуйста введите Email корректно';
          }

          return null;
        },
        onChanged: (String value) {
          _user.email = value;
        },
      );
    }

    Widget _buildPasswordField() {
      return TextFormField(
        decoration: InputDecoration(
          labelText: 'Пароль',
          labelStyle: TextStyle(color: Colors.black54),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black12),
          ),
          suffixIcon: IconButton(
            onPressed: () {
              setState(() => _obscure1 = !_obscure1);
            },
            icon: Icon(_obscure1 ? Icons.visibility : Icons.visibility_off),
          ),
        ),
        style: TextStyle(fontSize: 18, color: t_primary),
        obscureText: _obscure1,
        controller: _passwordController,
        validator: (String value) {
          if (value.isEmpty) {
            return 'Пароль обязателен';
          }

          if (value.length < 6) {
            return 'Пароль должен быть не менее 6 символов';
          }

          return null;
        },
        onChanged: (String value) {
          _user.password = value;
        },
      );
    }

    return Scaffold(
      backgroundColor: c_secondary,
      body: Stack(
        children: [
          Image.asset(
            'assets/login.jpg',
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.30,
            fit: BoxFit.cover,
          ),
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.30,
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.black.withAlpha(0),
                  Colors.black12,
                  Colors.black87,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                Text(
                  'Вход',
                  style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
            constraints: BoxConstraints.expand(
              height: double.infinity,
            ),
            decoration: BoxDecoration(
              color: c_background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
            ),
            child: Form(
              autovalidate: true,
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(42.0, 35.0, 42.0, 42.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildEmailField(),
                    _buildPasswordField(),
                    SizedBox(height: 32),
                    Align(
                      alignment: Alignment.center,
                      child: FloatingActionButton.extended(
                        backgroundColor: c_secondary,
                        elevation: 0.0,
                        icon: Icon(Icons.person),
                        label: Text(
                          'ВХОД',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () => _submitForm(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _enter == true
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black54,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpinKitWave(
                        color: Colors.white,
                        size: 50.0,
                      ),
                      Text(
                        'Подключаемся',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
