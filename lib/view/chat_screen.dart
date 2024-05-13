import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattingapp/components/widgets/message_card.dart';
import 'package:chattingapp/models/message_model.dart';
import 'package:chattingapp/models/user_model.dart';
import 'package:chattingapp/services/api.dart';
import 'package:chattingapp/utils/utils.dart';
import 'package:chattingapp/view/view_profile_screen.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser userData;
  const ChatScreen({super.key,required this.userData});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> list = [];
  //for handling msg text changes
  final _textEditingController = TextEditingController();
  //to show emoji
  bool showEmoji = false;
  bool isUploading = false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: PopScope(
        canPop: showEmoji,
        onPopInvoked: (_) async {
          if (showEmoji) {
            setState(() => showEmoji = !showEmoji);
          } else {
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 5.0,
            automaticallyImplyLeading: false,
            flexibleSpace: customAppBar(),
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                    stream: API.getAllMessages(widget.userData),
                    builder: (context, snapshot) {

                      switch(snapshot.connectionState){
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const Center(child: SizedBox(),);
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;

                          list = data!.map((e) => Message.fromJson((e.data()))).toList()??[];

                          if(list.isNotEmpty){
                            return ListView.builder(
                                reverse: true,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.only(top:10.0),
                                itemCount: list.length,
                                itemBuilder: (context,index){
                                  return MessageCard(message:list[index]);
                                });
                          }
                          else{
                            return const Text("No Message found!");
                          }
                      }
                    }
                ),
              ),
              //progress indicator for showing uploading
              if (isUploading)
                const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                        padding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                        child: CircularProgressIndicator(strokeWidth: 2))),
              chatInput(),

              if(showEmoji)
              SizedBox(
                height: size.height * .35,
                child: EmojiPicker(
                  onEmojiSelected: (Category? category, Emoji emoji) {
                    // Do something when emoji is tapped (optional)
                  },
                onBackspacePressed: () {
                // Do something when the user taps the backspace button (optional)
                // Set it to null to hide the Backspace-Button
                },
                textEditingController: _textEditingController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                  config: const Config(
                emojiViewConfig: EmojiViewConfig(
                    columns: 7,
                    emojiSizeMax: 32 * 1.0)
                ),
                    ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // app bar widget
  Widget customAppBar() {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ViewProfileScreen(user: widget.userData)));
          },
          child: StreamBuilder(
              stream: API.getUserInfo(widget.userData),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list =
                    data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                        [];

                return Row(
                  children: [
                    //back button
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.black54)),

                    //user profile picture
                    ClipRRect(
                      borderRadius: BorderRadius.circular(size.height * .03),
                      child: CachedNetworkImage(
                        width: size.height * .05,
                        height: size.height * .05,
                        fit: BoxFit.cover,
                        imageUrl:
                        list.isNotEmpty ? list[0].image : widget.userData.image,
                        errorWidget: (context, url, error) =>
                        const CircleAvatar(
                            child: Icon(CupertinoIcons.person)),
                      ),
                    ),

                    //for adding some space
                    const SizedBox(width: 10),

                    //user name & last seen time
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //user name
                        Text(list.isNotEmpty ? list[0].name : widget.userData.name,
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500)),

                        //for adding some space
                        const SizedBox(height: 2),

                        //last seen time of user
                        Text(
                            list.isNotEmpty
                                ? list[0].isOnline
                                ? 'Online'
                                : Utils.getLastActiveTime(
                                context: context,
                                lastActive: list[0].lastActive)
                                : Utils.getLastActiveTime(
                                context: context,
                                lastActive: widget.userData.lastActive),
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black54)),
                      ],
                    )
                  ],
                );
              })),
    );
  }

  Widget chatInput(){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)
              ),
              child: Row(
                children: [
                  InkWell(
                      onTap: (){
                        setState(() {
                          FocusScope.of(context).unfocus();
                          showEmoji = !showEmoji;
                        });
                      },
                      child: const Icon(Icons.emoji_emotions,color: Colors.blue,)),
                   Expanded(child: TextField(
                    controller: _textEditingController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(hintText: "Type Something",
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        border: InputBorder.none
                    ),
                  )),
                  InkWell(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final List<XFile> images = await picker.pickMultiImage(
                           imageQuality: 70);

                        for(var i in images){
                          setState(() => isUploading = true);
                          await API.sendChatImage(
                              widget.userData, File(i.path));
                          setState(() => isUploading = false);
                        }
                      },
                      child: const Icon(Icons.image,color: Colors.blueAccent,)),
                  const SizedBox(width: 5.0,),
                  InkWell(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                         setState(() => isUploading = true);

                          await API.sendChatImage(
                              widget.userData, File(image.path));
                         setState(() => isUploading = false);
                        }
                      },
                      child: const Icon(Icons.camera_alt_rounded,color: Colors.blue,)),

                ],
              ),
            ),
          ),
          MaterialButton(onPressed: (){
            if(_textEditingController.text.isNotEmpty){
              API.sendMessage(widget.userData, _textEditingController.text,Type.text);
              _textEditingController.text="";
            }
          },
              color: Colors.green,
              minWidth: 0,
              padding: const EdgeInsets.only(top: 10.0,bottom: 10.0,right: 5.0,left: 5.0),
              shape: const CircleBorder(),
              child: const Icon(Icons.send,
            color: Colors.white,size: 26,))
        ],
      ),
    );
  }
}
