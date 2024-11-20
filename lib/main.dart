import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:practice_first_flutter_project/login/login.dart';
import 'package:practice_first_flutter_project/puzzle/puzzle.dart';
import 'NotificationController.dart';
import 'bingo_main.dart';
import 'combination_words.dart';
import 'widgets/app_above_bar.dart';
import 'widgets/bottom_navigation_bar.dart';
import 'hiddenword/hiddenword_open.dart';
import 'package:http/http.dart' as http;

// Global 상태를 관리하는 Provider
class GlobalProvider extends GetxController {
  RxInt memberId = 0.obs;

  void setMemberId(int memberId) {
    this.memberId.value = memberId;
  }

  int getMemberId() {
    return memberId.value;
  }
}

void main() {
  Get.put(GlobalProvider()); // GlobalProvider 등록
  // if (!Get.isRegistered<NotificationController>()) {
  //    Get.put(NotificationController()); // NotificationController 등록
  // }

  print('NotificationController registered');
  runApp(const YesterPayApp());
}

class YesterPayApp extends StatelessWidget {
  const YesterPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(), // 앱 시작 화면
    );
  }
}

class YesterPayMainContent extends StatefulWidget {
  const YesterPayMainContent({super.key});

  @override
  _YesterPayMainContentState createState() => _YesterPayMainContentState();
}

class _YesterPayMainContentState extends State<YesterPayMainContent> {
  final PageController _pageController = PageController();
  int _currentPage = 2;
  String requiredBingoCount = '로딩 중...';
  List<String> letters = [];

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController());
    }
    // 페이지 자동 전환 타이머 설정
    Future.delayed(Duration.zero, () {
      Timer.periodic(const Duration(seconds: 3), (Timer timer) {
        if (_pageController.hasClients) {
          _currentPage = (_currentPage + 1) % 5;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        }
      });
    });

    fetchLetters();
    fetchRequiredBingoCount();
  }

  Future<void> fetchLetters() async {
    try {
      final response = await http.get(Uri.parse('http://3.34.102.55:8080/member/1/letter'));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody) as List;
        setState(() {
          letters = data.map((item) => item.toString()).toList();
        });
      } else {
        print('Error: ${response.statusCode}, Body: ${response.body}');
        setState(() {
          letters = [];
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        letters = [];
      });
    }
  }

  Future<void> fetchRequiredBingoCount() async {
    try {
      final response = await http.get(Uri.parse('http://3.34.102.55:8080/bingo/status?memberId=1'));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody);
        setState(() {
          requiredBingoCount = data['requiredBingoCount']?.toString() ?? '0';
        });
      } else {
        print('Error: ${response.statusCode}, Body: ${response.body}');
        setState(() {
          requiredBingoCount = '0';
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        requiredBingoCount = '0';
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalProvider pro = Get.find<GlobalProvider>();
    return Scaffold(
      appBar: CustomAppBar(), // Custom AppBar 사용
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상단 배너
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/up_home_yeseterpay.png',
                      fit: BoxFit.fitHeight,
                      width: double.infinity,
                      height: 180,
                    ),
                  ),
                  Positioned(
                    bottom: -6,
                    left: 14,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HiddenWordOpenPage(hiddenWord: '차'),
                          ),
                        );
                      },
                      child: const Text(
                        '글자 확인하러 가기  ➔',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 빙고 섹션
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD9D9D9), width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: Image.asset(
                    'assets/icons/free-icon-bingo-home.png',
                    width: 24,
                    height: 24,
                  ),
                  title: Row(
                    children: [
                      const Text('PAYGO! BINGO!',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          '$requiredBingoCount빙고/3빙고',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  subtitle: const Text('빙고 완성하러 가기'),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => BingoMain()),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFD9D9D9), width: 1), // 테두리
                  borderRadius: BorderRadius.circular(10), // 모서리 둥글게 처리
                ),
                child: ListTile(
                  leading: Image.asset(
                    'assets/icons/free-icon-crossword-home.png',
                    width: 24,
                    height: 24,
                  ),
                  title: Row(
                    children: const [
                      Text('십자말 풀이',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Spacer(),
                      Text('완성률 : 55%', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  subtitle: Text('십자말 완성하러 가기'),
                  trailing: Padding(
                    padding: EdgeInsets.only(right: 0.0), // 아이콘 오른쪽으로 이동
                    child: IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        // CrosswordPage 페이지로 이동
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CrosswordPage()),
                        );
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),

              // 내 단어 섹션
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD9D9D9)),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '내 단어',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CombinationWordsPage()),
                            );
                          },
                          child: const Text('조합하기 >'),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: letters.isEmpty
                          ? [const Text('보유한 단어가 없습니다.')]
                          : letters.map((word) {
                        return Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            word,
                            style: const TextStyle(fontSize: 18),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 캐러셀 섹션
              SizedBox(
                height: 310,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: 5,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Image.asset(
                        'assets/images/season_ad_${index + 1}.png',
                        fit: BoxFit.fitHeight,
                        width: double.infinity,
                        height: 300,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 2),
    );
  }
}
