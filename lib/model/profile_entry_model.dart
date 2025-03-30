class ProfileEntryItem {
  int? id;
  String? name;

  ProfileEntryItem({this.id, required this.name});

  ProfileEntryItem.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    name = map["name"];
  }

  Map<String, dynamic> toMap() {
    return {"id": id, "name": name};
  }
}
