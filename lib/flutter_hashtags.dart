import 'dart:ui';

import 'package:flutter/painting.dart';

class FlutterHashtag {
   FlutterHashtag(
      this.hashtag,
      this.color,
      this.size,
      this.rotated,
      );
   String hashtag='';
   Color color= Color.fromARGB(33, 33, 33, 33);
   int size=1;
   bool rotated=false;
}

class FlutterColors {
  const FlutterColors._();

  static const Color yellowShade = Color(0xFFFFC108);
  static const Color yellow = Color(0xFfffeb3b);

  static const Color white = Color(0xFFFFFFFF);

  static const Color blue400 = Color(0xFF13B9FD);
  static const Color blue600 = Color(0xFF0175C2);
  static const Color blue = Color(0xFF02569B);
  static const Color red = Color(0xfFF44336);

  static const Color gray100 = Color(0xFFD5D7DA);
  static const Color gray600 = Color(0xFF60646B);
  static const Color gray = Color(0xFF202124);

  static const Color green = Color(0xF44caF50);



  static const Color deepOrange = Color(0xFFFF5722);
  static const Color orange = Color(0xFFFF9800);
}

 List<FlutterHashtag> kFlutterHashtags =  <FlutterHashtag>[
  FlutterHashtag('FlutterTastic', FlutterColors.yellow, 50, false),
  FlutterHashtag('FlutterSpiration', FlutterColors.red, 34, false),
  FlutterHashtag('FlutterSpirit', FlutterColors.blue600, 29, true),
  FlutterHashtag('FlutterHashtagging', FlutterColors.gray, 34, false),
  FlutterHashtag('FlutterHashtagChallenge', FlutterColors.blue400, 26, false),
  FlutterHashtag('FlutterHashtagOfTheDay', FlutterColors.yellow, 24, true),
FlutterHashtag('FlutterCover', FlutterColors.gray600, 30, true),
  FlutterHashtag('FlutterDream', FlutterColors.blue, 36, false),
  FlutterHashtag('FlutterAddict', FlutterColors.blue400, 40, false),
   /*  FlutterHashtag('FlutterDevOps', FlutterColors.gray, 32, true),
  FlutterHashtag('Fluttermidable', FlutterColors.green, 29, false),
  FlutterHashtag('FlutterPackage', FlutterColors.gray600, 24, false),
  FlutterHashtag('FlutterUpgradeDay', FlutterColors.blue600, 26, false),
  FlutterHashtag('FlutterFunCoding', FlutterColors.blue600, 30, true),
  FlutterHashtag('FlutterGuestStars', FlutterColors.blue, 29, false),
  FlutterHashtag('FlutterMagician', FlutterColors.gray, 30, false),
  FlutterHashtag('FlutterHotReload', FlutterColors.yellow, 44, false),
  FlutterHashtag('FlutterMagicTrick', FlutterColors.blue400, 30, true),
  FlutterHashtag('FlutterWeekEnd', FlutterColors.gray, 29, true),
 FlutterHashtag('FlutterArtist', FlutterColors.blue600, 33, false),
  FlutterHashtag('FlutterDevelopers', FlutterColors.gray600, 32, false),
  FlutterHashtag('FlutterGuestStar', FlutterColors.blue600, 34, false),
  FlutterHashtag('FlutterBestDayOfTheWeek', FlutterColors.deepOrange, 32, true),
  FlutterHashtag('FlutterIsMyBFF', FlutterColors.orange, 33, false),
FlutterHashtag('FlutterIsComing', FlutterColors.yellow, 44, false),
  FlutterHashtag('FlutterMakers', FlutterColors.blue, 32, true),
  FlutterHashtag('FlutterLiveInvite', FlutterColors.blue, 40, false),
  FlutterHashtag('FlutterPower', FlutterColors.blue400, 32, false),
  FlutterHashtag('FlutterCat', FlutterColors.blue, 30, true),
  FlutterHashtag('FlutterExcellent', FlutterColors.gray, 24, true),
  FlutterHashtag('FlutterIsAwesome', FlutterColors.blue, 26, false),
  FlutterHashtag('FlutterExcited', FlutterColors.blue600, 28, false),
  FlutterHashtag('FlutterReady', FlutterColors.gray, 36, true),
  FlutterHashtag('FlutterRennes', FlutterColors.blue, 36, false),
  FlutterHashtag('FlutterLiveRegistration', FlutterColors.blue400, 40, false),
  FlutterHashtag('FlutterLiveTicket', FlutterColors.blue, 36, false),
  FlutterHashtag('FlutterDreamComeTrue', FlutterColors.blue400, 30, false),
  FlutterHashtag('SeeYouLiveAtFlutterLive', FlutterColors.blue, 29, false),
  FlutterHashtag('GoodFlutterNews', FlutterColors.blue, 24, false),
  FlutterHashtag('FlutterIsSoGreat', FlutterColors.blue, 40, false),
  FlutterHashtag('FlutterUsers', FlutterColors.blue, 30, false),
  FlutterHashtag('FlutterSpeakers', FlutterColors.blue, 29, true),
  FlutterHashtag('FlutterSwag', FlutterColors.blue, 34, false),
  FlutterHashtag('Flutter40K', FlutterColors.yellow, 40, false),*/
];