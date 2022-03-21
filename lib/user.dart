class Users_Isspeak {
  int uid;
  bool isSpeaking;


  Users_Isspeak(this.uid, this.isSpeaking);

  @override
  String toString() {
    return 'User{uid: $uid, isSpeaking: $isSpeaking}';
  }
}