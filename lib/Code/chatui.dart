
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// Fetch ticket details API
Future<Map<String, dynamic>> fetchTicketDetails(String ticketRef) async {
  final response = await Dio().post(
    'https://holidayscarparking.uk/api/getSupportTicketsView',
    data: json.encode({'ticket_ref': ticketRef}),
    options: Options(headers: {'Content-Type': 'application/json'}),
  );

  if (response.statusCode == 200) {
    return response.data;
  } else {
    throw Exception('Failed to load ticket details');
  }
}

/// Send reply with or without an image
Future<void> postReply(String ticketRef, String message, File? imageFile) async {
  try {
    FormData formData = FormData.fromMap({
      'ticket_ref': ticketRef,
      'message': message,
      'attachment': imageFile,
      // if (imageFile != null)
      //   'attachment': await MultipartFile.fromFile(imageFile.path),
    });

    Response response = await Dio().post(
      'https://holidayscarparking.uk/api/submitTicketReply',
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );


    if (response.statusCode != 200) {
      print(imageFile);
      throw Exception("Failed to send reply: ${response.data}");
    }
  } catch (e) {
    print("Error: $e");
    throw Exception("Error sending reply: $e");
  }
}

/// Ticket Details Page
class TicketDetailsPage extends StatefulWidget {
  final String ticketRef;
  const TicketDetailsPage({super.key, required this.ticketRef});

  @override
  _TicketDetailsPageState createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {
  late Future<Map<String, dynamic>> ticketData;
  final TextEditingController _messageController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    ticketData = fetchTicketDetails(widget.ticketRef);
  }

  /// Pick Image from Gallery
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// Send Reply
  Future<void> _sendReply() async {
    if (_messageController.text.isEmpty && _selectedImage == null) return;
    await postReply(widget.ticketRef, _messageController.text, _selectedImage);

    setState(() {
      ticketData = fetchTicketDetails(widget.ticketRef);
      _messageController.clear();
      _selectedImage = null;
    });
  }
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
          title: const Text('Ticket Details')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: ticketData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CupertinoActivityIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final data = snapshot.data!;
                  final progress = data['data']['progress'];
                  final messages = progress.entries.toList().reversed.toList();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  });
                  return ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    children: messages.map<Widget>((entry) {
                      final messageData = entry.value;
                      final isClient = messageData['reply_by'] == 'Client';
                      return Column(
                        crossAxisAlignment:
                        isClient ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          _buildChatBubble(
                            content: messageData['message'],
                            isSender: isClient,
                          ),
                          Text(
                            'Time: ${messageData['replyingtime']}',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          if (messageData['attachment'] != null &&
                              messageData['attachment'].isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Image.network(
                                'https://holidayscarparking.uk/${messageData['attachment']}',
                                height: 200,
                              ),
                            ),
                          const SizedBox(height: 10),
                        ],
                      );
                    }).toList(),
                  );
                } else {
                  return const Center(child: Text('No Data Available'));
                }
              },
            ),
          ),
          _buildReplyInput(),
        ],
      ),
    );
  }

  /// Chat Bubble UI
  Widget _buildChatBubble({required String content, required bool isSender}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child:  Align(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: isSender ? Theme.of(context).primaryColor : Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),

    );
  }


  //
  // setState(() {
  // _selectedImage = null; // Clear image after sending
  // });

  Widget _buildReplyInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          if (_selectedImage != null)
            Stack(
              alignment: Alignment.topRight,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _selectedImage!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.cancel, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                ),
              ],
            ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.image),
                onPressed: _pickImage,
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                  ),
                ),
              ),
              IconButton(
                icon: Icon(MingCute.send_fill, color: Theme.of(context).primaryColor),
                onPressed: _sendReply,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
