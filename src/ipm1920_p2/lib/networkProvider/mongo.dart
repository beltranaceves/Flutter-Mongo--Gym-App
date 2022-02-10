import 'dart:async';
import 'dart:convert';

import 'package:ipm1920_p2/model/exercise.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:ipm1920_p2/model/workout.dart';

class DatabaseHelper {
  static Db _db;

  Future<Db> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {}

  Future<List<Workout>> getWorkoutData() async {
    List<Workout> list = [];
    Db db = Db('mongodb://10.0.2.2:27017/workouts');

    //Abrimos la base de datos
    await db.open();

    DbCollection workouts = db.collection('workouts');
    var listaRutinas = await workouts.find().toList();

    for (var i in listaRutinas) {
      String name = i['name'];
      String date = i['date'];

      var imageStr = i['image'];
      String image;
      if (imageStr == "") {
        image = "";
      } else {
        image = utf8.decode(i['image'].byteList); //imagen
      }

      List<dynamic> description = i['description'];
      List<dynamic> exercises = i['exercises'];

      Workout aux = new Workout(name, date, image, description, exercises);
      list.add(aux);
    }

    //Cerramos base de datos
    await db.close();

    //Devolvemos la lista construida
    if (list.length == 0) {
      return null;
    }

    return list;
  }

  Future<List<Exercise>> getExerciseData(Workout workout) async {
    List<Exercise> list = [];
    Db db = Db('mongodb://10.0.2.2:27017/workouts');

    //Abrimos la base de datos
    await db.open();

    DbCollection exercises = db.collection('exercises');

    for (var aux in workout.exercises) {
      String name = aux[0];
      String reps = aux[1];

      var auxExercise = await exercises.findOne({"name": name});

      if (auxExercise != null) {

        String description;
        if (auxExercise['description'] == "") {
          description = "";
        } else {
          List<dynamic> descriptionArray = auxExercise['description'];

          var concatenate = StringBuffer();
          descriptionArray.forEach((item) {
            concatenate.write(item);
          });

          description = concatenate.toString(); //descripcion
        }

        String video = auxExercise['video']; //video

        var imageStr = auxExercise['image'];
        String image;
        if (imageStr == "") {
          image = "";
        } else {
          image = utf8.decode(auxExercise['image'].byteList); //imagen
        }
        Exercise aux = new Exercise(name, description, image, video, reps);

        list.add(aux);
      } else {
        Exercise aux = new Exercise(name, "", "", "", reps);

        list.add(aux);
      }

    }

    //Cerramos base de datos
    await db.close();

    //Devolvemos la lista construida
    if (list.length == 0) {
      return null;
    }

    return list;
  }
}
