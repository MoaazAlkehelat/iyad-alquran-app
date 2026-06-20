class BookmarkModel {

  final String name;

  final int page;

  BookmarkModel({
    required this.name,
    required this.page,
  });

  Map<String, dynamic> toMap() {

    return {

      'name': name,

      'page': page,
    };
  }

  factory BookmarkModel.fromMap(
      Map<String, dynamic> map,
      ) {

    return BookmarkModel(

      name: map['name'],

      page: map['page'],
    );
  }
}