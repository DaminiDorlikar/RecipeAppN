class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.image,
    required this.rating,
    required this.cuisine,
    required this.ingredients,
    required this.instructions,
    required this.cookTimeMinutes,
  });

  final int id;
  final String name;
  final String image;
  final double rating;
  final String cuisine;
  final List<String> ingredients;
  final List<String> instructions;
  final int cookTimeMinutes;
}
