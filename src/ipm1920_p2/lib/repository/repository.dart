import 'dart:async';

import 'package:ipm1920_p2/model/exercise.dart';
import 'package:ipm1920_p2/networkProvider/mongo.dart';
import 'package:ipm1920_p2/model/workout.dart';

class Repository {
  final mongo = DatabaseHelper();

  Future<List<Workout>> fetchAllWorkouts() => mongo.getWorkoutData();

  Future<List<Exercise>> fetchExercises(Workout workout) =>
      mongo.getExerciseData(workout);
}
