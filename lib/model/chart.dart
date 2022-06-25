class ChartData {
  int id;
  String clusterName;
  double totalInKMeans;
  double totalInKMedoids;

  ChartData({
    required this.id,
    required this.clusterName,
    required this.totalInKMeans,
    required this.totalInKMedoids,
  });
}
