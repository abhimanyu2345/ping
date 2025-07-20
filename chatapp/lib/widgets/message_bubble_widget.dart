import 'dart:io';
import 'package:chatapp/state_management/riverpods.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/data/models/chat_message.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:http/http.dart' as http;

class MessageBubbleWidget extends ConsumerStatefulWidget {
  const MessageBubbleWidget({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  ConsumerState<MessageBubbleWidget> createState() =>
      _MessageBubbleWidgetState();
}

class _MessageBubbleWidgetState extends ConsumerState<MessageBubbleWidget> {
  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.75;
    final maxHeight = MediaQuery.of(context).size.height * 0.9;
    final isSentByMe = widget.message.from == ref.watch(userIdProvider);
    final timeString = widget.message.time.toIso8601String();

    Widget messageWidget;

    if (widget.message.type == MessageType.text) {
      messageWidget = Text(
        widget.message.message,
        style: TextStyle(
          color: isSentByMe ? Colors.white : Colors.black,
          fontSize: 16,
        ),
      );
    } else if (widget.message.type == MessageType.image) {
      messageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.grey[500],
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Image.network(
            widget.message.message,
            height: 30,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image),
          ),
        ),
      );
    } else if (widget.message.type == MessageType.pdf) {
      messageWidget = SizedBox(
        height: 300,
        child: Stack(
          children: [
            SfPdfViewer.network(widget.message.message,  canShowScrollHead: true,
  canShowScrollStatus: true,),
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onLongPress: () => downloadAndPreview(widget.message),
                child: Container(),
              ),
            ),
          ],
        ),
      );
    } else if (widget.message.type == MessageType.file) {
      messageWidget = Container(
        decoration: BoxDecoration(
          color: Colors.grey[500],
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.insert_drive_file, color: Colors.white, size: 48),
            const SizedBox(height: 4),
            Text(
              widget.message.message.split('/').last,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      );
    } else {
      messageWidget = const SizedBox();
    }

    return VisibilityDetector(
      key: Key(
          'msg-${widget.message.chatId}-${widget.message.time.toIso8601String()}'),
      onVisibilityChanged: (info) {
        if (!widget.message.marked &&
            !isSentByMe &&
            info.visibleFraction >= 0.75) {
          Future.microtask(() {
            if (!mounted) return;
            ref.read(chatProvider.notifier).setSeen(
                widget.message.toJson(), false);
          });
        }
      },
      child: Align(
        alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: maxHeight,
          ),
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: isSentByMe ? Colors.blueAccent : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: isSentByMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    messageWidget,
                    const SizedBox(height: 4),
                    Text(
                      timeString,
                      style: TextStyle(
                        color: isSentByMe ? Colors.white70 : Colors.black54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSentByMe)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "👀",
                        style: TextStyle(
                          fontSize: 16,
                          color: widget.message.marked
                              ? Colors.greenAccent
                              : Colors.transparent,
                        ),
                      ),
                      Icon(
                        Icons.done,
                        size: 16,
                        color: widget.message.marked
                            ? const Color.fromARGB(255, 175, 255, 84)
                            : Colors.transparent,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> downloadAndPreview(ChatMessage msg) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.get(Uri.parse(msg.message));
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/temp.pdf');
      await file.writeAsBytes(response.bodyBytes);

      if (!mounted) return;

      Navigator.of(context).pop();

      
showModalBottomSheet(
  context: context,
  backgroundColor: Colors.transparent, // Outer background
  barrierColor: Colors.transparent, // Dim behind
  isScrollControlled: true,
  builder: (_) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.65,
    minChildSize: 0.64,
    maxChildSize: 0.75,
    builder: (_, controller) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black, // Black background INSIDE
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          child: PDFView(
            filePath: file.path,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: true,
            pageFling: true,
          ),
        ),
      );
    },
  ),
);

    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download PDF: $e')),
      );
    }
  }
}
