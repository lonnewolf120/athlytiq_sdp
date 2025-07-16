import 'package:flutter/material.dart';
import '../../themes/text_styles.dart';

class ContactsTab extends StatelessWidget {
  const ContactsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final contacts = [
      "Akram Emtiaz",
      "Farhan Muhib",
      "Iftekhar Islam",
      "Ashrafee Jahan",
      "Rashed Kamal",
      "Mahrab Hossain",
      "Ashraf Tanvir",
      "Zareen Tasnim",
    ];

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search on Athlytiq",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(contacts[index]),
                trailing: OutlinedButton(
                  onPressed: () {},
                  child: const Text("Invite"),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: ElevatedButton(
            onPressed: () {},
            child: Text("Invite Friends", style: AppTextStyles.darkButtonText),
          ),
        ),
      ],
    );
  }
}
