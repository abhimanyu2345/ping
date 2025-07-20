import 'dart:io';
import 'package:chatapp/data/models/chat_message.dart';
import 'package:chatapp/data/models/user_data.dart';
import 'package:chatapp/data/models/webrtc_notifier.dart';
import 'package:chatapp/pages/call_Page.dart';
import 'package:chatapp/pages/home_page.dart';
import 'package:chatapp/pages/profile_page.dart';
import 'package:chatapp/state_management/riverpods.dart';
import 'package:chatapp/state_management/value_notifers.dart';
import 'package:chatapp/widgets/file_preview_stack.dart';
import 'package:chatapp/widgets/image_preview_stack.dart';
import 'package:chatapp/widgets/message_bubble_widget.dart';
import 'package:chatapp/widgets/search_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/scheduler.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({
    super.key,
    required this.chatee,
    this.chatId,
  });

  final UserProfileData chatee;
  final String? chatId;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  String? _preparedData;
  File? _preparedAudio;
  FilePickerResult? _pickedFilesResult;
  Image? _preparedImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _initialLoadComplete = false;

  void sendMessage(dynamic message, MessageType type) {
    ref.read(chatProvider.notifier).sendMessage(
          widget.chatId,
          widget.chatee.id,
          message,
          type,
        );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchFile() async {
    var result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() => _pickedFilesResult = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<ChatMessage> messages = widget.chatId != null
        ? ref.watch(chatProvider)[widget.chatId!] ?? []
        : [];

    if (!_initialLoadComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _initialLoadComplete = true;
          });
        }
      });
    }

    // New: Always scroll to bottom when messages change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return ValueListenableBuilder<Image?>(
      valueListenable: backgroundImage,
      builder: (context, bgImage, _) {
        return Stack(
          children: [
            if (bgImage != null) Positioned.fill(child: bgImage),
            Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                leading: IconButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                title: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfilePage(userData: widget.chatee),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[700],
                        child: widget.chatee.imageBytes != null
                            ? ClipOval(
                                child: Image.memory(
                                  widget.chatee.imageBytes!,
                                  fit: BoxFit.cover,
                                  width: 40,
                                  height: 40,
                                ),
                              )
                            : const Icon(Icons.person),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.chatee.tagName,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(widget.chatee.username,
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () async {
                      Map<Permission, PermissionStatus> statuses = await [
                        Permission.camera,
                        Permission.microphone,
                      ].request();
                      if (statuses[Permission.camera]!.isGranted &&
                          statuses[Permission.microphone]!.isGranted) {
                            ref.read(webRTCNotifierProvider.notifier).startCall(widget.chatId!);
                            
                            
                        Navigator.push(

                          context,
                          MaterialPageRoute(

                              builder: (context) => WebRTCCallPage(callerId: widget.chatId! ,)),
                        );
                      }
                    },
                    icon: const Icon(Icons.video_call, color: Colors.green),
                  ),
                  SearchWidget(onSearched: (query) {}),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    color: isDark ? Colors.grey[800] : Colors.white,
                    offset: const Offset(0, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (_) => [
                      const PopupMenuItem(child: Text('Clear Chat')),
                      PopupMenuItem(
                        child: const Text('Profile'),
                        onTap: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProfilePage(userData: widget.chatee),
                              ),
                            );
                          });
                        },
                      ),
                      const PopupMenuItem(child: Text('Settings')),
                      PopupMenuItem(
                        child: const Text('Change Background'),
                        onTap: () async {
                          var result = await FilePicker.platform
                              .pickFiles(type: FileType.image);
                          if (result != null) {
                            backgroundImage.value = Image.file(
                              File(result.files.single.path!),
                              fit: BoxFit.cover,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: !_initialLoadComplete
                        ? const Center(child: CircularProgressIndicator())
                        : messages.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height / 2,
                                      child: Lottie.network(
                                        'https://lottie.host/4a904127-f40c-46b1-a64e-11a2e87d7f13/KyevlkuWqi.json',
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      "Start a conversation!",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    )
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                itemCount: messages.length,
                                itemBuilder: (_, index) {
                                  return MessageBubbleWidget(
                                    message: messages[index],
                                  );
                                },
                              ),
                  ),
                ],
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Type your message...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 8.0),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                            onChanged: (value) {
                              _preparedData = value;
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.camera_alt_outlined,
                            color: Colors.blueAccent),
                        onPressed: _pickImageFromCamera,
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.mic, color: Colors.blueAccent),
                        onPressed: () {
                          // TODO: implement audio recording
                        },
                      ),
                      if (_preparedImage != null)
                        ImagePreviewStack(imageUrls: [_preparedImage!]),
                      if (_pickedFilesResult?.files.isNotEmpty == true)
                        FilePreviewStack(files: _pickedFilesResult!.files),
                      IconButton(
                        icon: const Icon(Icons.attach_file,
                            color: Colors.blueAccent),
                        onPressed: fetchFile,
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.blueAccent),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _sendMessage() {
    if (_preparedData != null && _preparedData!.trim().isNotEmpty) {
      sendMessage(_preparedData, MessageType.text);
    }

    if (_pickedFilesResult != null && _pickedFilesResult!.files.isNotEmpty) {
      for (PlatformFile file in _pickedFilesResult!.files) {
        final ext = file.extension?.toLowerCase();
        final type = ChatMessage.fileType(ext);
        sendMessage(file, type);
      }
    }

    if (_preparedAudio != null) {
      sendMessage(_preparedAudio, MessageType.audio);
    }

    if (_preparedImage != null) {
      sendMessage(_preparedImage, MessageType.image);
    }

    setState(() {
      _preparedAudio = null;
      _preparedImage = null;
      _pickedFilesResult = null;
      _preparedData = null;
      _messageController.clear();
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? imageFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (imageFile != null) {
      setState(() {
        _preparedImage = Image.file(File(imageFile.path));
      });
    }
  }
}
