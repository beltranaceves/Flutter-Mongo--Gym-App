import 'package:flutter/material.dart';
import 'package:ipm1920_p2/model/workout.dart';
import 'package:ipm1920_p2/views/listViewExercises.dart';
import 'package:ipm1920_p2/views/listViewWorkouts.dart';


/////////////////////////////////////////////////////////////////

class MasterDetailContainer extends StatefulWidget {
  @override
  _ItemMasterDetailContainerState createState() =>
      _ItemMasterDetailContainerState();
}

class _ItemMasterDetailContainerState extends State<MasterDetailContainer> {
  static const int kTabletBreakpoint = 600;

  Workout _selectedItem;
  List<Workout> values;
  int index;

  Widget _buildTabletLayout() {
    return Row(
      children: <Widget>[
        Flexible(
          flex: 1,
          child: Material(
              elevation: 4.0,
              child: ListViewDB(itemSelectedCallback: (item) {
                setState(() {
                  _selectedItem = item;
                });
              })),
        ),
        Flexible(
            flex: 3,
            child: ListViewExercise(
              workout: _selectedItem,
            )),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return ListViewDB(
      itemSelectedCallback: (item) {
        setState(() {
          _selectedItem = item;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListViewExercise(workout: _selectedItem),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;

    if ((shortestSide > kTabletBreakpoint) ||
        (MediaQuery.of(context).orientation == Orientation.portrait)) {
      return Scaffold(
        body: _buildMobileLayout(),
      );
    } else {
      return Scaffold(
        body: _buildTabletLayout(),
      );
    }
  }
}
