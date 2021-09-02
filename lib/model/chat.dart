class Chat {
  final String message, username, type, replyText, replyName;
  final bool isMe, isGroup, isReply;
  final int time;
  final String chatStatus;

  Chat(this.message, this.time, this.type, this.username, this.replyText, this.replyName,this.isMe, this.isGroup,this.isReply,this.chatStatus);
}