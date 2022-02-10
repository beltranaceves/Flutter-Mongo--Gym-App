import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ipm1920_p2/model/workout.dart';
import 'package:ipm1920_p2/bloc/workoutBloc.dart';
import 'dart:convert';

/////////////////////////////////////////////////////////////////

class ListViewDB extends StatelessWidget {
  ListViewDB({@required this.itemSelectedCallback});

  final ValueChanged<Workout> itemSelectedCallback;

  @override
  Widget build(BuildContext context) {
    workoutBloc
        .fetchAllWorkouts()
        .timeout(const Duration(seconds: 2))
        .catchError((error) {
      errorPage(context);
    });

    return new StreamBuilder(
      stream: workoutBloc.allWorkouts,
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        switch (snapshot.connectionState) {
          //TODO preguntar por que si aqui pongo un progressIndicator que queda pillado la primera vez que se enciende.
          case ConnectionState.active:
            if (snapshot.hasError) {
              return new Text('Error: ${snapshot.error}');
            } else
              return new Scaffold(
                backgroundColor: Colors.black,
                appBar: new AppBar(
                  backgroundColor: Colors.green,
                  title: Text('Gestor BD Fitness'),
                ),
                body: createListView(context, snapshot),
              );
            break;
          default:
            return new Center(
                child: Text(
              "Cargando datos...",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25),
            ));
        }
      },
    );
  }

  void errorPage(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return WillPopScope(
        onWillPop: () async {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          return false;
        },
        child: Scaffold(
          body: Center(
              child: Text(
            "No se pudo conectar con el servidor.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 25, color: Colors.white),
          )),
        ),
      );
    }));
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    List<Workout> values = snapshot.data;
    return new ListView.builder(
      itemCount: values.length,
      itemBuilder: (BuildContext context, int index) {
        return new Column(
          children: <Widget>[
            Divider(
              height: 4,
              color: Colors.black12,
            ),
            Container(
              decoration: BoxDecoration(color: Colors.grey[900]),
              child: ListTile(
                title: Text(values[index].name, style: TextStyle(fontSize: 20)),
                trailing: getImageFromDocument(values[index]),
                onTap: () => itemSelectedCallback(values[index]),
              ),
            ),
            new Divider(
              height: 2.0,
            ),
          ],
        );
      },
    );
  }

  Image getImageFromDocument(Workout workout) {
    if (workout.image == "") {
      return new Image(image: AssetImage('assets/placeholder.png'));
    } else {
      return new Image.memory(base64.decode(workout.image));
    }
  }
}

///////////////////////////////////////////////////////////////////////////
