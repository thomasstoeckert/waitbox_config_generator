class Configuration {
  final int refreshFrequency;
  final Map<String, List<String>> parks;

  Configuration({this.refreshFrequency = 5, this.parks = const {}});

  factory Configuration.fromJSON(Map jsonData) {
    // Filter the native data type of the json map into our string list
    Map<String, List<String>> parks = {};
    jsonData["parks"].forEach((park) {
      String parkID = park["parkID"];
      parks[parkID] = List<String>.from(park["attractions"]);
    });

    return Configuration(
        refreshFrequency: jsonData["refreshFrequency"], parks: parks);
  }

  Map toJSON() {
    List<Map> parksList = [];
    parks.forEach((key, value) {
      parksList.add({"parkID": key, "attractions": value});
    });
    return {"refreshFrequency": refreshFrequency, "parks": parksList};
  }

  int calculateCurrentRowNumber() {
    int numRows = 0;

    if (parks.isEmpty) return numRows;

    parks.forEach((parkID, attractionIDs) {
      // Each park has +3 rows (one for name, one for post-name break,
      //  one for post-park break)
      numRows += 3;

      // Each attraction gets one row
      numRows += attractionIDs.length;
    });

    return numRows;
  }
}
