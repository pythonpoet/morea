import 'package:flutter/material.dart';
import '../services/auth.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.auth, this.onSignedIn});

  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

enum FormType { login, register }
enum authProblems { UserNotFound, PasswordNotValid, NetworkError }
enum Platform { isAndroid, isIOS }

class _LoginPageState extends State<LoginPage> {
  Auth auth0 = new Auth();

  final formKey = new GlobalKey<FormState>();
  final resetkey = new GlobalKey<FormState>();

  String _email,
      _pfadinamen = ' ',
      _vorname,
      _nachname,
      _stufe,
      _selectedstufe = 'Stufe wählen';
  String _password, _adresse, _ort, _plz, _handynummer, _passwordneu;
  FormType _formType = FormType.login;
  Platform _platform = Platform.isAndroid;
  List<String> _stufenselect = [
    'Biber',
    'Wombat (Wölfe)',
    'Nahani (Meitli)',
    'Drason (Buebe)',
    'Pios'
  ];
  String error;

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void validateAndSubmit() async {
    Platform.isAndroid;
    if (validateAndSave()) {
      try {
        if (_formType == FormType.login) {
          String userId =
              await widget.auth.signInWithEmailAndPassword(_email, _password);
          print('Sign in: ${userId}');
          widget.onSignedIn();
        } else {
          if (_password == _passwordneu) {
            if (_selectedstufe != 'Stufe wählen') {
              String userId = await widget.auth
                  .createUserWithEmailAndPassword(_email, _password);
              print('Registered user: ${userId}');
              if (userId != null) {
                widget.auth.createUserInformation(mapUserData());
                widget.onSignedIn();
              }
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Bitte eine Stufe wählen!"),
                  );
                },
              );
            }
          } else {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: new Text("Passwörter sind nicht identisch"),
                  );
                });
          }
        }
      } catch (e) {
        print('$e');
        authProblems errorType;
        if (_platform == Platform.isAndroid) {
          switch (e.message) {
            case 'There is no user record corresponding to this identifier. The user may have been deleted.':
              errorType = authProblems.UserNotFound;
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: new Text("Login"),
                      content: new Text('Du bist noch nicht registriert'),
                    );
                  });
              break;
            case 'The password is invalid or the user does not have a password.':
              errorType = authProblems.PasswordNotValid;
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: new Text("Login"),
                      content: new Text('Falsches Passwort'),
                    );
                  });
              break;
            case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
              errorType = authProblems.NetworkError;
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: new Text("Login"),
                      content: new Text('Keine Internet Verbindung'),
                    );
                  });
              break;
            // ...
            default:
              print('Case ${e.message} is not jet implemented');
          }
        } else if (_platform == Platform.isIOS) {
          switch (e.code) {
            case 'Error 17011':
              errorType = authProblems.UserNotFound;
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: new Text("Login"),
                      content: new Text('Du bist noch nicht registriert'),
                    );
                  });
              break;
            case 'Error 17009':
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: new Text("Login"),
                      content: new Text('Falsches Passwort'),
                    );
                  });
              errorType = authProblems.PasswordNotValid;
              break;
            case 'Error 17020':
              errorType = authProblems.NetworkError;
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: new Text("Login"),
                      content: new Text('Keine Internet Verbindung'),
                    );
                  });
              break;
            // ...
            default:
              print('Case ${e.message} is not jet implemented');
          }
        }
        print('The error is $errorType');
      }
    }
  }

  void moveToRegister() {
    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    setState(() {
      _formType = FormType.login;
    });
  }

  void passwortreset() async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => new AlertDialog(
            contentPadding: const EdgeInsets.all(16.0),
            content: new Row(
              children: <Widget>[
                new Expanded(
                  child: new TextField(
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    decoration: new InputDecoration(
                      labelText: 'Passwort zurücksetzen',
                      hintText: 'z.B. maxi@stinkt.undso',
                    ),
                    onChanged: (String value) {
                      this._email = value;
                    },
                  ),
                )
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('CANCEL'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('Zurücksetzen'),
                  onPressed: () {
                    Navigator.pop(context);
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: new Text(
                                'Sie haben ein Passwortzurücksetzungsemail auf die Emailadresse: $_email erhalten'),
                          );
                        });
                    auth0.sendPasswordResetEmail(_email);
                  })
            ],
          ),
    );
  }

  Map mapUserData() {
    Map<String, String> userInfo = {
      'Pfadinamen': this._pfadinamen,
      'Vorname': this._vorname,
      'Nachname': this._nachname,
      'Stufe': this._selectedstufe,
      'Adresse': this._adresse,
      'PLZ': this._plz,
      'Ort': this._ort,
      'Handynummer': this._handynummer,
      'Pos': 'Teilnehmer',
    };
    return userInfo;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Pfadi Morea'),
        ),
        body: new SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: new Form(
            key: formKey,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: buildInputs() + buildSubmitButtons()),
          ),
        ));
  }

  List<Widget> buildInputs() {
    if (_formType == FormType.login) {
      return [
        new TextFormField(
          decoration: new InputDecoration(labelText: 'Email'),
          validator: (value) =>
              value.isEmpty ? 'Email darf nicht leer sein' : null,
          keyboardType: TextInputType.emailAddress,
          onSaved: (value) => _email = value,
        ),
        new TextFormField(
          decoration: new InputDecoration(labelText: 'Password'),
          validator: (value) =>
              value.isEmpty ? 'Passwort darf nicht leer sein' : null,
          obscureText: true,
          onSaved: (value) => _password = value,
        ),
      ];
    } else {
      return [
        new TextFormField(
          decoration: new InputDecoration(
            border: UnderlineInputBorder(),
            filled: true,
            icon: Icon(Icons.perm_identity),
            labelText: 'Pfadinamen',
          ),
          onSaved: (value) => _pfadinamen = value,
        ),
        new TextFormField(
          decoration: new InputDecoration(
              border: UnderlineInputBorder(),
              filled: true,
              icon: Icon(Icons.person),
              labelText: 'Vorname'),
          validator: (value) =>
              value.isEmpty ? 'Vornamen darf nicht leer sein' : null,
          keyboardType: TextInputType.text,
          onSaved: (value) => _vorname = value,
        ),
        new TextFormField(
          decoration: new InputDecoration(
              border: UnderlineInputBorder(),
              filled: true,
              icon: Icon(Icons.person),
              labelText: 'Nachname'),
          validator: (value) =>
              value.isEmpty ? 'Nachname darf nicht leer sein' : null,
          keyboardType: TextInputType.text,
          onSaved: (value) => _nachname = value,
        ),
        new DropdownButton<String>(
            items: _stufenselect.map((String val) {
              return new DropdownMenuItem<String>(
                value: val,
                child: new Text(val),
              );
            }).toList(),
            hint: Text(_selectedstufe),
            onChanged: (newVal) {
              _selectedstufe = newVal;
              this.setState(() {});
            }),
        new TextFormField(
          decoration: new InputDecoration(
              border: UnderlineInputBorder(),
              filled: true,
              icon: Icon(Icons.home),
              labelText: 'Adresse'),
          keyboardType: TextInputType.text,
          onSaved: (value) => _adresse = value,
        ),
        new Row(
          children: <Widget>[
            Expanded(
                child: new TextFormField(
              decoration: new InputDecoration(
                  border: UnderlineInputBorder(),
                  filled: true,
                  icon: Icon(Icons.home),
                  labelText: 'PLZ'),
              keyboardType: TextInputType.text,
              onSaved: (value) => _plz = value,
            )),
            Expanded(
              child: new TextFormField(
                decoration: new InputDecoration(
                    border: UnderlineInputBorder(),
                    filled: true,
                    labelText: 'Ort'),
                keyboardType: TextInputType.text,
                onSaved: (value) => _ort = value,
              ),
            ),
          ],
        ),
        new TextFormField(
          decoration: new InputDecoration(
              border: UnderlineInputBorder(),
              filled: true,
              icon: Icon(Icons.phone),
              labelText: 'Handy nummer'),
          validator: (value) =>
              value.isEmpty ? 'Handynummer darf nicht leer sein' : null,
          keyboardType: TextInputType.phone,
          onSaved: (value) => _handynummer = value,
        ),
        new TextFormField(
          decoration: new InputDecoration(
              border: UnderlineInputBorder(),
              filled: true,
              icon: Icon(Icons.email),
              labelText: 'Email'),
          validator: (value) =>
              value.isEmpty ? 'Email darf nicht leer sein' : null,
          keyboardType: TextInputType.emailAddress,
          onSaved: (value) => _email = value,
        ),
        new TextFormField(
          decoration: new InputDecoration(
              border: UnderlineInputBorder(),
              filled: true,
              icon: Icon(Icons.vpn_key),
              labelText: 'Password'),
          validator: (value) =>
              value.isEmpty ? 'Passwort darf nicht leer sein' : null,
          obscureText: true,
          onSaved: (value) => _password = value,
        ),
        new TextFormField(
          decoration: new InputDecoration(
              border: UnderlineInputBorder(),
              filled: true,
              icon: Icon(Icons.vpn_key),
              labelText: 'Password erneut eingeben'),
          validator: (value) =>
              value.isEmpty ? 'Passwort darf nicht leer sein' : null,
          obscureText: true,
          onSaved: (value) => _passwordneu = value,
        ),
      ];
    }
  }

  List<Widget> buildSubmitButtons() {
    if (_formType == FormType.login) {
      return [
        new RaisedButton(
          child: new Text('Login', style: new TextStyle(fontSize: 20)),
          onPressed: validateAndSubmit,
        ),
        new FlatButton(
          child: new Text(
            'Create an account',
            style: new TextStyle(fontSize: 20),
          ),
          onPressed: moveToRegister,
        ),
        new FlatButton(
          child: new Text(
            'Passwort vergessen?',
            style: new TextStyle(fontSize: 15),
          ),
          onPressed: passwortreset,
        )
      ];
    } else {
      return [
        new RaisedButton(
          child:
              new Text('Create an account', style: new TextStyle(fontSize: 20)),
          onPressed: validateAndSubmit,
        ),
        new FlatButton(
          child: new Text(
            'have an account?',
            style: new TextStyle(fontSize: 20),
          ),
          onPressed: moveToLogin,
        ),
      ];
    }
  }
}
