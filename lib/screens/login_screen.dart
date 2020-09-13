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

enum AuthMode { Signup, Login }

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscure1 = true, _obscure2 = true;
  bool _enter = false;
  AuthMode _authMode = AuthMode.Login;
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

  void _submitForm() {
    if (!_formKey.currentState.validate()) {
      return;
    }
    setState(() => _enter = !_enter);

    _formKey.currentState.save();

    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);

    if (_authMode == AuthMode.Login) {
      _login(_user, authNotifier);
    } else {
      _signUp(_user, authNotifier);
    }
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

  _signUp(User user, AuthNotifier authNotifier) async {
    AuthResult authResult = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: user.email, password: user.password)
        .catchError((error) {
      print(error.code);
      setState(() => _enter = !_enter);
      _showErrorSignIn();
    });

    if (authResult != null) {
      UserUpdateInfo updateInfo = UserUpdateInfo();
      updateInfo.displayName = user.displayName;

      FirebaseUser firebaseUser = authResult.user;

      if (firebaseUser != null) {
        await firebaseUser.updateProfile(updateInfo);

        await firebaseUser.reload();

        print("Sign up: $firebaseUser");

        FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
        authNotifier.setUser(currentUser);
      }
    }
  }

  _showErrorLogin(String error) {
    Widget okButton = FlatButton(
      child: Text('OK'),
      onPressed: () => Navigator.pop(context),
    );
    AlertDialog alert = AlertDialog(
      title: Text('Ошибка'),
      content: Text(error == 'ERROR_WRONG_PASSWORD'
          ? 'Неверный Email или Пароль. Проверьте правильность ввода.'
          : 'Аккаунта с таким Email ещё не существует.'),
      actions: [okButton],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _showErrorSignIn() {
    Widget okButton = FlatButton(
      child: Text('OK'),
      onPressed: () => Navigator.pop(context),
    );
    AlertDialog alert = AlertDialog(
      title: Text('Ошибка'),
      content: Text('Такой Email уже используется. Попробуйте выполнить вход'),
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
    return Scaffold(
      backgroundColor: c_secondary,
      body: Stack(
        children: [
          Image.asset(
            'assets/login.jpg',
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.40,
            fit: BoxFit.cover,
          ),
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.40,
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                Text(
                  _authMode == AuthMode.Login ? 'Вход' : 'Регистрация',
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
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.35),
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
                    _authMode == AuthMode.Signup
                        ? _buildDisplayNameField()
                        : Container(),
                    _buildEmailField(),
                    _buildPasswordField(),
                    _authMode == AuthMode.Signup
                        ? _buildConfirmPasswordField()
                        : Container(),
                    SizedBox(height: 32),
                    Align(
                      alignment: Alignment.center,
                      child: FloatingActionButton.extended(
                        backgroundColor: c_secondary,
                        elevation: 0.0,
                        icon: Icon(_authMode == AuthMode.Login
                            ? Icons.person
                            : Icons.person_add),
                        label: Text(
                          _authMode == AuthMode.Login ? 'ВХОД' : 'РЕГИСТРАЦИЯ',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () => _submitForm(),
                      ),
                    ),
                    SizedBox(height: 42),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _authMode == AuthMode.Login
                              ? 'Ещё нет аккаунта?'
                              : 'Уже есть аккаунт?',
                          style: TextStyle(
                            color: t_primary,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _authMode = _authMode == AuthMode.Login
                                  ? AuthMode.Signup
                                  : AuthMode.Login;
                            });
                          },
                          child: Text(
                            _authMode == AuthMode.Login
                                ? 'Регистрация'
                                : 'Войти',
                            style: TextStyle(
                              color: c_primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildDisplayNameField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Название заведения',
        labelStyle: TextStyle(color: Colors.black54),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black12),
        ),
        helperText: 'Нельзя будет изменить в дальнейшем!',
        helperStyle: TextStyle(color: Colors.redAccent),
      ),
      keyboardType: TextInputType.text,
      style: TextStyle(fontSize: 18, color: t_primary),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Название заведения обязательно';
        }

        if (value.length < 2 || value.length > 30) {
          return 'Название не может быть короче 2 символов';
        }

        return null;
      },
      onChanged: (String value) {
        _user.displayName = value;
      },
    );
  }

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

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Подтвердите пароль",
        labelStyle: TextStyle(color: Colors.black54),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black12),
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() => _obscure2 = !_obscure2);
          },
          icon: Icon(_obscure2 ? Icons.visibility : Icons.visibility_off),
        ),
      ),
      style: TextStyle(fontSize: 18, color: t_primary),
      obscureText: _obscure2,
      validator: (String value) {
        if (_passwordController.text != value) {
          return 'Пароли не совпадают';
        }

        return null;
      },
    );
  }
}
