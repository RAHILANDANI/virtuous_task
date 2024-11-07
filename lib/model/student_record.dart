class Record {
  int? id;
  String name;
  int age;
  String address;
  bool isFavorite;

  Record({
    this.id,
    required this.name,
    required this.age,
    required this.address,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'address': address,
    };
  }

  // Convert a Map to a Record
  factory Record.fromMap(Map<String, dynamic> map) {
    return Record(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      address: map['address'],
      isFavorite: map['isFavorite'] == 1,
    );
  }
}
