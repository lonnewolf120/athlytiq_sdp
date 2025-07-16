import 'package:flutter/material.dart';
import 'suggested_tab.dart';
import 'facebook_tab.dart';
import 'contacts_tab.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Search"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.group), text: "Suggested"),
              Tab(icon: Icon(Icons.facebook), text: "Facebook"),
              Tab(icon: Icon(Icons.contacts), text: "Contacts"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [SuggestedTab(), FacebookTab(), ContactsTab()],
        ),
      ),
    );
  }
}
