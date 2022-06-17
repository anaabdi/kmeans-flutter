class Dataset {
  List<Datasets>? datasets;

  Dataset({this.datasets});

  Dataset.fromJson(Map<String, dynamic> json) {
    if (json['datasets'] != null) {
      datasets = <Datasets>[];
      json['datasets'].forEach((v) {
        datasets!.add(new Datasets.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.datasets != null) {
      data['datasets'] = this.datasets!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Datasets {
  int? id;
  double? humidity;
  double? temperature;
  int? stepCount;

  Datasets({this.id, this.humidity, this.temperature, this.stepCount});

  Datasets.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    humidity = json['humidity'];
    temperature = json['temperature'];
    stepCount = json['step_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['humidity'] = this.humidity;
    data['temperature'] = this.temperature;
    data['step_count'] = this.stepCount;
    return data;
  }
}
