import 'package:waitbox_config_generator/data/attraction.dart';

class Park {
  final String entityID;
  final String name;
  final List<Attraction> attractions;

  const Park(
      {this.entityID = "UNDEFINED",
      this.name = "UNDEFINED",
      this.attractions = const []});

  factory Park.fromJSON(Map jsonData) {
    // Parse each attraction from the result
    List<Attraction> parsedAttractions = [];

    // If we have child data, parse and store it.
    if (jsonData.containsKey("children")) {
      for (var child in jsonData["children"]) {
        Attraction parsedChild = Attraction.fromJSON(child);
        if (parsedChild.entityType ==
                "ATTRACTION" /* ||
            parsedChild.entityType == "SHOW" */
            ) {
          parsedAttractions.add(Attraction.fromJSON(child));
        }
      }
    }

    // Sort children by name
    parsedAttractions.sort((a, b) => a.name.compareTo(b.name));

    // Build our final object
    return Park(
        entityID: jsonData["id"],
        name: jsonData["name"],
        attractions: parsedAttractions);
  }

  Map toJSON() {
    return {
      "parkID": entityID,
      // Return a list of attraction IDs
      "attractions": attractions.map((e) => e.entityID)
    };
  }
}
