import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'account_page.dart';
import 'classes/TrialDetailsView.dart';
import 'classes/trial.dart';
import 'my_trials_page.dart';
import 'trials_page.dart';
import 'dart:convert' as convert;


class HomePage extends StatefulWidget{

  @override
  State createState() => _State();

}

class _State extends State{

  void navigateToTrialsPage(){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (builder) => TrialsPage())
    );
  }

  void navigateToMyTrialsPage(){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (builder) => MyTrialsPage())
    );
  }

  void navigateToAccountPage(){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (builder) => AccountPage())
    );
  }


  List<Trial> parseTrials(List<dynamic> trialsData){
    List<Trial> trialList= [];

    for(Map<String, dynamic> trialInfo in trialsData){

      int? min_age = int.tryParse('${trialInfo['age_range'][0]}');
      int? max_age = int.tryParse('${trialInfo['age_range'][1]}');

      if(trialInfo['age_range'] is String){
        if(trialInfo['age_range'] == "18 years and up"){
          min_age = 18 * 12;
          max_age = 100 * 12;
        }
        else{
          min_age = 0;
          max_age = 100 * 12;
        }
      }

      min_age = min_age == null ? 0 : min_age;
      max_age = max_age == null ? 100 * 12 : max_age;


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
        trialInfo['link'],
        trialInfo['location'],
          eth
      );

      trialList.add(trial);
    }
    return trialList;
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

  Future<void> saveTrial(Trial trial) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String path = "savedTrials/$uid";
    DatabaseReference ref = FirebaseDatabase.instance.ref(path);
    ref = ref.push();
    await ref.set(trial.getJson());
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

  Widget trialCard(Trial trial){
    return Card(
      child: ListTile(
        title:Text(
          trial.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        trailing: Icon(Icons.chevron_right),
        subtitle: makeSubtitleForCard(trial),
        onTap: () {
          showDetailsDialog(trial);
        },

      ),
    );
  }

  Widget trialListView(List<Trial> trialsList){

    int count = min(trialsList.length, 5);

    return ListView.builder(
      itemCount: count,
      itemBuilder: (context, index){
        return trialCard(trialsList[index]);
      }
    );
  }


  Widget userDataFutureBuilder(){
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String path = "user_data/$uid";
    return FutureBuilder(
        future: FirebaseDatabase.instance.ref(path).get(),
        builder: (context, snapshot){
          if(snapshot.hasError){
            return const Text("An Error has Occurred, try again later");
          }
          else if(snapshot.hasData){
            if(snapshot.data!.value == null){
              return const Text("There is no data on this account");
            }
            else{
              Map<dynamic, dynamic> userData = snapshot.data!.value as Map<dynamic, dynamic>;
              return recommendationFutureBuilder(userData);
            }
          }
          return const Center( child: CircularProgressIndicator());
        }
    );
  }

  Widget recommendationFutureBuilder(Map<dynamic, dynamic> accountData){
    String url = 'http://52.14.88.67:5000/recommendation';

    String gender = "all";
    if (accountData['sex'] == 0){ gender = 'male';}
    else if (accountData['sex'] == 1){ gender = 'female';}

    Map<String, dynamic> userData = {
      "age": "${accountData['age']}",
      "gender": gender,
      "ethnicity": accountData['ethnicity'],
      "race": "z",
      "focus": "all",
      "sort": 'z'
    };

    return FutureBuilder(
      future: http.post(
        Uri.parse(url),
        body: userData,
      ),
      builder: (context, snapshot){
        if(snapshot.hasData){

          dynamic response = snapshot.data;
          if(response != null){

            Map<String, dynamic> trialsData = convert.jsonDecode(response.body) as Map<String, dynamic>;

            List<dynamic> trialsDynamicList = trialsData["trial"].toList();
            List<Trial> trialsList = parseTrials(trialsDynamicList);
            return Column(
              children: [
                Center(child:
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Trials Recommendation",
                      style : Theme.of(context).textTheme.titleLarge
                    ),
                  )
                ),
                Expanded(child: trialListView(trialsList)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(onPressed: (){ setState(() {}); }, child: const Text("Get New Recommendations")),
                ),
              ],
            );

          }
          else{
            return const Center(
              child: Text("No Recommendations"),
            );
          }
        }

        else if(snapshot.hasError){
          print(snapshot.error);

          return const Center(
            child: Text("An Error has Occurred"),
          );
        }

        else{
          // Loading...
          print('Waiting on the webpage');
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      }
    );
  }


  @override
  Widget build(context){
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("HealthSmart")),
        actions:[
          IconButton(
              onPressed: navigateToAccountPage,
              icon: const Icon(Icons.account_circle)
          )
        ]

      ),
      body: Center(
        child: Column(
          children: [

            infoBody(),


            Expanded(
                child: userDataFutureBuilder()
            ),


            Container(
              color: Theme.of(context).primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: navigateToMyTrialsPage,
                        child: Text("My Trials")
                    ),

                    ElevatedButton(
                        onPressed: navigateToTrialsPage,
                        child: Text("Find Trials")
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      )
    );
  }


  Widget infoBody() {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top:20, bottom: 20),
      child: Column(
        children: [

          Text(
            "What are clinical trials?",
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const Text(
            "Clinical trials are studies done by researchers to test the effectiveness of a novel medical treatment.",
          ),

          Text(
            "Why participate?",
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const Text(
            "By participating, you can help further our scientific knowledge of medicine, get potentially innovative treatment before it’s available to others, give researchers a more comprehensive understanding of the effects of a treatment, and more.",
          ),

        ],
      ),
    );
  }

}