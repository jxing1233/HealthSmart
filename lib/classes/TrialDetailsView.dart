import 'dart:developer';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'trial.dart';

class TrialsDetailsView extends StatefulWidget{

  final Trial trial;
  const TrialsDetailsView(this.trial, {super.key});

  State createState() => _State();

}

class _State extends State<TrialsDetailsView>{

  Widget urlRow(){
    if(widget.trial.url != null){
      if(widget.trial.url == "N/A"){
        return Container();
      }

      return Row(
        children: [
          const Text("URL:"),
          const Spacer(),
          RichText(text:
            TextSpan(
              text: "Open Link",
              style: TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()..onTap = () async {
                print(widget.trial.url);
                Uri _url = Uri.parse(widget.trial.url!);
                await launchUrl(_url);
              },
            ),
          ),
        ],
      );
    }
    return Container();
  }


  Widget ethnicityRow(){
    // Age Row
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Ethnicity:"),
        const Spacer(),
        Expanded(child: Text("${widget.trial.ethnicity}")),
      ],
    );

  }


  Widget locationRow(){
    // Age Row
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Location:"),
        const Spacer(),
        Expanded(child: Text("${widget.trial.location}")),
      ],
    );

  }


  @override
  Widget build(context){

    print(widget.trial);
    print(widget.trial.location);

    int minMonths = widget.trial.minAgeMonths;
    int maxMonths = widget.trial.maxAgeMonths;

    int minYears = minMonths ~/ 12;
    int maxYears = maxMonths ~/ 12;

    List<Widget> focusTextList = [];
    for(dynamic focus in widget.trial.focus){
      focusTextList.add(
        Text(
          "$focus",
          softWrap: true,
          textAlign: TextAlign.end,
        )
      );
    }

    List<Widget> locationTextList = [];
    if(widget.trial.location != null){
      print(widget.trial.location);
    }



    return SingleChildScrollView(
      child: Column(
        children: [

          // Gender Row
          Row(
            children: [
              const Text("Gender:"),
              const Spacer(),
              Text(widget.trial.gender.toUpperCase()),
            ],
          ),

          // Age Row
          Row(
            children: [
              const Text("Age:"),
              const Spacer(),
              Text("$minYears - $maxYears"),
            ],
          ),

          // Focus Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Focus:"),
              const Spacer(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: focusTextList
                ),
              )
            ],
          ),

          ethnicityRow(),
          urlRow(),
          locationRow(),

        ],
      ),
    );
  }
}