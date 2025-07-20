import 'package:chatapp/state_management/riverpods.dart';
import 'package:chatapp/data/models/user_data.dart';
import 'package:chatapp/services/supabase_service.dart';
import 'package:chatapp/widgets/account_logout_widget.dart';
import 'package:chatapp/widgets/image_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({super.key});

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage> {
  // Editing flags
  bool isEditingEmail = false;
  bool isEditingPhone = false;
  bool isEditingBio = false;
  bool isEditingUsername = false;
  bool isEditingTagName = false;

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController tagNameController = TextEditingController();

  /// Save changes and refresh profile provider
  Future<void> setUserInfo(UserProfileData updatedUser) async {
    await ref.read(supabaseServiceProvider).saveUserProfile(updatedUser);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated!')),
    );
    ref.invalidate(userProfileProvider);
  }

  /// Editable text row builder
  Widget buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: onToggle,
          ),
          Expanded(
            child: isEditing
                ? TextField(
                    controller: controller,
                    decoration: InputDecoration(labelText: label),
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      "$label: ${controller.text.isEmpty ? 'N/A' : controller.text}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('No UserData Found')),
          );
        }

        // Populate controllers with current data
        emailController.text = user.email ?? '';
        phoneController.text = user.phoneNumber ?? '';
        bioController.text = user.bio ?? '';
        usernameController.text = user.username;
        tagNameController.text = user.tagName;

        return Scaffold(
          appBar: AppBar(title: const Text("My Profile")),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ImagePickerWidget(
                  image: user.imageBytes,
                  onImagePicked: (image) {
                    setUserInfo(user.copyWith(imageBytes: image));
                  },
                ),
                const SizedBox(height: 16),

                // Editable Fields
                buildEditableField(
                  label: 'Username',
                  controller: usernameController,
                  isEditing: isEditingUsername,
                  onToggle: () {
                    if (isEditingUsername) {
                      setUserInfo(user.copyWith(username: usernameController.text));
                    }
                    setState(() => isEditingUsername = !isEditingUsername);
                  },
                ),
                buildEditableField(
                  label: 'Tag Name',
                  controller: tagNameController,
                  isEditing: isEditingTagName,
                  onToggle: () {
                    if (isEditingTagName) {
                      setUserInfo(user.copyWith(tagName: tagNameController.text));
                    }
                    setState(() => isEditingTagName = !isEditingTagName);
                  },
                ),
                buildEditableField(
                  label: 'Email',
                  controller: emailController,
                  isEditing: isEditingEmail,
                  onToggle: () {
                    if (isEditingEmail) {
                      setUserInfo(user.copyWith(email: emailController.text));
                    }
                    setState(() => isEditingEmail = !isEditingEmail);
                  },
                ),
                buildEditableField(
                  label: 'Phone',
                  controller: phoneController,
                  isEditing: isEditingPhone,
                  onToggle: () {
                    if (isEditingPhone) {
                      setUserInfo(user.copyWith(phoneNumber: phoneController.text));
                    }
                    setState(() => isEditingPhone = !isEditingPhone);
                  },
                ),
                buildEditableField(
                  label: 'Bio',
                  controller: bioController,
                  isEditing: isEditingBio,
                  onToggle: () {
                    if (isEditingBio) {
                      setUserInfo(user.copyWith(bio: bioController.text));
                    }
                    setState(() => isEditingBio = !isEditingBio);
                  },
                ),
                const SizedBox(height: 16),
                Text("Joined: ${user.created.toLocal()}"),
                const SizedBox(height: 24),
                const AccountLogoutWidget(),
              ],
            ),
          ),
        );
      },
    );
  }
}
