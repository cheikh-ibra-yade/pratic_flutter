class Category {
  final int id;
  final String name;
  final String avatar;

  Category({required this.id, required this.name, required this.avatar});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json["id"],
      name: json["name"],
      avatar: json["avatar"],
    );
  }
}
