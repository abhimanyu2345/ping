
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:chatapp/data/constants.dart';
import 'package:chatapp/data/personal_theme_data.dart';
import 'package:chatapp/state_management/riverpods.dart';
import 'package:chatapp/data/models/user_data.dart';
import 'package:chatapp/pages/home_page.dart';
import 'package:chatapp/widgets/image_picker_widget.dart';
import 'package:chatapp/widgets/theme_button.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';





TextEditingController usernameController = TextEditingController();
TextEditingController tagnameController = TextEditingController();
TextEditingController bioController = TextEditingController();
TextEditingController phoneController = TextEditingController();
TextEditingController statusMessageController = TextEditingController();

Uint8List? imageBytesPayload;


class UserCreationPage extends ConsumerStatefulWidget {
  const UserCreationPage({super.key});
  

  @override
  ConsumerState<UserCreationPage> createState() => _UserCreationPageState();
}

class _UserCreationPageState extends ConsumerState<UserCreationPage> {
  Status status = Status.notStarted;
  String? id;
  bool isNavigated = false;
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    fetchId();
  }

  Future<void> fetchId() async {
    final uid =ref.watch(userIdProvider);
    setState(() {
      id = uid;
      isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (status == Status.success && !isNavigated) {
      isNavigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      });
    }

    double width = MediaQuery.of(context).size.width * 0.8;

    Widget content;
    if (!isReady) {
      content = const CircularProgressIndicator();
    } else {
      switch (status) {
        case Status.notStarted:
          content = _buildForm(width);
          break;
        case Status.loading:
          content = const CircularProgressIndicator();
          break;
        case Status.failed:
          content = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Profile creation failed. Please try again."),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    status = Status.notStarted;
                  });
                },
                child: const Text("Retry"),
              ),
            ],
          );
          break;
        case Status.success:
          content = const SizedBox.shrink();
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(actions: const [ThemeButton()]),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(child: content),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ImagePickerWidget(onImagePicked: (image) {
            imageBytesPayload = image;
          }),
          const SizedBox(height: 20),
          TextField(
            controller: usernameController,
            decoration: const InputDecoration(
              hintText: 'Username *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: tagnameController,
            decoration: const InputDecoration(
              hintText: 'Tag Name *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.abc),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: bioController,
            decoration: const InputDecoration(
              hintText: 'Bio',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.info_outline),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(
              hintText: 'Phone Number *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: statusMessageController,
            decoration: const InputDecoration(
              hintText: 'Status Message',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.chat_bubble_outline),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: id == null
                ? null
                : () async {
                    final username = usernameController.text.trim();
                    final tagName = tagnameController.text.trim();
                    final phone = phoneController.text.trim();

                    if (username.isEmpty || tagName.isEmpty || phone.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Username, Tag Name, and Phone Number are required.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    setState(() => status = Status.loading);

                    final payload = UserProfileData(
                      id: id!,
                      created: DateTime.now(),
                      username: username,
                      tagName: tagName,
                      bio: bioController.text.trim(),
                      phoneNumber: phone,
                      statusMessage: statusMessageController.text.trim(),
                      imageBytes: imageBytesPayload,
                    );

                    bool response = await ref.watch(HttpServiceProvider).userRegister(payload);

                    setState(() => status = response ? Status.success : Status.failed);
                  },
            style: PersonalThemeData.btnStyle(context),
            child: SizedBox(
              width: min(width, 300),
              child: const Center(
                child: Text('Complete Creation'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
