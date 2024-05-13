import 'package:chattingapp/models/message_model.dart';
import 'package:chattingapp/models/user_model.dart';
import 'package:chattingapp/services/api.dart';
import 'package:chattingapp/utils/utils.dart';
import 'package:chattingapp/view/chat_screen.dart';
import 'package:chattingapp/view/view_profile_screen.dart';
import 'package:flutter/material.dart';

class UserCard extends StatefulWidget {
  final ChatUser userData;
  const UserCard({super.key,required this.userData});

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  Message? message;

  @override
  Widget build(BuildContext context) {
    Size size =MediaQuery.of(context).size;
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatScreen(userData: widget.userData)));
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: size.width * .04,vertical: 4.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 1,
        child: StreamBuilder(
          stream: API.getLastMessages(widget.userData),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list = data?.map((e) => Message.fromJson(e.data())).toList()??[];

            if(list.isNotEmpty){
              message=list[0];
            }
            return ListTile(
              // leading: CachedNetworkImage(
              // width: size.width * .055,
              // height: size.height * .055,
              //   imageUrl: widget.userData.image,
              //   placeholder: (context, url) => const CircularProgressIndicator(),
              //   errorWidget: (context, url, error) => const CircleAvatar(child: Icon(Icons.person),),
              // ),
              leading: InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewProfileScreen(user:widget.userData)));
                  },
                  child: Image.network(widget.userData.image)),
              title: Text(widget.userData.name),
              subtitle: Text(message!=null?
              message!.type==Type.image?'image':
              message!.msg:widget.userData.about,maxLines: 1,),
              trailing:
              message==null?null:
                  message!.read.isEmpty && message!.fromId!=API.user.uid?
              Container(
                width: 15,height: 15,
                decoration: BoxDecoration(
                  color: Colors.greenAccent.shade400,
                  borderRadius: BorderRadius.circular(10.0)
                ),
              ): Text(Utils.getLastMessageTime(context:context,time:message!.sent),style: const TextStyle(color: Colors.black54),),
            );
          }
        ),
      ),
    );
  }
}
