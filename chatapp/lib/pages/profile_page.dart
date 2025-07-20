import 'package:chatapp/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/data/models/user_data.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.userData});
  final UserProfileData userData;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  
  
  

  @override
  Widget build(BuildContext context) {
    final user =widget.userData;
    return Scaffold(

      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body:
          

          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user.imageBytes != null
                            ? MemoryImage(user.imageBytes!)
                            : null,
                        child: user.imageBytes == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(user.username,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(user.tagName,
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      if (user.statusMessage != null)
                        Text(user.statusMessage!,
                            style:
                                const TextStyle(fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Basic Info
                Text("Email: ${user.email ?? 'N/A'}"),
                Text("Phone: ${user.phoneNumber ?? 'N/A'}"),
                Text("Bio: ${user.bio ?? 'N/A'}"),
                Text("Last seen: ${user.lastSeen?.toLocal().toString() ?? 'N/A'}"),
                Text("Joined: ${user.created.toLocal().toString()}"),
                Text("Online: ${user.isOnline ? 'Yes' : 'No'}"),

                const SizedBox(height: 24),

                // Contacts
                const Text("Contacts:",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                ...?user.contacts?.map((c) => Column(
                      children: [
                        userBarWidget(c),
                        const Divider(),
                      ],
                    )),

                const SizedBox(height: 24),

                // Blocked Users
                const Text("Blocked Users:",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                ...?user.blockedUsers?.map((b) => Column(
                      children: [
                        userBarWidget(b),
                        const Divider(),
                      ],
                    )),
              ],
            )));
  }

Widget userBarWidget(String id) {
  
UserData data =UserData(id: 'id',tagName: 'tag',username: 'usr');


 return InkWell(
      onTap: () {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
          
          return ChatPage(
          
           chatee: UserProfileData(id: 'id', username: 'username', tagName: 'tagName', created: DateTime.now()),
          );
        },),(route) => false,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage:
                  data.imageBytes != null ? MemoryImage(data.imageBytes!) : null,
              child: data.imageBytes == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.username,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(data.tagName,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
