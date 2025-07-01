// import 'package:fitnation/Screens/HomeScreen.dart';
import 'package:fitnation/main.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Placeholder for the abstract cyclist art
            // You'll need to replace this with your actual asset
            Image.asset(
              'assets/images/cyclist_art.png', // Replace with your image
              height: 300,
              errorBuilder:
                  (context, error, stackTrace) => const SizedBox(
                    height: 300,
                    child: Center(
                      child: Text(
                        'Image not found',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
            ),
            const SizedBox(height: 40),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                children: const [
                  TextSpan(text: 'ENJOY EVERY '),
                  TextSpan(
                    text: '😊\n',
                    style: TextStyle(fontSize: 24),
                  ), // Emoji size
                  TextSpan(
                    text: 'MOMENT WITH US !',
                  ), // Typo from image, corrected to MOMENT
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Join in Extremely Adventures Ridings and\nEnjoy your best experience', // Typo from image, corrected to Enjoy
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[400]),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                );
              },
              child: const Text("Let's Start"),
            ),
          ],
        ),
      ),
    );
  }
}



// class OnBoardingPage extends StatefulWidget {
//   const OnBoardingPage({super.key});

//   @override
//   OnBoardingPageState createState() => OnBoardingPageState();
// }

// class OnBoardingPageState extends State<OnBoardingPage> {
//   final introKey = GlobalKey<IntroductionScreenState>();

//   void _onIntroEnd(context) {
//     Navigator.of(
//       context,
//     ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
//   }

//   Widget _buildImage(String assetName, [double width = 350]) {
//     return Image.asset('assets/$assetName', width: width);
//   }

//   @override
//   Widget build(BuildContext context) {
//     const bodyStyle = TextStyle(fontSize: 19.0);

//     const pageDecoration = PageDecoration(
//       titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
//       bodyTextStyle: bodyStyle,
//       bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
//       pageColor: Colors.white,
//       imagePadding: EdgeInsets.zero,
//     );

//     return IntroductionScreen(
//       key: introKey,
//       globalBackgroundColor: Colors.white,
//       allowImplicitScrolling: true,
//       autoScrollDuration: 3000,
//       infiniteAutoScroll: true,
//       globalHeader: Align(
//         alignment: Alignment.topRight,
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.only(top: 16, right: 16),
//             child: _buildImage('flutter.png', 100),
//           ),
//         ),
//       ),
//       globalFooter: SizedBox(
//         width: double.infinity,
//         height: 60,
//         child: ElevatedButton(
//           child: const Text(
//             'Let\'s go right away!',
//             style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
//           ),
//           onPressed: () => _onIntroEnd(context),
//         ),
//       ),
//       pages: [
//         PageViewModel(
//           title: "Fractional shares",
//           body:
//               "Instead of having to buy an entire share, invest any amount you want.",
//           image: _buildImage('img1.jpg'),
//           decoration: pageDecoration,
//         ),
//         PageViewModel(
//           title: "Learn as you go",
//           body:
//               "Download the Stockpile app and master the market with our mini-lesson.",
//           image: _buildImage('img2.jpg'),
//           decoration: pageDecoration,
//         ),
//         PageViewModel(
//           title: "Kids and teens",
//           body:
//               "Kids and teens can track their stocks 24/7 and place trades that you approve.",
//           image: _buildImage('img3.jpg'),
//           decoration: pageDecoration,
//         ),
//         PageViewModel(
//           title: "Another title page",
//           body: "Another beautiful body text for this example onboarding",
//           image: _buildImage('img2.jpg'),
//           footer: ElevatedButton(
//             onPressed: () {
//               introKey.currentState?.animateScroll(0);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.lightBlue,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//               ),
//             ),
//             child: const Text(
//               'FooButton',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//           decoration: pageDecoration.copyWith(
//             bodyFlex: 6,
//             imageFlex: 6,
//             safeArea: 80,
//           ),
//         ),
//         PageViewModel(
//           title: "Title of last page - reversed",
//           bodyWidget: const Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text("Click on ", style: bodyStyle),
//               Icon(Icons.edit),
//               Text(" to edit a post", style: bodyStyle),
//             ],
//           ),
//           decoration: pageDecoration.copyWith(
//             bodyFlex: 2,
//             imageFlex: 4,
//             bodyAlignment: Alignment.bottomCenter,
//             imageAlignment: Alignment.topCenter,
//           ),
//           image: _buildImage('img1.jpg'),
//           reverse: true,
//         ),
//       ],
//       onDone: () => _onIntroEnd(context),
//       onSkip: () => _onIntroEnd(context), // You can override onSkip callback
//       showSkipButton: true,
//       skipOrBackFlex: 0,
//       nextFlex: 0,
//       showBackButton: false,
//       //rtl: true, // Display as right-to-left
//       back: const Icon(Icons.arrow_back),
//       skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
//       next: const Icon(Icons.arrow_forward),
//       done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
//       curve: Curves.fastLinearToSlowEaseIn,
//       controlsMargin: const EdgeInsets.all(16),
//       controlsPadding:
//           kIsWeb
//               ? const EdgeInsets.all(12.0)
//               : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
//       dotsDecorator: const DotsDecorator(
//         size: Size(10.0, 10.0),
//         color: Color(0xFFBDBDBD),
//         activeSize: Size(22.0, 10.0),
//         activeShape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.all(Radius.circular(25.0)),
//         ),
//       ),
//       dotsContainerDecorator: const ShapeDecoration(
//         color: Colors.black87,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.all(Radius.circular(8.0)),
//         ),
//       ),
//     );
//   }
// }
