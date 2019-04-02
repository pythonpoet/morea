import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/bubble_indication_painter.dart';

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
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  final formKey = new GlobalKey<FormState>();
  final resetkey = new GlobalKey<FormState>();

  String _email,
      _pfadinamen = ' ',
      _vorname,
      _nachname,
      _stufe,
      _selectedstufe = 'Stufe wählen';
  String _password, _adresse, _ort, _plz, _handynummer, _passwordneu, userId,error;
  FormType _formType = FormType.login;
  Platform _platform = Platform.isAndroid;
  List<String> _stufenselect = [
    'Biber',
    'Wombat (Wölfe)',
    'Nahani (Meitli)',
    'Drason (Buebe)',
    'Pios'
  ];
  bool _load = false;

  PageController pageController;
  Color left = Colors.black;
  Color right = Colors.white;

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  updatedevtoken()async{
    List devtoken;
    await auth0.getUserInformation(userId).then((userInfo){
      try{
        List devtoken_old = userInfo.data['devtoken'];
        if(devtoken_old == null){
          firebaseMessaging.getToken().then((token){
          devtoken = [token];
          Map<String, List> devtokens ={
            'devtoken':devtoken
          };
          userInfo.data.addAll(devtokens);
          auth0.createUserInformation(userInfo.data);
        });
        }else{
          firebaseMessaging.getToken().then((token){
        if(devtoken_old[0] == 'leer'){
          devtoken = [token];
        }else{
          for(int i=0;i<devtoken_old.length;i++){
            if(devtoken_old[i]==token){
              return;
            }
          }
          devtoken = new List.from(devtoken_old)..add(token);
        }
        
        userInfo.data['devtoken'] = devtoken;

        auth0.createUserInformation(userInfo.data);
        });
        }
        

      }catch(e){
        
        print(e);
      }
       
    
    
    
    });
    
  }
  
          

  void validateAndSubmit() async {
    Platform.isAndroid;
    if (validateAndSave()) {
      try {
        if (_formType == FormType.login) {
          setState(() {
           _load =true; 
          });
         userId = await widget.auth.signInWithEmailAndPassword(_email, _password);
          print('Sign in: ${userId}');
          setState(() {
           _load = false; 
          });
          updatedevtoken();
          widget.onSignedIn();
           
        } else {
          if(_password.length >= 6){
            if (_password == _passwordneu){
            if (_selectedstufe != 'Stufe wählen') {
              setState(() {
           _load =true; 
            });
               userId = await widget.auth
                  .createUserWithEmailAndPassword(_email, _password);
              print('Registered user: ${userId}');
              if (userId != null) {
                widget.auth.createUserInformation(await mapUserData());
               setState(() {
              _load = false; 
              });
                widget.onSignedIn();
              }
            } else {
              showDialog(
                  context: context,
                  child: new AlertDialog(
                    title: new Text("Bitte eine Stufe wählen!"),
                  ));
            }
          } else {
            showDialog(
                context: context,
                child: new AlertDialog(
                  title: new Text("Passwörter sind nicht identisch"),
                ));
          }
          }else{
            showDialog(
                context: context,
                child: new AlertDialog(
                  title: new Text("Passwort muss aus mindistens 6 Zeichen bestehen"),
                ));
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
                  child: new AlertDialog(
                    title: new Text("Login"),
                    content: new Text('Du bist noch nicht registriert'),
                  ));
              break;
            case 'The password is invalid or the user does not have a password.':
              errorType = authProblems.PasswordNotValid;
              showDialog(
                  context: context,
                  child: new AlertDialog(
                    title: new Text("Login"),
                    content: new Text('Falsches Passwort'),
                  ));
              break;
            case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
              errorType = authProblems.NetworkError;
              showDialog(
                  context: context,
                  child: new AlertDialog(
                    title: new Text("Login"),
                    content: new Text('Keine Internet Verbindung'),
                  ));
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
                  child: new AlertDialog(
                    title: new Text("Login"),
                    content: new Text('Du bist noch nicht registriert'),
                  ));
              break;
            case 'Error 17009':
              showDialog(
                  context: context,
                  child: new AlertDialog(
                    title: new Text("Login"),
                    content: new Text('Falsches Passwort'),
                  ));
              errorType = authProblems.PasswordNotValid;
              break;
            case 'Error 17020':
              errorType = authProblems.NetworkError;
              showDialog(
                  context: context,
                  child: new AlertDialog(
                    title: new Text("Login"),
                    content: new Text('Keine Internet Verbindung'),
                  ));
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
                        child: new AlertDialog(
                          title: new Text(
                              'Sie haben ein Passwortzurücksetzungsemail auf die Emailadresse: $_email erhalten'),
                        ));
                    auth0.sendPasswordResetEmail(_email);
                  })
            ],
          ),
    );
  }

 Future<Map> mapUserData() async {
    var token = await firebaseMessaging.getToken();
         List devtoken = [token];
    Map<String, dynamic> userInfo = {
      'Pfadinamen': this._pfadinamen,
      'Vorname': this._vorname,
      'Nachname': this._nachname,
      'Stufe': this._selectedstufe,
      'Adresse': this._adresse,
      'PLZ': this._plz,
      'Ort': this._ort,
      'Handynummer': this._handynummer,
      'Pos': 'Teilnehmer',
      'UID': this.userId,
      'Email': this._email,
      'devtoken' : devtoken
    };
    return userInfo;
    
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }
  @override
  Widget build(BuildContext context) {
    Widget loadingIndicator =_load? new Container(
      width: 70.0,
      height: 70.0,
      child: new Padding(padding: const EdgeInsets.all(5.0),child: new Center(child: new CircularProgressIndicator())),
    ):new Container();

    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Pfadi Morea'),
          backgroundColor: Color(0xff7a62ff),
        ),
        body: Stack(
          children: <Widget>[
            Container(
          color: Colors.white70,
         child: new SingleChildScrollView(
          child: new Form(
            key: formKey,
            child: Container(
              width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height >= 900.0
                    ? MediaQuery.of(context).size.height
                    : 900.0,
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: buildInputs(),
            ),
            )
          ),
        )
        ),
        new Align(child: loadingIndicator,alignment: FractionalOffset.center,),
          ],
        ));
  }
  Widget buildMenuBar(BuildContext context){
    return Container(
      width: 300.0,
      height: 50.0,
      decoration: BoxDecoration(
        color:  Color(0xffff9262),
        borderRadius: BorderRadius.all(Radius.circular(25.0))
      ),
      child: CustomPaint(
        painter: TabIndicationPainter(pageController: pageController),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Flexible(
              fit: FlexFit.loose,
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed:  _registerAsTeilnehmer,
                child: Text(
                  'Teilnehmer',
                  style: TextStyle(
                    color: left,
                    fontSize: 16.0
                  )),
              ),
            ),
            Flexible(
              fit: FlexFit.loose,
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _registerAsElternteil,
                child: Text(
                  'Elternteil',
                  style: TextStyle(
                    color: right,
                    fontSize: 16.0
                  )),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> buildInputs() {
    if (_formType == FormType.login) {
      return [
        Container(
            padding: EdgeInsets.all(15.0),
            child: Column(
              children: <Widget>[
                new Image(
                  height: 200,
                  image: new AssetImage('assets/images/Logo_gross_weiss.jpeg'),
                ),
                new SizedBox(height: 34,),
                new TextFormField(
                  decoration: new InputDecoration(
                      labelText: 'Email',
                      border: UnderlineInputBorder(
                        borderSide: new BorderSide(
                          width: 4,
                          color: Colors.black
                        ),
                      ),
                    ),
                  validator: (value) =>
                      value.isEmpty ? 'Email darf nicht leer sein' : null,
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) => _email = value,
                ),
                new TextFormField(
                  decoration: new InputDecoration(
                    labelText: 'Passwort',
                    border: UnderlineInputBorder(
                      borderSide: new BorderSide(
                        color: Colors.black
                      )
                    ),
                    ),
                  validator: (value) =>
                      value.isEmpty ? 'Passwort darf nicht leer sein' : null,
                  obscureText: true,
                  onSaved: (value) => _password = value,
                ),
                SizedBox(height: 24,),
                Column(
                  children: buildSubmitButtons(),
                )
              ],
            ))
      ];
    } else {
      return [
          Padding(
              padding: EdgeInsets.only(top: 20),
              child: buildMenuBar(context),
                ),
          
               Expanded(

                      flex: 2,
                      child: PageView(
                        controller: pageController,
                        onPageChanged: (i) {
                          if (i == 0) {
                            setState(() {
                              right = Colors.white;
                              left = Colors.black;
                            });
                          } else if (i == 1) {
                            setState(() {
                              right = Colors.black;
                              left = Colors.white;
                            });
                          }
                        },
                        children: <Widget>[
                          Container(
                            child: Column(
                              children: <Widget>[
                                buildRegisterTeilnehmer(context),
                                Column(
                                  children: buildSubmitButtons()
                                  )
                               
                              ],
                            ),
                          ),
                             Center(
                                child: Text('A dere Stell chönt mer s Registragtionsformular fürd Eltere anefeze z.B', style: TextStyle(fontSize: 50),),
                              )
                        ],
                      ),
                    )
       
      ];
    }
  }
  Widget buildRegisterTeilnehmer(BuildContext context){
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
          children: <Widget>[
             Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Expanded(
              child: Icon(Icons.person),
              flex: 1,
            ),
            Expanded(
              flex: 9,
              child: Container(
          alignment: Alignment.center, //
          decoration: new BoxDecoration(
            border: new Border.all(color: Colors.black, width: 2),
            borderRadius: new BorderRadius.all(
              Radius.circular(4.0),
            ),
          ),
          child: Column(
            children: <Widget>[
              new TextFormField(
            decoration: new InputDecoration(
              border: UnderlineInputBorder(),
              filled: true,
              labelText: 'Pfadinamen',
            ),
            onSaved: (value) => _pfadinamen = value,
          ),
          new TextFormField(
            decoration: new InputDecoration(
                border: UnderlineInputBorder(),
                filled: true,
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
                labelText: 'Nachname'),
            validator: (value) =>
                value.isEmpty ? 'Nachname darf nicht leer sein' : null,
            keyboardType: TextInputType.text,
            onSaved: (value) => _nachname = value,
          ),
          Container(
            padding: EdgeInsets.only(left: 12),
            width: 1000,
            color: Colors.grey[200],
            child: new DropdownButton<String>(
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
          )
                            ],
                          ),
                          ),
            )
                          ],
          
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Icon(Icons.home),
                ),
                Expanded(
                  flex: 9,
                  child: Container(
                    alignment: Alignment.center, //
                    decoration: new BoxDecoration(
                      border: new Border.all(color: Colors.black, width: 2),
                      borderRadius: new BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        new TextFormField(
            decoration: new InputDecoration(
                border: UnderlineInputBorder(),
                filled: true,
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
                      ],
                    ),
                  )
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Icon(Icons.phone),
                ),
                Expanded(
                  flex: 9,
                  child: Container(
                    alignment: Alignment.center, //
                      decoration: new BoxDecoration(
                        border: new Border.all(color: Colors.black, width: 2),
                        borderRadius: new BorderRadius.all(
                          Radius.circular(4.0),
                        ),
                      ),
                    child: new TextFormField(
              decoration: new InputDecoration(
                  border: UnderlineInputBorder(),
                  filled: true,
                  labelText: 'Handy nummer'),
              validator: (value) =>
                  value.isEmpty ? 'Handynummer darf nicht leer sein' : null,
              keyboardType: TextInputType.phone,
              onSaved: (value) => _handynummer = value,
            ),
                  ),
                )
              ],
            ),),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Icon(Icons.email),
                ),
                Expanded(
                  flex: 9,
                  child: Container(
                    alignment: Alignment.center, //
                    decoration: new BoxDecoration(
                      border: new Border.all(color: Colors.black, width: 2),
                      borderRadius: new BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                    ),
                    child: new TextFormField(
                      decoration: new InputDecoration(
                          filled: true,
                          labelText: 'Email'),
                      validator: (value) =>
                          value.isEmpty ? 'Email darf nicht leer sein' : null,
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (value) => _email = value,
                   ),
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Icon(Icons.vpn_key),
                ),
                Expanded(
                  flex: 9,
                  child: Container(
                    alignment: Alignment.center, //
                    decoration: new BoxDecoration(
                      border: new Border.all(color: Colors.black, width: 2),
                      borderRadius: new BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                          new TextFormField(
                          decoration: new InputDecoration(
                              border: UnderlineInputBorder(),
                              filled: true,
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
                              labelText: 'Password erneut eingeben'),
                          validator: (value) =>
                              value.isEmpty ? 'Passwort darf nicht leer sein' : null,
                          obscureText: true,
                          onSaved: (value) => _passwordneu = value,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          
        SizedBox(height: 24,)
          ],
      ),
    );
  }

  List<Widget> buildSubmitButtons() {
    if (_formType == FormType.login) {
      return [
        new RaisedButton(
                    child: new Text('Anmelden', style: new TextStyle(fontSize: 20)),
                    onPressed: validateAndSubmit,
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    color: Color(0xff7a62ff),
                    textColor: Colors.white,
                  ),
        new FlatButton(
          child: new Text(
            'Noch kein Konto? Hier registrieren',
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
                    child: new Text('Registrieren', style: new TextStyle(fontSize: 20)),
                    onPressed: validateAndSubmit,
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    color: Color(0xff7a62ff),
                    textColor: Colors.white,
                  ),
        new FlatButton(
          child: new Text(
            'Ich habe bereits ein Konto',
            style: new TextStyle(fontSize: 20),
          ),
          onPressed: moveToLogin,
        ),
      ];
    }
  }
  void _registerAsTeilnehmer() {
    pageController.animateToPage(0,
        duration: Duration(milliseconds: 700), curve: Curves.decelerate);
  }

  void _registerAsElternteil() {
    pageController?.animateToPage(1,
        duration: Duration(milliseconds: 700), curve: Curves.decelerate);
  }
}
