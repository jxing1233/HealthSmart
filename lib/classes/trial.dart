class Trial{

  String name;
  String gender;
  List<dynamic> focus;
  int minAgeMonths;
  int maxAgeMonths;

  String? url;
  String? description;
  String? ethnicity;
  String? location;

  Trial(this.name, this.gender, this.focus, this.minAgeMonths, this.maxAgeMonths, [this.url, this.location, this.ethnicity] );

  Map<String, dynamic> getJson(){
    Map<String, dynamic> data = {
      "name": name,
      "gender" : gender,
      "focus" : focus,
      "minAgeMonths" : minAgeMonths,
      "maxAgeMonths" : maxAgeMonths,
      "url" : url,
      "location" : location,
      "ethnicity" : ethnicity,
    };

    if(url != null){
      data["url"] = url;
    }

    if(description != null){
      data["description"] = description;
    }

    if(location != null){
      data["location"] = location;
    }

    if(ethnicity != null){
      data["ethnicity"] = ethnicity;
    }

    return data;
  }

  @override
  String toString() {
    String s = "name:\t${this.name}\n";
    s = s + "gender:\t${this.gender}\n";
    s = s + "minAgeMonths:\t${this.minAgeMonths}\n";
    s = s + "maxAgeMonths:\t${this.maxAgeMonths}\n";

    if(this.location != null) {
      s = s + "location:\t${this.location}\n";
    }
    else{
      s = s + "location:\tmissing\n";
    }

    if(this.description != null) {
      s = s + "description:\t${this.description}\n";
    }
    else{
      s = s + "description:\tmissing\n";
    }

    if(this.url != null) {
      s = s + "url:\t${this.url}\n";
    }
    else{
      s = s + "url:\tmissing\n";
    }


    s = s + "focus:\n";
    for(dynamic d in this.focus){
      s = s + "\t\t$d\n";
    }

    if(this.ethnicity != null) {
      s = s + "ethnicity:\t${this.ethnicity}\n";
    }
    else{
      s = s + "ethnicity:\tmissing\n";
    }

    return s;

  }

}