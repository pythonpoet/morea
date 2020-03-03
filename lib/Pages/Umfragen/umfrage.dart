import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morealayout.dart';

class Umfrage extends StatefulWidget {
  @override
  _UmfrageState createState() => _UmfrageState();
}

class _UmfrageState extends State<Umfrage> {
  ScrollPosition flex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: MoreaColors.violett,
        shape: CircleBorder(side: BorderSide(color: Colors.white)),
        child: Icon(Icons.person_add),
        onPressed: null,
      ),
      body: MoreaBackgroundContainer(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              title: SABT(child: Text('Test')),
              elevation: 10,
              forceElevated: false,
              primary: true,
              pinned: true,
              floating: false,
              expandedHeight: 70,
              backgroundColor: MoreaColors.orange,
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[
                  Center(
                    child: Text(
                      'Test',
                      style: MoreaTextStyle.title,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Center(
                      child: Text(
                        'von Test',
                        style: MoreaTextStyle.captionWhite,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 50.0, top: 20),
                    child: MoreaDividerWhite(),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.all(0),
                    leading: SizedBox(
                      width: 50,
                      child: Icon(
                        Icons.place,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      'Ort',
                      style: MoreaTextStyle.lableWhite,
                    ),
                    onTap: () => print('test'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 50.0,
                    ),
                    child: MoreaDividerWhite(),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.all(0),
                    leading: SizedBox(
                      width: 50,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      '10 von 20',
                      style: MoreaTextStyle.lableWhite,
                    ),
                    onTap: () => print('test'),
                  ),
                  MoreaShadowContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10)),
                              color: Colors.black12),
                          padding: EdgeInsets.only(
                              left: 15, top: 5, bottom: 5, right: 15),
                          child: Text(
                            'Optionen',
                            style: MoreaTextStyle.caption,
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Datum1',
                            style: MoreaTextStyle.lable,
                          ),
                          trailing: Icon(Icons.check_circle_outline,
                              color: Colors.green),
                        ),
                        MoreaDivider(),
                        this._buildOption(),
                        MoreaDivider(),
                        ListTile(
                          title: Text(
                            'Datum3',
                            style: MoreaTextStyle.lable,
                          ),
                          trailing: Icon(Icons.remove_circle_outline,
                              color: Colors.red),
                        ),
                        MoreaDivider(),
                        ListTile(
                          title: Text(
                            'Datum4',
                            style: MoreaTextStyle.lable,
                          ),
                          trailing:
                              Icon(Icons.error_outline, color: Colors.orange),
                        ),
                        MoreaDivider(),
                        ListTile(
                          title: Text(
                            'Datum2',
                            style: MoreaTextStyle.lable,
                          ),
                          trailing:
                          Icon(Icons.panorama_fish_eye, color: Colors.grey),
                        ),
                        MoreaDivider(),
                        ListTile(
                          title: Text(
                            'Datum2',
                            style: MoreaTextStyle.lable,
                          ),
                          trailing:
                          Icon(Icons.panorama_fish_eye, color: Colors.grey),
                        ),
                        MoreaDivider(),
                        ListTile(
                          title: Text(
                            'Datum2',
                            style: MoreaTextStyle.lable,
                          ),
                          trailing:
                          Icon(Icons.panorama_fish_eye, color: Colors.grey),
                        ),
                        MoreaDivider(),
                        ListTile(
                          title: Text(
                            'Datum2',
                            style: MoreaTextStyle.lable,
                          ),
                          trailing:
                          Icon(Icons.panorama_fish_eye, color: Colors.grey),
                        ),
                        MoreaDivider(),
                        ListTile(
                          title: Text(
                            'Datum2',
                            style: MoreaTextStyle.lable,
                          ),
                          trailing:
                          Icon(Icons.panorama_fish_eye, color: Colors.grey),
                        ),
                        MoreaDivider(),
                        this._buildOption(),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  ListTile _buildOption(){
    return ListTile(
      title: Text(
        'Datum2',
        style: MoreaTextStyle.lable,
      ),
      trailing:
      Icon(Icons.panorama_fish_eye, color: Colors.grey),
    );
  }
}

class SABT extends StatefulWidget {
  final Widget child;

  const SABT({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  _SABTState createState() {
    return new _SABTState();
  }
}

class _SABTState extends State<SABT> {
  ScrollPosition _position;
  bool _visible;

  @override
  void dispose() {
    _removeListener();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _removeListener();
    _addListener();
  }

  void _addListener() {
    _position = Scrollable.of(context)?.position;
    _position?.addListener(_positionListener);
    _positionListener();
  }

  void _removeListener() {
    _position?.removeListener(_positionListener);
  }

  void _positionListener() {
    final FlexibleSpaceBarSettings settings = context
        .dependOnInheritedWidgetOfExactType(aspect: FlexibleSpaceBarSettings);
    bool visible =
        settings == null || settings.currentExtent <= settings.minExtent;
    if (_visible != visible) {
      setState(() {
        _visible = visible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _visible,
      child: widget.child,
    );
  }
}
