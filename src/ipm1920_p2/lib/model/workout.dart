class Workout {
  final String name;
  final String date;
  final String image;
  final List<dynamic> description;
  final List<dynamic> exercises;

  Workout(
    this.name,
    this.date,
    this.image,
    this.description,
    this.exercises,
  );

  //Getters
  String get getName => name;

  String get getDate => date;

  String get getImage => image;
}
