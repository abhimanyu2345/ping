import 'package:chatapp/data/models/user_data.dart';
import 'package:chatapp/data/models/user_data_provider.dart';
import 'package:chatapp/pages/chat_page.dart';
import 'package:chatapp/state_management/riverpods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:phone_number/phone_number.dart';
import 'package:uuid/uuid.dart';

class NewChatPage extends ConsumerStatefulWidget {
  const NewChatPage({super.key});

  @override
  ConsumerState<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends ConsumerState<NewChatPage> {
  late Future<void> _contactsFuture;

  final PhoneNumberUtil _phoneUtil = PhoneNumberUtil();

  List<Contact> _allDeviceContacts = []; 

  /// Normalized phone number => Contact
  Map<String, Contact> _normalizedContactMap = {};

  /// Normalized phone number => UserProfileData
  Map<String, UserProfileData> _activeContacts = {};

  @override
  void initState() {
    super.initState();
    _contactsFuture = _fetchContacts();
  }

  /// Proper E.164 normalization
  Future<String> normalize(String rawNumber) async {
    final parsed = await _phoneUtil.parse(rawNumber, regionCode: 'IN');
    return parsed.e164;
  }

  Future<void> _fetchContacts() async {
    try {
      // 1️⃣ Get all device contacts
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      _allDeviceContacts = contacts;

      // 2️⃣ Normalize all numbers once and keep a map: normalized => Contact
      final Set<String> normalizedNumbers = {};
      final Map<String, Contact> normalizedMap = {};

      for (final contact in contacts) {
        for (final phone in contact.phones) {
          try {
            final normalized = await normalize(phone.number);
            normalizedNumbers.add(normalized);
            normalizedMap[normalized] = contact;
          } catch (e) {
            debugPrint('Failed to normalize ${phone.number}: $e');
          }
        }
      }

      // 3️⃣ Call backend to find active users by normalized numbers
      final fetched = await ref
          .read(HttpServiceProvider)
          .fetchActiveContacts(normalizedNumbers.toList());

      setState(() {
        _normalizedContactMap = normalizedMap;
        _activeContacts = fetched;
      });
    } catch (e) {
      debugPrint('Fetch contacts error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    
    final existingChats = ref.watch(userDataProvider.notifier).userContactMap;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Chat'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _contactsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_normalizedContactMap.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.network(
                      'https://lottie.host/7e14db79-80e3-4356-a7e9-bd029d244bdd/Ok0rZUNgrK.json',
                      height: 200,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No Contacts Found',
                      style: GoogleFonts.oregano(fontSize: 35),
                    ),
                  ],
                ),
              );
            }
             List<MapEntry<String,Contact>> filteredActive=[];
             List<MapEntry<String,Contact>> filteredNonActive=[];

            // ✅ Filter active + not in existing chats

            for( var entry in _normalizedContactMap.entries){
               final normalized = entry.key;
              final isExisting = existingChats.contains(normalized);
              final isActive = _activeContacts.containsKey(normalized);
              if(!isActive){
                filteredNonActive.add(entry);

              }
              else if(isExisting){
                filteredActive.add(entry);
              }

            }

           

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (filteredActive.isNotEmpty) ...[
                      const Text(
                        'Active Contacts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: filteredActive.length,
                        itemBuilder: (context, index) {
                          final entry = filteredActive[index];
                          final normalized = entry.key;
                          final profile = _activeContacts[normalized]!;
                          return newChatWidget(profile);
                        },
                      ),
                    ],
                    if (filteredNonActive.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Invite to App',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisExtent: 200,
                        ),
                        itemCount: filteredNonActive.length,
                        itemBuilder: (context, index) {
                          final entry = filteredNonActive[index];
                          final contact = entry.value;
                          return inviteToAppWidget(contact);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget newChatWidget(UserProfileData profile) {
    return Container(
      child: Column(
        children: [
          if (profile.imageBytes != null)
            CircleAvatar(
              radius: 30,
              backgroundImage: MemoryImage(profile.imageBytes!),
            )
          else
            const CircleAvatar(
              radius: 30,
              child: Icon(Icons.person),
            ),
          const SizedBox(height: 8),
          Text(profile.phoneNumber!),
          Text(profile.username, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(profile.tagName),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
                
                return ChatPage(chatee: profile, chatId: Uuid().v4(),);
              },), (route) => false,);
              
            },
            child: const Text('Start Chat'),
          ),
        ],
      ),
    );
  }

  Widget inviteToAppWidget(Contact contact) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (contact.photoFetched && contact.photo != null)
            CircleAvatar(
              radius: 30,
              backgroundImage: MemoryImage(contact.photo!),
            )
          else
            const CircleAvatar(
              radius: 30,
              child: Icon(Icons.person),
            ),
          const SizedBox(height: 8),
          Text(contact.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(contact.phones[0].normalizedNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              
            },
            child: const Text('Invite'),
          ),
        ],
      ),
    );
  }
}
