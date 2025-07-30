import 'package:flutter/material.dart';
import '../models/product.dart';

class Review {
  final String id;
  final String userName;
  final double rating;
  final String comment;
  final DateTime date;
  final bool isVerifiedPurchase;

  const Review({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
    required this.isVerifiedPurchase,
  });
}

class ProductReviewsPage extends StatefulWidget {
  final Product product;

  const ProductReviewsPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductReviewsPage> createState() => _ProductReviewsPageState();
}

class _ProductReviewsPageState extends State<ProductReviewsPage> {
  final List<Review> _reviews = [
    Review(
      id: '1',
      userName: 'Abdullah Rahman',
      rating: 5.0,
      comment: 'Excellent adjustable dumbbell! The weight adjustment is very smooth and the build quality is outstanding. Perfect for home workouts in Dhaka.',
      date: DateTime(2025, 7, 25),
      isVerifiedPurchase: true,
    ),
    Review(
      id: '2',
      userName: 'Fatim Khan',
      rating: 4.5,
      comment: 'Great product for the price. The dumbbells are sturdy and the weight plates lock securely. Delivery to Chittagong was quick. Highly recommended!',
      date: DateTime(2025, 7, 20),
      isVerifiedPurchase: true,
    ),
    Review(
      id: '3',
      userName: 'Mohammad Hasan',
      rating: 5.0,
      comment: 'Amazing quality! I can adjust from 5kg to 40kg easily. Perfect for my home gym in Sylhet. The grip is comfortable even during long workouts.',
      date: DateTime(2025, 7, 18),
      isVerifiedPurchase: true,
    ),
    Review(
      id: '4',
      userName: 'Rashid Hasan',
      rating: 4.0,
      comment: 'Good adjustable dumbbells. The mechanism works well but takes a bit of practice to get used to. Overall satisfied with the purchase.',
      date: DateTime(2025, 7, 15),
      isVerifiedPurchase: true,
    ),
    Review(
      id: '5',
      userName: 'Kamrul Islam',
      rating: 5.0,
      comment: 'Fantastic! These dumbbells have revolutionized my home workouts. The space-saving design is perfect for my small apartment in Dhanmondi.',
      date: DateTime(2025, 7, 12),
      isVerifiedPurchase: true,
    ),
    Review(
      id: '6',
      userName: 'Nasir Ahmed',
      rating: 4.5,
      comment: 'Very impressed with the build quality. The weight adjustment is quick and secure. Great value for money. Shipping to Rajshahi was fast.',
      date: DateTime(2025, 7, 10),
      isVerifiedPurchase: true,
    ),
    Review(
      id: '7',
      userName: 'Salman Akthter',
      rating: 4.0,
      comment: 'Good product overall. The dumbbells feel solid and the weight range is perfect for my fitness goals. Packaging was excellent.',
      date: DateTime(2025, 7, 8),
      isVerifiedPurchase: false,
    ),
    Review(
      id: '8',
      userName: 'Rafiqul Haque',
      rating: 5.0,
      comment: 'Outstanding adjustable dumbbells! Easy to use, durable construction, and saves so much space. Best fitness investment I have made.',
      date: DateTime(2025, 7, 5),
      isVerifiedPurchase: true,
    ),
  ];

  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', '5 Stars', '4 Stars', '3 Stars', '2 Stars', '1 Star'];

  List<Review> get filteredReviews {
    if (_selectedFilter == 'All') return _reviews;
    
    int targetRating = int.parse(_selectedFilter.split(' ')[0]);
    return _reviews.where((review) => review.rating.floor() == targetRating).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Reviews',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.product.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.fitness_center,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < widget.product.rating.floor()
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 20,
                                  );
                                }),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.product.rating}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${_reviews.length} reviews)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filterOptions.length,
                    itemBuilder: (context, index) {
                      final filter = _filterOptions[index];
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? Theme.of(context).primaryColor 
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected 
                                    ? Theme.of(context).primaryColor 
                                    : Colors.grey.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                color: isSelected 
                                    ? Colors.white 
                                    : Theme.of(context).colorScheme.onSurface,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredReviews.length,
              itemBuilder: (context, index) {
                final review = filteredReviews[index];
                return _buildReviewCard(review);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    review.userName.split(' ').map((name) => name[0]).take(2).join(''),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.userName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (review.isVerifiedPurchase) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < review.rating.floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${review.rating}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${review.date.day}/${review.date.month}/${review.date.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
