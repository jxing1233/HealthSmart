import 'dart:convert' as convert;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:searchfield/searchfield.dart';
import 'dart:math';



import 'TrialDetailsView.dart';
import 'trial.dart';

class TrialsListView extends StatefulWidget{

  List<Trial> trialsList;
  Map<String, dynamic> filterData;

  TrialsListView(this.trialsList, this.filterData, {super.key});

  @override
  State createState() => _State();

}

class _State extends State<TrialsListView>{

  Widget makeSubtitleForCard(Trial trial){
    int minMonths = trial.minAgeMonths;
    int maxMonths = trial.maxAgeMonths;

    int minYears = minMonths ~/ 12;
    int maxYears = maxMonths ~/ 12;

    String focusString = "";

    for(String f in trial.focus){
      focusString += "$f, ";
    }
    focusString = focusString.substring(0, focusString.length - 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Age: $minYears - $maxYears\t\tGender: ${trial.gender}"),
        Text("Focus: $focusString"),
      ],
    );
  }

  Future<void> saveTrial(Trial trial) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String path = "savedTrials/$uid";
    DatabaseReference ref = FirebaseDatabase.instance.ref(path);
    ref = ref.push();
    await ref.set(trial.getJson());
  }

  List<Trial> filterByAge(List<Trial> trialsList){
    if(widget.filterData['age'] < 1){
      return trialsList;
    }
    List<Trial> filtered = [];
    int age_in_months = widget.filterData['age'] * 12;
    for (Trial trial in trialsList) {
      if(trial.minAgeMonths <= age_in_months && age_in_months <= trial.maxAgeMonths){
        filtered.add(trial);
      }
    }
    return filtered;
  }

  List<Trial> filterByGender(List<Trial> trialsList){
    if(widget.filterData['gender'].toLowerCase() == 'all'){
      return trialsList;
    }
    List<Trial> filtered = [];
    for (Trial trial in trialsList){
      if(trial.gender.toLowerCase() == 'all'){
        filtered.add(trial);
      }
      else if(trial.gender.toLowerCase()[0] == widget.filterData['gender'].toLowerCase()[0]){
        filtered.add(trial);
      }
    }
    return filtered;
  }

  List<Trial> filterByFocus(List<Trial> trialsList){
    if(widget.filterData['focus'].toLowerCase() == 'all'){
      return trialsList;
    }
    List<Trial> filtered = [];
    for (Trial trial in trialsList){
      for(dynamic focuses in trial.focus){
        String s_focus = (focuses as String).toLowerCase();
        String selectedFocus = widget.filterData['focus'].toLowerCase();
        if(s_focus.contains(selectedFocus)){
          filtered.add(trial);
          break;
        }
      }
    }
    return filtered;
  }

  List<Trial> filterTrials(List<Trial> trialsList){
    List<Trial> filtered = filterByFocus(trialsList);
    filtered = filterByGender(filtered);
    filtered = filterByAge(filtered);
    return filtered;
  }

  Widget body(List<Trial> trialsList){
    trialsList = filterTrials(trialsList);
    return ListView.builder(
        itemCount: trialsList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(
                trialsList[index].name,
                style: Theme
                    .of(context)
                    .textTheme
                    .titleMedium,
              ),
              trailing: Icon(Icons.chevron_right),
              subtitle: makeSubtitleForCard(trialsList[index]),
              onTap: () {
                showDetailsDialog(trialsList[index]);
              },

            ),
          );
        }
    );

  }


  void showDetailsDialog(Trial trial) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(trial.name),
          content: TrialsDetailsView(trial),
          actions: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  child: const Text("Back")
                ),
                const Spacer(),
                ElevatedButton(
                    onPressed: () async {
                      await saveTrial(trial);
                      Navigator.of(context).pop();
                    },
                    child: const Text("Save")
                ),
              ],
            )
          ],
        );
      }
    );
  }


  @override
  Widget build(context){

    List<String> categoriesGender = ["ALL", "Female", "Male"];
    String selectedGender = "ALL";

    List<String> focuses_display = [];

    // keeps track of what user types in textfield
    final _textController = TextEditingController();

    final _focusController = TextEditingController();

    String enteredAge = '';
    String enteredFocus = '';

    Set<String> all_focuses = Set();
    for (int i = 0; i < widget.trialsList.length; i++) {
      for (int j = 0; j < widget.trialsList[i].focus.length; j++) {
        all_focuses.add(widget.trialsList[i].focus[j]);
      }
    }

    for (int i = 0; i < all_focuses.length; i++) {
      focuses_display.add(all_focuses.toList()[i].substring(0, min(all_focuses.toList()[i].length, 25)));

    }

    print(focuses_display);

    return body(widget.trialsList);

  }
}
