import 'package:chatapp/data/models/user_data.dart';
import 'package:flutter/material.dart';

class IncomingCallPanelWidget extends StatelessWidget {
  final UserProfileData profile;
  const IncomingCallPanelWidget({required this.profile,super.key});


  @override

  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        
        padding: const EdgeInsets.all(16),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(16),
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: profile.imageBytes != null
                      ? MemoryImage(profile.imageBytes!)
                      : null,
                  child: profile.imageBytes == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  profile.tagName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Incoming call',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Accept call logic here
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.call),
                        label: const Text('Accept'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Reject call logic here
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.call_end),
                        label: const Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  }
