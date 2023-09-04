import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'login_page.dart';

class AccountPage extends StatefulWidget {
  @override
  State createState() => _State();
}

class _State extends State {

  void showSnackBar(String message){
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.yellow,
            onPressed: (){ ScaffoldMessenger.of(context).hideCurrentSnackBar(); } ,
          ),
        )
    );
  }

  void navigateToHomePage(){
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (builder) => HomePage()),
            (route) => false
    );
  }

  void navigateToLoginScreen(){
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (builder) => LoginPage()),
            (route) => false
    );
  }

  void logout() async{
    await FirebaseAuth.instance.signOut();
    navigateToLoginScreen();
  }

  void deleteAccount() async{
    await FirebaseAuth.instance.currentUser!.delete();
    await FirebaseAuth.instance.signOut();
    navigateToLoginScreen();
  }

  void showDeleteAlert(){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
              title: const Text("Delete Account"),
              content: const Text("Are you sure you want to delete your account. This action can not be undone."),
              actions: [

                ElevatedButton(
                  onPressed: (){ Navigator.of(context).pop(); },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: (){ deleteAccount(); },
                  child: const Text('Delete'),
                ),
              ]
          );
        }
    );
  }

  Future<void> saveUserInfo(String raceSelected, String ethSelected, int ageSelected, int sexSelected) async{
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String path = "user_data/$uid";
    DatabaseReference ref = FirebaseDatabase.instance.ref(path);

    // age: -1 means unspecified
    // sex: -1 unspecified, 0 male, 1 female
    var userData = {
      "age": ageSelected,
      "sex": sexSelected,
      "ethnicity": ethSelected,
      "race": raceSelected,
    };
    await ref.update(userData);
    setState(() { Navigator.pop(context); });
  }


  void showUpdateUserDialog(Map<dynamic, dynamic> data){
    showDialog(
        context: context,
        builder: (context){
          List<String> ethList = [
            'Native American',
            'African American',
            'Hispanic',
            'Middle Eastern',
            'Pacific Islander',
            'White',
            'South Asian',
            'Asian',
            'N/A'
          ];
          List<int> ageList = List<int>.generate(101, (i) => i);
          List<int> sexList = [0,1,-1];

          String ethSelected = data['ethnicity'];
          int ageSelected = data['age'];
          int sexSelected = data['sex'];

          return StatefulBuilder(
            builder: (context, setStateSB){

              return AlertDialog(
                title: const Text("Update Info"),
                content: SingleChildScrollView(
                  child: Column(
                    children: [

                      // Ethnicity Row
                      Row(
                        children: [
                          const Text("Ethnicity:"),
                          const Spacer(),
                          DropdownButton<String>(
                            value: ethSelected,
                            onChanged: (String? value){
                              ethSelected = value!;
                              setStateSB((){});
                            },
                            items: ethList.map<DropdownMenuItem<String>>(
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
                                      if (value < 1) {valueText = "unspecified";}
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text(valueText),
                                  );
                                }
                            ).toList(),
                          ),
                        ],
                      ),


                      // Sex Row
                      Row(
                        children: [
                          const Text("Sex:"),
                          const Spacer(),
                          DropdownButton<int>(
                            value: sexSelected,
                            onChanged: (int? value){
                              sexSelected = value!;
                              setStateSB((){});
                            },
                            items: sexList.map<DropdownMenuItem<int>>(
                                    (int value){
                                  String valueText = "unspecified";

                                  if (value == 0) {valueText = "male";}
                                  else if (value == 1) {valueText = "female";}

                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text(valueText),
                                  );
                                }
                            ).toList(),
                          ),
                        ],
                      ),


                    ],
                  )
                ),
                actions: [
                  ElevatedButton(onPressed: (){Navigator.pop(context);}, child: const Text("Cancel")),
                  ElevatedButton(
                      onPressed: () async {await saveUserInfo("Unspecified", ethSelected, ageSelected, sexSelected);},
                      child: const Text("Save")
                  ),
                ]
              );

            }
          );

        }
    );
  }


  Widget displayUserDataWidget(Map<dynamic, dynamic> data){
    List<dynamic> keys = data.keys.toList();
    // ethnicity, race, sex, age
    List<Widget> children = [];

    children.add(
        Row(
          children: [
            const Text("Ethnicity"),
            const Spacer(),
            Text("${data["ethnicity"]}"),
          ],
        )
    );

    try{
      int age = data['age'] as int;
      String s_age = age > 0 ? "$age" : "unspecified";

      children.add(
          Row(
            children: [
              const Text("Age"),
              const Spacer(),
              Text(s_age),
            ],
        )
      );
    }  on Exception catch(_){
      children.add(
          const Row(
            children: [
              Text("Age"),
              Spacer(),
              Text("unspecified"),
            ],
          )
      );
    }

    try{
      int sex = data['sex'] as int;
      String s_sex = "unspecified";
      if(sex == 0) { s_sex = "male"; }
      else if(sex == 1) { s_sex = "female"; }

      children.add(
          Row(
            children: [
              const Text("Sex"),
              const Spacer(),
              Text(s_sex),
            ],
          )
      );
    }  on Exception catch(_){
      children.add(
          const Row(
            children: [
              Text("Sex"),
              Spacer(),
              Text("unspecified"),
            ],
          )
      );
    }

    children.add(ElevatedButton(
        onPressed: (){
          showUpdateUserDialog(data);
        },
        child: const Text("Update User Info")
      )
    );


    return Column(
      children: children,
    );
  }


  FutureBuilder getUserData(){
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String path = "user_data/$uid";
    return FutureBuilder(
      future: FirebaseDatabase.instance.ref(path).get(),
      builder: (context, snapshot){
        if(snapshot.hasError){
          // Error with connection
          return const Text("An Error has Occurred, try again later");
        }
        else if(snapshot.hasData){
          if(snapshot.data.value == null){
            // Error with Data
            return const Text("There is no data on this account");
          }
          else{
            // No Error
            return displayUserDataWidget(snapshot.data.value);
          }
        }
        return const Center( child: CircularProgressIndicator());
      }
    );
  }



  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(
          title: const Text("Account"),
        ),
        body: Center(
            child: Column(
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 125
                ),

                Padding(
                  padding: const EdgeInsets.all(35.0),
                  child: getUserData(),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.only(bottom: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: logout,
                          child: const Text("Logout")
                      ),

                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: showDeleteAlert,
                          child: const Text("Delete Account")
                      ),


                    ],
                  ),
                ),
              ],
            )
        )
    );
  }
}
