
class ReplaceText {
  final String oldText;
  final String newText;

  ReplaceText(this.oldText, this.newText);

  factory ReplaceText.fromJson(Map<String, dynamic> json){
    return new ReplaceText(json['oldText'], json['newText'],);
  }

  Map<String, dynamic> toJson() {
    return {'oldText': oldText, 'newText': newText};
  }
}