import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TaskIcons {
  static const List<IconData> icons = [
    FontAwesomeIcons.list,
    FontAwesomeIcons.listCheck,
    FontAwesomeIcons.clipboard,
    FontAwesomeIcons.calendar,
    FontAwesomeIcons.clock,
    FontAwesomeIcons.star,
    FontAwesomeIcons.heart,
    FontAwesomeIcons.house,
    FontAwesomeIcons.briefcase,
    FontAwesomeIcons.graduationCap,
    FontAwesomeIcons.book,
    FontAwesomeIcons.code,
    FontAwesomeIcons.gamepad,
    FontAwesomeIcons.music,
    FontAwesomeIcons.palette,
    FontAwesomeIcons.dumbbell,
    FontAwesomeIcons.plane,
    FontAwesomeIcons.cartShopping,
    FontAwesomeIcons.moneyBill,
    FontAwesomeIcons.user,
    FontAwesomeIcons.circleCheck,
    // Add more icons here as needed, they will automatically be supported
    FontAwesomeIcons.boxArchive,
    FontAwesomeIcons.fire,
    FontAwesomeIcons.trophy,
    FontAwesomeIcons.mapLocationDot,
    FontAwesomeIcons.suitcaseRolling,
    FontAwesomeIcons.camera,
  ];

  static IconData? getIconByCodePoint(int? codePoint) {
    if (codePoint == null) return null;
    try {
      return icons.firstWhere((icon) => icon.codePoint == codePoint);
    } catch (_) {
      // Fallback if the codePoint exists but isn't in our curated list
      // Return a default icon to avoid non-constant IconData invocation (breaks tree-shaking)
      return FontAwesomeIcons.circleQuestion;
    }
  }
}
