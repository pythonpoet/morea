import 'package:flutter/material.dart';
import 'package:morea/Widgets/standart/buttons.dart';

import '../../morealayout.dart';

class EditOptions extends StatefulWidget {
  EditOptions(this.options, this.returnOptions);

  final List<Map<String, dynamic>> options;
  final Function returnOptions;

  @override
  _EditOptionsState createState() => _EditOptionsState();
}

class _EditOptionsState extends State<EditOptions> {
  List<Map<String, dynamic>> options;

  @override
  void initState() {
    super.initState();
    this.options = widget.options;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Optionen'),
        leading: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: (){
              widget.returnOptions(this.options);
              Navigator.of(context).pop();
            },
          )
        ],
      ),
      floatingActionButton: moreaFloatingActionbutton(
        route: () => setState((){
          options.add({'limit':0, 'controller': TextEditingController()});
        }),
        icon: Icon(Icons.add),
      ),
      body: MoreaBackgroundContainer(
        child: ReorderableListView(
          onReorder: (oldIndex, newIndex) {
            setState(() {
              var reordered = options[oldIndex];
              options.insert(newIndex, reordered);
              if (oldIndex > newIndex) {
                options.removeAt(oldIndex + 1);
              } else {
                options.removeAt(oldIndex);
              }
            });
          },
          children: _buildOptions(),
        ),
      ),
    );
  }

  List<Container> _buildOptions() {
    print(options);
    List<Container> result = [];
    for (var item in options) {
      result.add(Container(
        key: ValueKey(item),
        margin: const EdgeInsets.only(top: 10.0),
        child: Card(
          child: ListTile(
            contentPadding: EdgeInsets.all(10),
            title: TextFormField(
              controller: item['controller'],
            ),
            subtitle: TextFormField(
              initialValue: item['limit'].toString(),
              decoration: InputDecoration(
                  labelText: 'Limit',
                  focusColor: MoreaColors.violett,
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: MoreaColors.violett))),
              onEditingComplete: () {
                setState(() {});
              },
              onChanged: (newVal) {
                item['limit'] = int.parse(newVal);
              },
              onSaved: (newVal) {
                setState(() {
                  item['limit'] = int.parse(newVal);
                });
              },
            ),
            trailing: Icon(
              Icons.drag_handle,
              color: Colors.black,
            ),
          ),
        ),
      ));
    }
    return result;
  }
}
