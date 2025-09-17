import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/chat_models.dart';
import '../../core/themes/colors.dart';
import '../../core/themes/text_styles.dart';

class CreateChatRoomScreen extends StatefulWidget {
  const CreateChatRoomScreen({Key? key}) : super(key: key);

  @override
  State<CreateChatRoomScreen> createState() => _CreateChatRoomScreenState();
}

class _CreateChatRoomScreenState extends State<CreateChatRoomScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  ChatRoomType _roomType = ChatRoomType.direct;
  List<UserSearchResult> _searchResults = [];
  List<UserSearchResult> _selectedUsers = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _searchUsers(String query) async {
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await context.read<ChatProvider>().searchUsers(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _selectUser(UserSearchResult user) {
    setState(() {
      if (_selectedUsers.any((u) => u.id == user.id)) {
        _selectedUsers.removeWhere((u) => u.id == user.id);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  void _createRoom() async {
    if (_roomType == ChatRoomType.direct) {
      if (_selectedUsers.length != 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select exactly one user for direct chat'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      if (_selectedUsers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one user for group chat'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a group name'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    try {
      ChatRoom room;
      if (_roomType == ChatRoomType.direct) {
        room = await context.read<ChatProvider>().createDirectChatRoom(
          _selectedUsers.first.id,
        );
      } else {
        room = await context.read<ChatProvider>().createGroupChatRoom(
          name: _nameController.text.trim(),
          participantIds: _selectedUsers.map((u) => u.id).toList(),
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(room: room),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating room: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'New Chat',
          style: AppTextStyles.heading2,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _createRoom,
            child: const Text(
              'Create',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Room type selection
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildRoomTypeOption(
                    ChatRoomType.direct,
                    'Direct Chat',
                    Icons.person,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildRoomTypeOption(
                    ChatRoomType.group,
                    'Group Chat',
                    Icons.group,
                  ),
                ),
              ],
            ),
          ),
          
          // Group name input (only for group chats)
          if (_roomType == ChatRoomType.group) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Group Name',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter group name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description (Optional)',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter group description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchUsers,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          
          // Selected users
          if (_selectedUsers.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Users',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedUsers.length,
                      itemBuilder: (context, index) {
                        final user = _selectedUsers[index];
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColors.primary,
                                    backgroundImage: user.avatarUrl != null
                                        ? NetworkImage(user.avatarUrl!)
                                        : null,
                                    child: user.avatarUrl == null
                                        ? Text(
                                            user.username[0].toUpperCase(),
                                            style: AppTextStyles.bodySmall.copyWith(
                                              color: AppColors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: GestureDetector(
                                      onTap: () => _selectUser(user),
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 12,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.displayName ?? user.username,
                                style: AppTextStyles.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
          
          // Search results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 64,
                              color: AppColors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Search for users to add',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Type at least 2 characters to search',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
                          final isSelected = _selectedUsers.any((u) => u.id == user.id);
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.primary,
                                backgroundImage: user.avatarUrl != null
                                    ? NetworkImage(user.avatarUrl!)
                                    : null,
                                child: user.avatarUrl == null
                                    ? Text(
                                        user.username[0].toUpperCase(),
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              title: Text(
                                user.displayName ?? user.username,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                user.username,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.grey,
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: AppColors.primary,
                                    )
                                  : const Icon(
                                      Icons.add_circle_outline,
                                      color: AppColors.grey,
                                    ),
                              onTap: () => _selectUser(user),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomTypeOption(ChatRoomType type, String title, IconData icon) {
    final isSelected = _roomType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _roomType = type;
          if (type == ChatRoomType.direct) {
            _selectedUsers.clear();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.white : AppColors.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.white : AppColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}