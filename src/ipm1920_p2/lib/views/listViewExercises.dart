import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ipm1920_p2/model/workout.dart';
import 'package:ipm1920_p2/bloc/exerciseBloc.dart';
import 'package:ipm1920_p2/model/exercise.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:async';


///////////////////////////////////////////////

class ListViewExercise extends StatelessWidget {
  final Workout workout;

  ListViewExercise({@required this.workout});

  @override
  Widget build(BuildContext context) {
    exerciseBloc
        .fetchExercises(workout)
        .timeout(const Duration(seconds: 2))
        .catchError((error) {
      errorPage(context);
    });
    return new StreamBuilder(
      stream: exerciseBloc.exercises,
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
            if (snapshot.hasError) {
              return new Text('Error: ${snapshot.error}');
            } else {
              return new Scaffold(
                backgroundColor: Colors.black,
                appBar: new AppBar(
                  backgroundColor: Colors.lightGreen[500],
                  title: new Text(workout.name, style: TextStyle(fontSize: 20)),
                  actions: [
                    FloatingActionButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CountDownTimer(
                                    workout) //TimerWorkout(workout)
                            ));
                      },
                      child: Icon(Icons.play_arrow),
                      backgroundColor: Colors.amber,
                    ),
                  ],
                ),
                body: createViewExercise(context, snapshot, workout),
              );
            }
            break;

          default:
            return Scaffold(
              body: Container(
                color: Colors.black,
                child: new Center(
                  child: Text("Esperando por la rutina",
                      style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ),
            );
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
                style: TextStyle(fontSize: 25, color: Colors.white),
              )),
        ),
      );
    }));
  }

  Widget createViewExercise(
      BuildContext context, AsyncSnapshot snapshot, Workout workout) {
    return _buildWorkoutDetails(workout, context, snapshot);
    //return createListViewExercise(context, snapshot);
  }

  Widget _buildWorkoutDetails(
      Workout entrada, BuildContext context, AsyncSnapshot snapshot) {
    return new SingleChildScrollView(
      child: new Column(
        children: <Widget>[
          getImageFromDocument(entrada, MediaQuery.of(context).size.width / 3,
              MediaQuery.of(context).size.height / 3),
          Container(
            color: Colors.grey[900],
            child: _getDescriptionWorkout(entrada.description, context),
          ),
          Container(
            color: Colors.grey[900],
            child: _getDescriptionWorkoutExercises(context, snapshot),
          ),
        ],
      ),
    );
  }

  _getDescriptionWorkoutExercises(context, snapshot) {
    return _getExercisesList(context, snapshot);
    //return createListViewExercise(context, snapshot);
  }

  Widget _getDescriptionWorkout(description, BuildContext context) {
    return ExpansionTile(title: Text('Descripción'), children: <Widget>[
      ListView.builder(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.all(16.0),
          itemCount: description.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, i) {
            return _buildDescriptionEntry(description[i]);
          }),
    ]);
  }

  Widget _buildDescriptionEntry(descriptionEntry) {
    if (descriptionEntry == "") {
      descriptionEntry = "Descripción no disponible en este momento.";
    }
    return ListTile(
      title: Text(
        descriptionEntry,
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _getExercisesList(BuildContext context, AsyncSnapshot snapshot) {
    List<Exercise> values = snapshot.data;
    return Container(
      color: Colors.grey[900],
      child: ExpansionTile(
          initiallyExpanded: true,
          title: Text('Lista de ejercicios'),
          children: <Widget>[
            ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: values.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return _buildExerciseListEntry(values[index], context);
                }),
          ]),
    );
  }

  Widget _buildExerciseListEntry(Exercise exerciseEntry, BuildContext context) {
    return ListTile(
      trailing: Text(exerciseEntry.repeticiones),
      title: Text(
        exerciseEntry.name,
      ),
      onTap: () => _navigateExercises(exerciseEntry, context),
    );
  }

  void _navigateExercises(Exercise exercise, BuildContext context) async {
    Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
      return new Scaffold(
        backgroundColor: Colors.black,
        appBar: new AppBar(
          backgroundColor: Colors.lightGreen,
          title: new Text(exercise.name),
        ),
        body: _buildExerciseDetails(exercise, context),
      );
    }));
  }

  Widget _buildExerciseDetails(Exercise exercise, BuildContext context) {
    return new SingleChildScrollView(
      child: new Column(
        children: <Widget>[
          Container(
              width: 240, height: 360, child: getImageFromDocument(exercise)),
          Container(
            color: Colors.grey[900],
            child: _getDescriptionExercise(exercise.description),
          ),
          (exercise.video != "")
              ? FloatingActionButton.extended(
            label: Text('Ver Video'),
            icon: Icon(Icons.play_arrow),
            onPressed: () {
              launch(exercise.video);
            },
          )
          // ignore: missing_required_param
              : FloatingActionButton.extended(
            label: Text('Video no disponible'),
            icon: Icon(Icons.play_arrow),
          ),
        ],
      ),
    );
  }

  Widget _getDescriptionExercise(description) {
    return ExpansionTile(title: Text('Descripción'), children: <Widget>[
      ListView(
        padding: const EdgeInsets.all(16.0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildDescriptionEntry(description),
        ],
      ),
    ]);
  }

  Widget createListViewExercise(BuildContext context, AsyncSnapshot snapshot) {
    List<Exercise> values = snapshot.data;
    return new ListView.builder(
      shrinkWrap: true,
      padding: new EdgeInsets.symmetric(vertical: 8.0),
      itemCount: values.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return new ExpansionTile(
          leading: getImageFromDocument(values[index]),
          title: new Text(values[index].name, style: TextStyle(fontSize: 20)),
          children: <Widget>[
            new Column(
              children: _buildExpandableContent(values[index]),
            ),
            new Divider(
              height: 2.0,
            ),
          ],
        );
      },
    );
  }

  _buildExpandableContent(Exercise exercise) {
    List<Widget> columnContent = [];

    if (exercise.video == "") {
      columnContent.add(
        new ListTile(
            title:
            new Text(exercise.description, style: TextStyle(fontSize: 18)),
            subtitle: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  new Text(exercise.repeticiones),
                ])),
      );
    } else {
      columnContent.add(
        new ListTile(
            title:
            new Text(exercise.description, style: TextStyle(fontSize: 18)),
            subtitle: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  new Text(exercise.repeticiones),
                  new InkWell(
                      child: new IconButton(
                        icon: Icon(Icons.play_circle_filled),
                        color: Colors.white,
                        onPressed: () {
                          launch(exercise.video);
                        },
                      ))
                ])),
      );
    }
    return columnContent;
  }

  Image getImageFromDocument(document, [ancho = 50.0, alto = 100.0]) {
    if (document.image == "") {
      return new Image(
        image: AssetImage('assets/placeholder-vertical.jpg'),
        width: ancho,
        height: alto,
      );
    } else {
      return new Image.memory(
        base64.decode(document.image),
        width: ancho,
        height: alto,
      );
    }
  }
}

///////////////////////////////////////////////////////////////////////////

class CountDownTimer extends StatefulWidget {
  final Workout workout;

  CountDownTimer(this.workout);

  List<dynamic> list;

  List<dynamic> workoutToReps() {
    List<dynamic> list = [];
    for (var array in workout.exercises) {
      var aux = array[1];
      var parsedArray = aux.split(" ");
      if (parsedArray.length == 2) {
        aux = aux.replaceAll(' rep', '');
        aux = int.parse(aux) * 3; //Cada repeticion lo toma como 3 segundos
      } else if (aux.contains("\"")) {
        aux = aux.replaceAll('\"', '');
        aux = int.parse(aux);
      } else if (aux.contains("\'")) {
        aux = aux.replaceAll("\'", "");
        aux = int.parse(aux) * 60;
      } else {
        aux = int.parse(aux) * 2;
      }
      list.add(aux);
    }
    return list;
  }

  List<dynamic> workoutToNames() {
    List<dynamic> list = [];
    for (var array in workout.exercises) {
      var aux = array[0];
      list.add(aux);
    }
    return list;
  }

  @override
  State<CountDownTimer> createState() {
    this.list = workoutToReps();
    int index = 0;
    return _CountDownTimerState(list, index, list[index], workoutToNames());
  }
}

class _CountDownTimerState extends State<CountDownTimer>
    with TickerProviderStateMixin {
  int index, duracion, duracionInicial;
  bool _iniciado = false;
  bool _pausado = false;
  List<dynamic> list, names;
  Timer timer;
  bool _usado = false;

  _CountDownTimerState(this.list, this.index, this.duracion, this.names);

  String name;

  String get timerString {
    Duration duration = Duration(seconds: this.duracion);
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  startTimer() {
    const oneSec = const Duration(seconds: 1);
    duracionInicial = duracion;
    timer = new Timer.periodic(
      oneSec,
          (Timer timer) => setState(
            () {
          if ((!_pausado) & (_iniciado)) {
            if (this.duracion < 1) {
              this.timer.cancel();
            } else {
              this.duracion = this.duracion - 1;
            }
          }
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    name = names[index];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_usado) {
          timer.cancel();
        }
        return true;
      },
      child: Scaffold(
          body: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.bottomCenter,
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Align(
                        alignment: FractionalOffset.center,
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: Stack(
                            children: <Widget>[
                              Align(
                                alignment: FractionalOffset.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      name,
                                      style: TextStyle(
                                          fontSize: 20.0, color: Colors.white),
                                    ),
                                    Text(
                                      timerString,
                                      style: TextStyle(
                                          fontSize: 112.0, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    (!_iniciado)
                        ? RaisedButton(
                        child: Text(
                          'Comenzar',
                          style: TextStyle(color: Colors.black),
                        ),
                        color: Colors.amber,
                        onPressed: () {
                          setState(() {
                            _usado = true;
                            _iniciado = true;
                            _pausado = false;
                            startTimer();
                          });
                        })
                        : (!_pausado)
                        ? Column(
                      children: [
                        RaisedButton(
                            child: Text(
                              'Pausar',
                              style: TextStyle(color: Colors.black),
                            ),
                            color: Colors.amber,
                            onPressed: () {
                              setState(() {
                                _pausado = true;
                              });
                            }),
                      ],
                    )
                        : Column(
                      children: [
                        RaisedButton(
                            child: Text(
                              'Continuar',
                              style: TextStyle(color: Colors.black),
                            ),
                            color: Colors.amber,
                            onPressed: () {
                              setState(() {
                                _pausado = false;
                              });
                            }),
                      ],
                    ),
                    RaisedButton(
                      child: Text(
                        'Next',
                        style: TextStyle(color: Colors.black),
                      ),
                      color: Colors.amber,
                      onPressed: () {
                        setState(() {
                          _iniciado = false;
                          _pausado = false;
                          if (_usado) {
                            _usado = false;
                            if (timer.isActive == true) {
                              timer.cancel();
                            }
                          }
                          if (index + 1 == list.length) {
                            if (_usado) {
                              timer.cancel();
                            }
                            Navigator.pop(context);
                          } else {
                            index = index + 1;
                            duracion = list[index];
                            name = names[index];
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
