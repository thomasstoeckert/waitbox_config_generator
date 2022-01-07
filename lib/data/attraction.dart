class Attraction {
  final String entityID;
  final String name;
  final String entityType;

  const Attraction(
      {this.entityID = "UNDEFINED",
      this.name = "UNDEFINED",
      this.entityType = "UNDEFINED"});

  factory Attraction.fromJSON(Map jsonData) {
    return Attraction(
        entityID: jsonData["id"],
        name: jsonData["name"],
        entityType: jsonData["entityType"]);
  }
}
