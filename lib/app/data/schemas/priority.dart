// enum TodoPriority {
//   highLevel,
//   mediumLevel,
//   lowLevel,
// }

// 因为在Dart中，枚举并不直接支持包含非英文的其他字符，因为枚举的每个值都是常量，
// 且必须满足Dart的标识符规则，不允许使用中文字符。
// 但是可以使用一个类来达到类似的效果，例如

class TodoPriority {
  final String value;
  const TodoPriority._internal(this.value);

  static const TodoPriority highLevel = TodoPriority._internal('highLevel');
  static const TodoPriority mediumLevel = TodoPriority._internal('mediumLevel');
  static const TodoPriority lowLevel = TodoPriority._internal('lowLevel');

  static TodoPriority fromString(String str) {
    switch (str) {
      case 'highLevel':
        return highLevel;
      case 'mediumLevel':
        return mediumLevel;
      case 'lowLevel':
        return lowLevel;
      default:
        throw Exception('Invalid TodoPriority value: $str');
    }
  }

  @override
  String toString() {
    return value;
  }
}
