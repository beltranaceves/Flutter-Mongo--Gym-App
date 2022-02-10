import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:ipm1920_p2/repository/repository.dart';
import 'package:ipm1920_p2/model/workout.dart';

class WorkoutBloc {
  final _repository = Repository();
  final _workoutFetcher = PublishSubject<List<Workout>>();

  Observable<List<Workout>> get allWorkouts => _workoutFetcher.stream;

  Future<bool> fetchAllWorkouts() async {
    try {
      List<Workout> workout = await _repository.fetchAllWorkouts();
      _workoutFetcher.sink.add(workout);
      return true;
    } catch (e) {
      return false;
    }
  }

  dispose() {
    _workoutFetcher.close();
  }
}

final workoutBloc = WorkoutBloc();


