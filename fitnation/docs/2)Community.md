
## 2. Community Feature

The Community feature screens and widgets are located in `lib/Screens/Community/` and `lib/widgets/community/`, using models from `lib/models/`.

### 2.1 Overview

This feature includes screens for viewing a feed of posts, exploring and joining community groups, viewing group details, and creating new posts or communities.

**Screens (`lib/Screens/Community/`):**

1.  Community Home (`CommunityHome.dart`)
2.  Community Groups (`CommunityGroups.dart`)
3.  Group Detail (`GroupDetailsScreen.dart`)
4.  Create Post (`CreatePostScreen.dart`)
5.  Create Community (`CreateCommunity.dart`)
6.  Post Detail (Planned, not detailed yet)

### 2.2 Data Models (`lib/models/`)

*   **`User.dart`**: Represents a user profile.
*   **`PostReact.dart`**: Represents a user's reaction (like) to a post.
*   **`PostComment.dart`**: Represents a comment on a post.
*   **`WorkoutPostModel.dart`**: Holds specific data for a workout-type post (likely embedded or referenced by `PostModel`).
*   **`ChallengePostModel.dart`**: Holds specific data for a challenge-type post (likely embedded or referenced by `PostModel`).
*   **`PostModel.dart`**: Represents a single post. Includes a `postType` (e.g., using an enum) and holds or references the data for `text`, `workout` (`WorkoutPostModel`), or `challenge` (`ChallengePostModel`) types. Includes author (`User`), react/comment counts, media URL, etc.
*   **`Community.dart`**: Represents a community group. Includes creator (`User`), name, description, image URLs (`imageUrl`, `coverImageUrl`), privacy status, member/post counts, etc.
*   **`CommunityMember.dart`**: Represents a user's membership in a community. Includes role (`CommunityMemberRole` enum, likely defined in `Community.dart`), joined date, and the member's `User` object.
*   **`CategoryChip.dart` (`lib/widgets/CategoryChip.dart`)**: A reusable widget for displaying categories, used in community contexts.

### 2.3 Screens (`lib/Screens/Community/`)

#### 2.3.1 `CommunityHome.dart`

*   **Purpose:** Main entry point, displays a feed of posts and access to groups.
*   **UI:** AppBar (logo, title, create button), TabBar (Feed, Groups), Stories Section (horizontal list of `StoryBubble`s), Post Feed (vertical list of `PostCard`s).
*   **Data/Logic:** Fetches/loads feed posts and stories via providers (`data_providers.dart`). Uses a `TabController`. Feed view displays `StoryBubble`s and `PostCard`s. Groups tab likely navigates to `CommunityGroups.dart`.
*   **Navigation:** To `CommunityGroups.dart` (via tab), `CreatePostScreen.dart` (from AppBar button), Post Detail Screen (from tapping a post/comment button).

#### 2.3.2 `CommunityGroups.dart`

*   **Purpose:** Displays a list of available community groups.
*   **UI:** AppBar (logo, title, create button), Search Bar, TabBar (All, My Groups, Popular, Trending), Group List (vertical list of `GroupCard.dart`s).
*   **Data/Logic:** Fetches/loads community groups via providers, filtered by tab and search query. Uses a `TabController`. Displays `GroupCard.dart`s.
*   **Navigation:** To `GroupDetailsScreen.dart` (from tapping card), `CreateCommunity.dart` (from AppBar button).

#### 2.3.3 `GroupDetailsScreen.dart`

*   **Purpose:** Detailed view of a specific community.
*   **UI:** AppBar (back button, options), Cover Image, Community Info section (profile image, name, stats, join/notify buttons), TabBar (Posts, About, Members), Tab content area.
*   **Data/Logic:** Fetches/loads detailed `Community.dart` data, associated `PostModel.dart`s, and `CommunityMember.dart`s via providers. Uses a `TabController`. Posts tab displays `PostCard.dart`s and a "Create Post" button. About tab displays description, rules, etc. Members tab displays a list of members. Manages join/leave state and notification toggle state.
*   **Navigation:** Back to `CommunityGroups.dart`, to `CreatePostScreen.dart` (passing group ID), to Post Detail Screen (from tapping post).

#### 2.3.4 `CreatePostScreen.dart`

*   **Purpose:** Allows users to create different types of posts.
*   **UI:** AppBar (back/cancel button, title), TabBar (Post, Workout, Challenge), Tab content area for each form.
*   **Data/Logic:** Uses a `TabController`. Each tab (likely implemented as separate widgets or sections within the screen) manages its form state. Handles image picking. Validation logic. Submission logic collects data based on the active tab, handles file uploads (via `API_Services.dart`), constructs the appropriate `PostModel.dart` structure (including `WorkoutPostModel.dart` or `ChallengePostModel.dart` data), and calls `API_Services.dart` to create the post. Manages a submitting state.
*   **Navigation:** Back to the previous screen after submission or cancellation.

#### 2.3.5 `CreateCommunity.dart`

*   **Purpose:** Allows users to create a new community group.
*   **UI:** AppBar (back button, title), Form fields (Name, Description, Categories, Images, Private Toggle), Action buttons (Cancel, Create).
*   **Data/Logic:** Manages form state. Handles image picking. Validation logic. Submission logic handles image uploads (via `API_Services.dart`), constructs the `Community.dart` model, and calls `API_Services.dart`. Manages a submitting state. Uses `CategoryChip.dart` for displaying selected categories.
*   **Navigation:** Back to `CommunityGroups.dart` after creation or cancellation.

### 2.4 Reusable Community Widgets (`lib/widgets/community/`)

*   **`StoryBubble.dart`**: Displays a user's story avatar.
*   **`PostCard.dart`**: Renders a single post item. Contains logic to render different content based on the post type, potentially using embedded widgets for workout/challenge details. Includes user info, timestamp, content, and action buttons.
*   **`GroupCard.dart`**: Renders a single community group item in the list. Includes image, name, description, categories (using `CategoryChip.dart`), counts, and join/joined button.



### 2.5. Community Feature Implementation

*   **Screens:** `lib/Screens/Community/`
    *   `CommunityHome.dart`: Main feed, stories, tabs (Feed, Groups). Displays `StoryBubble.dart` and `PostCard.dart`. Navigates to `CommunityGroups.dart` and `CreatePostScreen.dart`.
    *   `CommunityGroups.dart`: List of communities, search, tabs (All, My Groups, Popular, Trending). Displays `GroupCard.dart` (from `widgets/community/`). Navigates to `GroupDetailsScreen.dart` and `CreateCommunity.dart`.
    *   `GroupDetailsScreen.dart`: Detailed community view, cover image, info, tabs (Posts, About, Members). Displays `PostCard.dart` in Posts tab. Navigates to `CreatePostScreen.dart` (with group context) and Post Detail screen. Uses `CategoryChip.dart`.
    *   `CreatePostScreen.dart`: Create post interface with tabs (Post, Workout, Challenge). Each tab contains form fields for the specific post type data (`PostModel.dart`, `WorkoutPostModel.dart`, `ChallengePostModel.dart`). Handles image picking. Calls `API_Services.createPost`.
    *   `CreateCommunity.dart`: Create community interface. Form fields for `Community.dart` data (name, description, images, privacy, categories). Handles image picking. Calls `API_Services.createCommunity`. Uses `CategoryChip.dart`.
*   **Models:** `lib/models/` - `User.dart`, `PostModel.dart` (including `PostType`, `WorkoutPostModel.dart`, `ChallengePostModel.dart`), `PostReact.dart`, `PostComment.dart`, `Community.dart` (including `CommunityMemberRole`), `CommunityMember.dart`.
*   **Widgets:** `lib/widgets/community/` - `StoryBubble.dart`, `PostCard.dart` (handles rendering different post types), `GroupCard.dart`. Also uses `lib/widgets/CategoryChip.dart`.
*   **Data Flow:** Screens watch providers (`data_providers.dart`) that fetch data via `API_Services.dart`. Actions (create, join, react, comment) call methods on Riverpod notifiers that interact with `API_Services.dart` and invalidate/refresh relevant providers to update the UI.


