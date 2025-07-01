// lib/models/story_model.dart
import 'package:fitnation/models/User.dart';

class StoryContentItem {
  final String type; // "image" | "text" | "workout"
  final String content;
  final String? completedWorkoutSession;
  final String? gymLocation;
  final DateTime? time;
  final Map<String, dynamic>? locationDetails; // For location stories
  final Map<String, dynamic>? workoutDetails; // For workout stories

  StoryContentItem({
    required this.type,
    required this.content,
    this.completedWorkoutSession,
    this.gymLocation,
    this.time,
    this.locationDetails,
    this.workoutDetails,
  });

  factory StoryContentItem.fromJson(Map<String, dynamic> json) {
    return StoryContentItem(
      type: json['type'] as String,
      content: json['content'] as String,
      completedWorkoutSession: json['completedWorkoutSession'] as String?,
      gymLocation: json['gymLocation'] as String?,
      time: json['time'] != null ? DateTime.parse(json['time'] as String) : null,
      locationDetails: json['locationDetails'] as Map<String, dynamic>?,
      workoutDetails: json['workoutDetails'] as Map<String, dynamic>?,
    );
  }
}

final List<Story> dummyStories = [
  Story(
    id: 's1',
    name: 'Your Story',
    isYourStory: true,
    image: null,
  ),
  Story(
    id: 's2',
    name: 'Jordan Smith',
    image: 'https://randomuser.me/api/portraits/men/1.jpg',
    isYourStory: false,
    storyContent: [
      StoryContentItem(
        type: 'location',
        content: 'Gold\'s Gym', // This will be the location name
        locationDetails: {
          'address': '123 Fitness St, City',
          'latitude': 34.052235,
          'longitude': -118.243683,
        },
        time: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    ],
  ),
  Story(
    id: 's3',
    name: 'Alex Johnson',
    image: 'https://randomuser.me/api/portraits/men/2.jpg',
    isYourStory: false,
    storyContent: [
      StoryContentItem(
        type: 'text',
        content: 'Feeling stronger every day! 💪🦆🔥',
        time: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      StoryContentItem(
        type: 'workout',
        content: 'Push Day', // This will be the workout name
        workoutDetails: {
          'duration': 45, // in minutes
          'intensity': 8, // on a scale of 1-10
          'exercises': [
            {'name': 'Bench Press', 'sets': 4, 'reps': '8', 'weight': '80kg'},
            {'name': 'Shoulder Press', 'sets': 3, 'reps': '10', 'weight': '25kg'},
            {'name': 'Tricep Dips', 'sets': 3, 'reps': '12', 'weight': null},
          ],
        },
        time: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ],
  ),
  Story(
    id: 's4',
    name: 'Charlie',
    image: 'https://randomuser.me/api/portraits/men/3.jpg',
    isYourStory: false,
    storyContent: [
      StoryContentItem(
        type: 'image',
        content: 'https://picsum.photos/id/239/200/300',
        completedWorkoutSession: 'Upper Body Strength',
        gymLocation: 'City Fitness Center',
        time: DateTime.now().subtract(const Duration(days: 1)),
      ),
      StoryContentItem(
        type: 'text',
        content: 'Crushed my personal best today!',
      ),
    ],
  ),
  Story(
    id: 's5',
    name: 'Diana',
    image: 'https://randomuser.me/api/portraits/women/4.jpg',
    isYourStory: false,
    storyContent: [
      StoryContentItem(
        type: 'image',
        content: 'https://picsum.photos/id/240/200/300',
        completedWorkoutSession: 'Yoga Flow',
        gymLocation: 'Serenity Yoga Studio',
        time: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ],
  ),
];

class Story {
  final String id;
  final String name;
  final String? image; // URL, nullable
  final bool isYourStory;
  final List<StoryContentItem>? storyContent;

  Story({
    required this.id,
    required this.name,
    this.image,
    this.isYourStory = false,
    this.storyContent,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String?,
      isYourStory: json['isYourStory'] as bool? ?? false,
      storyContent: (json['storyContent'] as List<dynamic>?)
          ?.map((item) => StoryContentItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

// lib/models/group_model.dart
class Group {
  final String id;
  final String name;
  final String description;
  final int memberCount;
  final int postCount;
  final String image; // URL
  final bool trending;
  final List<String> categories;
  final bool joined;
  // From GroupDetail
  final String? coverImage; // URL
  final DateTime? createdAt;
  final List<String>? rules;


  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.memberCount,
    required this.postCount,
    required this.image,
    required this.trending,
    required this.categories,
    required this.joined,
    this.coverImage,
    this.createdAt,
    this.rules,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      memberCount: json['memberCount'] as int,
      postCount: json['postCount'] as int,
      image: json['image'] as String,
      trending: json['trending'] as bool? ?? false, // Handle if not always present
      categories: List<String>.from(json['categories'] as List),
      joined: json['joined'] as bool,
      coverImage: json['coverImage'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      rules: json['rules'] != null ? List<String>.from(json['rules'] as List) : null,
    );
  }
}

/// A community member, extending the base User model with extra fields.
class Member extends User {
  /// The member’s display name (e.g. full name, nickname).
  final String displayName;

  /// URL to the member’s avatar or profile image.
  final String imageUrl;

  /// The member’s role in the community (e.g. “admin”, “moderator”, “member”).
  final String communityRole;

  /// When the user joined the community.
  final DateTime joinDate;

  Member({
    required String id,
    required String username,
    required String email,
    required UserRole userRole,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.displayName,
    required this.imageUrl,
    required this.communityRole,
    required this.joinDate,
  }) : super(
          id: id,
          username: username,
          email: email,
          role: userRole,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      userRole: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.user,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      displayName: json['display_name'] as String,
      imageUrl: json['image_url'] as String,
      communityRole: json['community_role'] as String,
      joinDate: DateTime.parse(json['join_date'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    return {
      ...data,
      'display_name': displayName,
      'image_url': imageUrl,
      'community_role': communityRole,
      'join_date': joinDate.toIso8601String(),
    };
  }
}
