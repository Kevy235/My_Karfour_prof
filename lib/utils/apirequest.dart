class Apirequest{
  static final  apiHost = 'https://mykarfour.com/api/';
  static final uploadHost = 'https://mykarfour.com/';

  static final login = Apirequest.apiHost+'m/login';
  static final register = Apirequest.apiHost+'m/register';
  static final check_phone = Apirequest.apiHost+'m/verify-phone-code';
  static final complete_profile = Apirequest.apiHost+'m/after-register';
  static final change_class = Apirequest.class_url+'changed';
  static final subscription = Apirequest.apiHost+'subscription';
  static final pay = Apirequest.subscription+'/payment';
  static final class_url = Apirequest.apiHost+'class/';
  static final subjects = Apirequest.apiHost+'subject/';
  static final subjects_url = Apirequest.apiHost+'subjects/';
  static final update_password = Apirequest.apiHost+'user/update/password';
  static final chapter = Apirequest.apiHost+'chapter/';
  static final update_profil = Apirequest.apiHost+'user/update/profil';
  static final profil = Apirequest.apiHost+'user/profil';
  static final update_profil_image = Apirequest.apiHost+'user/update/picture';
  static final posts = Apirequest.apiHost+'api/posts';
  static final save_media = Apirequest.apiHost+'chat/media';
  static final post = Apirequest.apiHost+'api/post';
  static final chats = Apirequest.apiHost+'api/chats';
  static final chat = Apirequest.apiHost+'api/chat';
  static final user = Apirequest.apiHost+'api/user';
  static final message = Apirequest.apiHost+'api/message';
  static final contacts = Apirequest.apiHost+'api/contacts';
  static final bookmarks = Apirequest.apiHost+'api/bookmarks';
  static final lists = Apirequest.apiHost+'api/lists';
  static final list = Apirequest.apiHost+'api/list';
  static final add_card = Apirequest.apiHost+'api/card/add';
  static final list_card = Apirequest.apiHost+'api/card/list';
}

