import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../screens/engineer_screens/chatscreen.dart';
import 'individualchatscreen.dart';

class ChatInfoTile extends StatefulWidget {
  const ChatInfoTile({
    super.key,
    required this.cUserID,
    required this.otherUser,
    required this.onTap,
  });

  final String cUserID;
  final ChatUser otherUser;
  final Function()? onTap;

  @override
  State<ChatInfoTile> createState() => _ChatInfoTileState();
}

class _ChatInfoTileState extends State<ChatInfoTile> {
  @override
  Widget build(BuildContext context) {
    var newChatRoom = widget.cUserID.compareTo(widget.otherUser.id) > 0
        ? '${widget.cUserID}_${widget.otherUser.id}'
        : '${widget.otherUser.id}_${widget.cUserID}';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(newChatRoom)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          var lastMessageData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          var lastMessageText = lastMessageData['text'] ?? 'No message';
          DateTime? messageTime;
          String amPm = '';

          if (lastMessageData['timestamp'] != null) {
            messageTime = (lastMessageData['timestamp'] as Timestamp).toDate();
            amPm = DateFormat('a').format(messageTime);
          }

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IndividualChatScreen(
                    chatRoomId: newChatRoom,
                    user: widget.otherUser,
                    selectedUser: widget.otherUser,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 10,
                child: ListTile(
                  tileColor: Colors.white,
                  leading: CircleAvatar(
                    radius: 30,
                    child: Image.asset('assets/images/Ellipse.png'),
                  ),
                  title: Text(
                    widget.otherUser.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        lastMessageText.length<20?lastMessageText:
                        '${lastMessageText.substring(0, 20)}..',
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (messageTime != null) // Only display time if not null
                        Text(
                          '${DateFormat('h:mm').format(messageTime)} $amPm',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
