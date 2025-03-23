class Course {
  final String title;
  final String platform;
  final double rating;
  final String productLink;  // Keeping this as productLink for consistency
  final String image_link;
  final String description;
  final String instructor;
  final String organization;
  final int reviews;
  final double price;
  final bool isTrending;
  final bool isPopular;

  Course({
    required this.title,
    required this.platform,
    required this.rating,
    required this.productLink,
    required this.image_link,
    required this.description,
    required this.instructor,
    required this.organization,
    required this.reviews,
    required this.price,
    this.isTrending = false,
    this.isPopular = false,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      title: json['title'] ?? '',
      platform: json['platform'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      productLink: json['product_link'] ?? '',
      image_link: json['image_link'] ?? '',
      description: json['description'] ?? '',
      instructor: json['instructor'] ?? '',
      organization: json['organization'] ?? '',
      reviews: json['reviews'] ?? 0,
      price: (json['price'] ?? 0.0).toDouble(),
      isTrending: json['isTrending'] ?? false,
      isPopular: json['isPopular'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'platform': platform,
      'rating': rating,
      'product_link': productLink,
      'image_link': image_link,
      'description': description,
      'instructor': instructor,
      'organization': organization,
      'reviews': reviews,
      'price': price,
      'isTrending': isTrending,
      'isPopular': isPopular,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Course &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          platform == other.platform;
  
  @override
  int get hashCode => title.hashCode ^ platform.hashCode;
}
