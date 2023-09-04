import 'dart:convert' as convert;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'classes/TrialsListView.dart';
import 'classes/trial.dart';

class TrialsPage extends StatefulWidget{ // creating a new page

  @override
  State createState() => _State();

}

class _State extends State{

  String url = 'http://52.14.88.67:5000/user_info_trials';

  Map<String, dynamic> filterData = {
    "age": 0,
    "gender": "all",
    "focus": "all"
  };

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

      String eth = "${trialInfo['ethnicity']}";

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


  void showFilterDialog() {
    List<String> genderList = ["all", "male", "female"];
    List<String> focusList = ["all"];
    List<int> ageList = List<int>.generate(101, (i) => i);

    String genderSelected = filterData['gender'];
    String focusSelected = filterData['focus'];
    int ageSelected = filterData['age'];

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setStateSB) {
              return AlertDialog(
                title: const Text("Filter Trials"),
                content: SingleChildScrollView(
                  child: Column(
                    children: [

                      // Gender Row
                      Row(
                        children: [
                          const Text("Gender:"),
                          const Spacer(),

                          DropdownButton<String>(
                            value: genderSelected,
                            onChanged: (String? value){
                              genderSelected = value!;
                              setStateSB((){});
                            },
                            items: genderList.map<DropdownMenuItem<String>>(
                                    (String value){
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }
                            ).toList(),
                          ),
                        ],
                      ),

                      // Age Row
                      Row(
                        children: [
                          const Text("Age:"),
                          const Spacer(),

                          DropdownButton<int>(
                            value: ageSelected,
                            onChanged: (int? value){
                              ageSelected = value!;
                              setStateSB((){});
                            },
                            items: ageList.map<DropdownMenuItem<int>>(
                                    (int value){
                                      String valueText = "$value";
                                      if (value < 1) {valueText = "all";}
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text(valueText),
                                  );
                                }
                            ).toList(),
                          ),
                        ],
                      ),


                      // Focus Row
                      Row(
                        children: [
                          const Text("Focus:"),
                          const Spacer(),

                          DropdownButton<String>(
                            value: focusSelected,
                            onChanged: (String? value){
                              focusSelected = value!;
                              setStateSB((){});
                            },
                            items: focusList.map<DropdownMenuItem<String>>(
                                    (String value){
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }
                            ).toList(),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                      onPressed: (){
                        setState(() {
                          filterData['age'] = ageSelected;
                          filterData['focus'] = focusSelected;
                          filterData['gender'] = genderSelected;
                        });
                      },
                      child: const Text('Update Filter')
                  )
                ],
              );
            }
          );
        }
    );
  }


  Widget makeSubtitleForCard(Map<String, dynamic>trialInfo){
    int minMonths = trialInfo['age_range'][0];
    int maxMonths = trialInfo['age_range'][1];

    int minYears = minMonths ~/ 12;
    int maxYears = maxMonths ~/ 12;

    String focusString = "";

    for(String f in trialInfo['focus']){
      focusString += "$f, ";
    }
    focusString = focusString.substring(0, focusString.length - 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Age: $minYears - $maxYears\t\tGender: ${trialInfo['gender']}"),
        Text("Focus: $focusString"),
      ],
    );
  }

  Widget trialsListView(List<dynamic> trialsList){

    return ListView.builder(
        itemCount: trialsList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(
                '${trialsList[index]['name']}',
                style: Theme
                    .of(context)
                    .textTheme
                    .titleMedium,
              ),
              trailing: Icon(Icons.chevron_right),
              subtitle: makeSubtitleForCard(trialsList[index]),
              onTap: () {},

            ),
          );
        }
      );

  }

  FutureBuilder trialsBody(){

    var map = new Map<String, dynamic>();
    map['age'] = 'z';
    map['gender'] = 'z';
    map['focus'] = 'z';
    map['sort'] = 'z';

    return FutureBuilder(
      future: http.post(
          Uri.parse(url),
          body: map,
      ),
      builder: (context, snapshot){
        if(snapshot.hasData){
          print('We got data... Does not mean we are ok');

          dynamic response = snapshot.data;

          if(response != null){

            Map<String, dynamic> trialsData = convert.jsonDecode(response.body) as Map<String, dynamic>;
            List<dynamic> trialsDynamicList = trialsData["trial"].toList();

            List<Trial> trialsList = parseTrials(trialsDynamicList);
            return Column(
              children: [
                ElevatedButton(onPressed: showFilterDialog, child: const Text("Filter")),
                Expanded(child: TrialsListView(trialsList, filterData)),
              ],
            );

          }
          else{
            return const Center(
              child: Text("No Data"),
            );

          }

        }

        else if(snapshot.hasError){

          return const Center(
            child: Text("ERROR STUFF HERE"),
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
        title: const Text("Trials"),
      ),

      body: trialsBody(),
    );
  }

}