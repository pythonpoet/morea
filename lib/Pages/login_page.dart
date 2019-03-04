import 'package:flutter/material.dart';
import '../services/auth.dart';



class LoginPage extends StatefulWidget{
  LoginPage({this.auth, this.onSignedIn});
  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => new _LoginPageState();
  }

  enum FormType {
   login,
    register
  }

  class _LoginPageState extends State<LoginPage> {

    final formKey = new GlobalKey<FormState>();

    String _email, _pfadinamen, _vorname, _nachname, _stufe,_selectedstufe;
    String _password;
    FormType _formType = FormType.login;
    List<String> _stufenselect = ['Biber', 'Wölfe', 'Nahnanis','Drason','Pios'];

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
      if (validateAndSave()) {
        try {
          if (_formType == FormType.login) {
            String userId = await widget.auth.signInWithEmailAndPassword(
                _email, _password);
            print('Sign in: ${userId}');
          } else {
            String userId = await widget.auth.createUserWithEmailAndPassword(
                _email, _password);
            print('Registered user: ${userId}');
            widget.auth.createUserInformation(mapUserData());
          }
          widget.onSignedIn();
        }
        catch (e) {
          print('Error: $e');
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

    Map mapUserData(){
      Map<String, String> userInfo ={
        'Pfadinamen': this._pfadinamen,
        'Vorname': this._vorname,
        'Nachname': this._nachname,
        'Stufe': this._selectedstufe
      };
      return userInfo;
    }

    @override
    Widget build(BuildContext context) {
      // TODO: implement build
      return new Scaffold(
          appBar: new AppBar(
            title: new Text('Flutter login demo'),
          ),
          body: new SingleChildScrollView(
            child: new Form(
              key: formKey,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: buildInputs() + buildSubmitButtons()
              ),
            ),
          ) /*
      new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: formKey,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: buildInputs() + buildSubmitButtons(),
        ),
      ),
    ),*/
      );
    }
    List<Widget> buildInputs(){
      if(_formType == FormType.login) {
        return [
          new TextFormField(
            decoration: new InputDecoration(labelText: 'Email'),
            validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
            keyboardType: TextInputType.emailAddress,
            onSaved: (value) => _email = value,
          ),
          new TextFormField(
            decoration: new InputDecoration(labelText: 'Password'),
            validator: (value) =>
            value.isEmpty
                ? 'Password can\'t be empty'
                : null,
            obscureText: true,
            onSaved: (value) => _password = value,
          ),
        ];
      }else{
        return[
          new TextFormField(
            decoration: new InputDecoration(labelText: 'Email'),
            validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
            keyboardType: TextInputType.emailAddress,
            onSaved: (value) => _email = value,
          ),
          new TextFormField(
            decoration: new InputDecoration(labelText: 'Password'),
            validator: (value) =>
            value.isEmpty
                ? 'Password can\'t be empty'
                : null,
            obscureText: true,
            onSaved: (value) => _password = value,
          ),
          new TextFormField(
            decoration: new InputDecoration(labelText: 'Pfadinamen'),
            validator: (value) =>
            value.isEmpty
                ? 'Pfadinamen can\'t be empty'
                : null,
            keyboardType: TextInputType.text,
            onSaved: (value) => _pfadinamen = value,
          ),
          new TextFormField(
            decoration: new InputDecoration(labelText: 'Vorname'),
            validator: (value) =>
            value.isEmpty
                ? 'Pfadinamen can\'t be empty'
                : null,
            keyboardType: TextInputType.text,
            onSaved: (value) => _vorname = value,
          ),
          new TextFormField(
            decoration: new InputDecoration(labelText: 'Nachname'),
            validator: (value) =>
            value.isEmpty
                ? 'Pfadinamen can\'t be empty'
                : null,
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
              hint: Text('Stufe wählen'),
              onChanged: (newVal) {
                _selectedstufe = newVal;
                this.setState(() {});
              })

        ];
      }
    }
    List<Widget> buildSubmitButtons(){
      if(_formType == FormType.login){
        return[
          new RaisedButton(
            child: new Text('Login',style: new TextStyle(fontSize: 20)),
            onPressed: validateAndSubmit,
          ),
          new FlatButton(
            child: new Text('Create an account', style: new TextStyle(fontSize: 20),),
            onPressed: moveToRegister,)
        ];
      }else{
        return[
          new RaisedButton(
            child: new Text('Create an account',style: new TextStyle(fontSize: 20)),
            onPressed: validateAndSubmit,
          ),
          new FlatButton(
            child: new Text('have an account?', style: new TextStyle(fontSize: 20),),
            onPressed: moveToLogin,)
        ];
      }

    }
  }