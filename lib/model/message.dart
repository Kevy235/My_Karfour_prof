class Message {
  final String avatar;
  final String name;
  final String username;
  final int interlocutorId;
  final String lastMessage;
  final int time;
  final int unreadMessages;

  Message(this.avatar, this.name, this.interlocutorId, this.username,this.lastMessage, this.time, this.unreadMessages);
}