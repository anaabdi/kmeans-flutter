class KMeansResponse {
  int? totalCluster;
  int? totalIteration;
  String? duration;
  double? highestStandardDeviation;
  Map<String, dynamic>? initialCentroids;
  Map<String, dynamic>? results;

  KMeansResponse({
    this.totalCluster,
    this.totalIteration,
    this.duration,
    this.initialCentroids,
    this.results,
    this.highestStandardDeviation,
  });

  KMeansResponse.fromJson(Map<String, dynamic> json) {
    totalCluster = json['total_cluster'];
    totalIteration = json['total_iteration'];
    duration = json['duration'];
    results = json['results'] != null ? json['results'] : null;
    initialCentroids =
        json['initial_centroids'] != null ? json['initial_centroids'] : null;
    highestStandardDeviation = json['highest_standard_deviation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_cluster'] = this.totalCluster;
    data['duration'] = this.duration;
    data['highest_standard_deviation'] = this.highestStandardDeviation;
    // if (this.results != null) {
    //   data['results'] = this.results!;
    // }
    return data;
  }
}
