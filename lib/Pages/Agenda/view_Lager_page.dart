import 'package:flutter/material.dart';
import 'package:morea/Pages/Agenda/Agenda_Eventadd_page.dart';

class ViewLagerPageState extends StatelessWidget {

 ViewLagerPageState({this.info, this.pos});
  var info;
  String pos;



  @override
  Widget build(BuildContext context) {
    print(info['Kontakt']['Pfadiname']);
    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff7a62ff),
          title: Text(info['Lagername'].toString()),
        ),
        body: LayoutBuilder(
              builder:
                  (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                    child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: viewLager(),
                ));
              },
            ),
            floatingActionButton: Opacity(
              opacity: istLeiter() ? 1.0 : 0.0 ,
              child: new FloatingActionButton(
                elevation: 0.0,
                child: new Icon(Icons.edit),
                backgroundColor:  Color(0xff7a62ff),
                onPressed: () => routeToLagerbearb(context),
                ),
             ),
      )
    );
  }
  Widget viewLager(){
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        children: <Widget>[
          Container(
             alignment: Alignment.center, //
                    decoration: new BoxDecoration(
                      border: new Border.all(color: Colors.black, width: 2),
                      borderRadius: new BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                    ),
            child: Container(
              padding: EdgeInsets.all(5),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                    child: Text(
                      'Datum',
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                    ],),
                  
                  Container(
                    child: Row(
                children: <Widget>[

                  Expanded(
                    
                    child: Text(
                     'vom: '+ info['Datum'],
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  Expanded(
                    
                    child: Text(
                     'bis: '+ info['Datum bis'],
                      style: TextStyle(fontSize: 15),
                    ),
                  )
                ],
              )),
              SizedBox(height: 5,),
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Text(
                     'Lagerort',
                      style: TextStyle(fontSize: 20),
                    )
                    )
                  ],
                ),
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Text(info['Lagerort'],style: TextStyle(fontSize: 15)),
                    )
                  ],
                ),
              ),
              Container(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                           Container(
                            child: Text('Besammlung', style: TextStyle(fontSize: 20)),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 5),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: Text('Zeit: '),
                                ),
                                Container(
                                  child: Text(info['Anfangszeit']),)
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 5),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: Text('Ort: '),
                                ),
                                Container(
                                  child: Text(info['Anfangsort']),)
                              ],
                            ),
                          ) 
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: Text('Schluss', style: TextStyle(fontSize: 20)),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 5),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: Text('Zeit: '),
                                ),
                                Container(
                                  child: Text(info['Schlusszeit']),)
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 5),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: Text('Ort: '),
                                ),
                                Container(
                                  child: Text(info['Schlussort']),)
                              ],
                            ),
                          ) 
                          
                        ],
                      ),
                    ),
                  ],
                ),
              )

                  

                ],
              ),
            ),
            ),
          SizedBox(height: 15,),
         Container(
             alignment: Alignment.center, //
                    decoration: new BoxDecoration(
                      border: new Border.all(color: Colors.black, width: 2),
                      borderRadius: new BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                    ),
            child: Container(
              padding: EdgeInsets.all(5),
              
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    child: Row(
                      children: <Widget>[
                        Container(
                      child: Text('Beschreibung', style: TextStyle(fontSize: 20)),
                    ),
                      ],
                    )
                  ),
                  Flexible(
                    child: Container(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(info['Beschreibung']),
                      )
                  )
                ],
              ),
            )
          ),
          SizedBox(
            height: 15,
          ),
          Container(
             alignment: Alignment.center, //
                    decoration: new BoxDecoration(
                      border: new Border.all(color: Colors.black, width: 2),
                      borderRadius: new BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                    ),
            child: Container(
              padding: EdgeInsets.all(5),
              child: Column(
                children: <Widget>[
                  Row(children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Text(
                        'Mitnehmen:',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ]),
                  Container(
                    height: 18 * info['Mitnehmen'].length.toDouble(),
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: this.info['Mitnehmen'].length,
                      itemBuilder: (context, int index) {
                        return Container(
                            child: Row(
                          children: <Widget>[
                            Expanded(
                                flex: 1,
                                child: Icon(
                                  Icons.brightness_1,
                                  size: 7,
                                )),
                            Expanded(
                              flex: 9,
                              child: Text(info['Mitnehmen'][index],
                                  style: new TextStyle(
                                    fontSize: 15,
                                  )),
                            ),
                          ],
                        ));
                      },
                    ),
                  )
                ],
              ))),
              SizedBox(height: 15,),
              Container(
             alignment: Alignment.center, //
                    decoration: new BoxDecoration(
                      border: new Border.all(color: Colors.black, width: 2),
                      borderRadius: new BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                    ),
                    child:
          Container(
              padding: EdgeInsets.all(5),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Kontakt:',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
        
                      Expanded(
                        child: Text('Kontaktperson: ',
                            style: TextStyle(fontSize: 15)),
                      ),
                      Expanded(
                        child: Text(
                          info['Kontakt']['Pfadiname'],
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text('Email:', style: TextStyle(fontSize: 15)),
                      ),
                      Expanded(
                        child: Text(
                          info['Kontakt']['Email'],
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  )
                ],
              ))),
        ],
      ),
    );
  }

  bool istLeiter(){
    if(pos=='Leiter'){
      return true;
    }else{
      return false;
    }
  }
 void routeToLagerbearb(context){
    Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) => EventAddPage(eventinfo: info, agendaModus: AgendaModus.lager,))).then((onValue){

                    });
  }
}

