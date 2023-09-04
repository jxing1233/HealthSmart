import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'classes/TrialDetailsView.dart';
import 'classes/trial.dart';

class MyTrialsPage extends StatefulWidget{

  @override
  State createState() => _State();

}

class _State extends State<MyTrialsPage>{

  Trial parseTrial(Map<dynamic,dynamic> trialInfo){
    int min_age = trialInfo['minAgeMonths'];
    int max_age = trialInfo['maxAgeMonths'];

    String eth = "ANY";

    if (trialInfo['ethnicity'] is List) {
      eth = trialInfo['ethnicity'][0];
    }
    else{
      eth = trialInfo['ethnicity'];
    }

    Trial trial = Trial(
        trialInfo['name'],
        trialInfo['gender'],
        trialInfo['focus'],
        min_age,
        max_age,
        trialInfo['url'],
        trialInfo['location'],
        eth
    );

    return(trial);
  }


  Future<void> deleteTrial(String key) async{
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String path = "savedTrials/$uid/$key";

    await FirebaseDatabase.instance.ref(path).remove();
  }


  void showDetailsDialog(Trial trial, String key) {
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
                        await deleteTrial(key);
                        Navigator.of(context).pop();
                      },
                      child: const Text("Delete")
                  ),
                ],
              )
            ],
          );
        }
    );
  }


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

  Widget savedTrialsListView(Map<dynamic, dynamic> savedTrialsRaw){
    Map<String, Trial> savedTrials = {};
    for(String key in savedTrialsRaw.keys.toList()){
      print(key);
      print(savedTrialsRaw[key]);
      savedTrials[key] = parseTrial(savedTrialsRaw[key]);
    }

    List<String> trialKeys = savedTrials.keys.toList();

    return ListView.builder(
      itemCount: savedTrials.length,
      itemBuilder: (context, index){
        Trial trial = savedTrials[trialKeys[index]]!;
        return Card(
          child: ListTile(

            title: Text(
              trial.name,
              style: Theme
                  .of(context)
                  .textTheme
                  .titleMedium,
            ),
            trailing: Icon(Icons.chevron_right),
            subtitle: makeSubtitleForCard(trial),
            onTap: () {
              showDetailsDialog(trial, trialKeys[index]);
            },

          ),
        );
      }
    );

  }


  Widget savedTrialsBody(){
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String path = "savedTrials/$uid";

    return StreamBuilder(
      stream: FirebaseDatabase.instance.ref(path).onValue,
      builder: (context, snapshot){
        if(snapshot.hasError){
          return const Text("Error");
        }
        if(snapshot.hasData){
          if(snapshot.data == null || snapshot.data!.snapshot.value == null){
            return Center(child:
              Text(
                "No Trials Saved",
                style: Theme.of(context).textTheme.displaySmall,
              )
            );
          }
          else{
            Map<dynamic, dynamic> mapOfSavedTrials = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            return savedTrialsListView(mapOfSavedTrials);
          }
        }

        return const Text("loading...");
      }
    );
  }

  @override
  Widget build(context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Trials"),
      ),
      body: savedTrialsBody(),
    );
  }

}