import 'package:rxdart/rxdart.dart';
import 'package:ipm1920_p2/repository/repository.dart';
import 'package:ipm1920_p2/model/workout.dart';
import 'package:ipm1920_p2/model/exercise.dart';

class ExerciseBloc {
  final _repository = Repository();
  final _exerciseFetcher = PublishSubject<List<Exercise>>();

  Observable<List<Exercise>> get exercises => _exerciseFetcher.stream;

  Future<bool> fetchExercises(Workout workout) async {
    try {
      if (workout != null) {
        List<Exercise> exercises = await _repository.fetchExercises(workout);
        _exerciseFetcher.sink.add(exercises);
      }
      return true;
    } catch (e) {
      return false;
    }

  }

  dispose() {
    _exerciseFetcher.close();
  }
}

final exerciseBloc = ExerciseBloc();