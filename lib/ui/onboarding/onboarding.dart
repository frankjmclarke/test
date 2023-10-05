import 'package:flutter/material.dart';
import 'package:introduction_slider/source/presentation/pages/introduction_slider.dart';
import 'package:introduction_slider/source/presentation/widgets/buttons.dart';
import 'package:introduction_slider/source/presentation/widgets/dot_indicator.dart';
import 'package:introduction_slider/source/presentation/widgets/introduction_slider_item.dart';
import '../home_ui.dart';

class OnboardingUI extends StatelessWidget {
  const OnboardingUI({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroductionSlider(
      items: [
        IntroductionSliderItem(
          logo: Image.asset('assets/images/share.png'),
          title: Text(
            "Share your shopping links to Shopping Lister",
            style: TextStyle(
                fontSize: 28,
                // height: 2, //line height 200%, 1= 100%, were 0.9 = 90% of actual line height
                color: Colors.black87,
                //font color
                //backgroundColor: Colors.black12, //background color
                letterSpacing: 1,
                //letter spacing
                //decoration: TextDecoration.underline, //make underline
                decorationStyle: TextDecorationStyle.double,
                //double underline
                decorationColor: Colors.brown,
                //text decoration 'underline' color
                //decorationThickness: 1.5, //decoration 'underline' thickness
                fontStyle: FontStyle.normal),
          ),
          backgroundColor: Colors.black12,
        ),
        IntroductionSliderItem(
          logo: Image.asset('assets/images/clipart865414.png'),
          title: Text(
            "AI generates new suggestions",
            style: TextStyle(
              fontSize: 28,
              color: Colors.black87,
            ),
          ),
          backgroundColor: Colors.black12,
        ),
        IntroductionSliderItem(
          logo: Image.asset('assets/images/shop.png'),
          title: Text(
            "Pick the ones you like and get new suggestions",
            style: TextStyle(
              fontSize: 28,
              color: Colors.black87,
            ),
          ),
          backgroundColor: Colors.black12,
        ),
      ],
      done: Done(
        child: Icon(Icons.done),
        home: HomeUI(),
      ),
      next: Next(child: Icon(Icons.arrow_forward)),
      back: Back(child: Icon(Icons.arrow_back)),
      dotIndicator: DotIndicator(),
    );
  }
}
