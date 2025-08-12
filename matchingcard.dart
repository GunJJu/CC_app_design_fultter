import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(home: CardSwipePage(), debugShowCheckedModeBanner: false),
  );
}

class CardSwipePage extends StatefulWidget {
  const CardSwipePage({super.key});
  @override
  State<CardSwipePage> createState() => _CardSwipePageState();
}

// 1. 애니메이션을 위한 SingleTickerProviderStateMixin 추가
class _CardSwipePageState extends State<CardSwipePage>
    with SingleTickerProviderStateMixin {
  // 2. showHeartCenter를 제거하고 애니메이션 관련 변수 추가
  bool expanded = false;
  bool showEnd = false;

  late final AnimationController _animationController;
  Animation<Alignment>? _alignmentAnimation;
  Animation<double>? _sizeAnimation;
  bool _isAnimating = false;

  final Set<int> likedIndexes = {};
  final Set<int> hiddenIndexes = {};

  final List<Map<String, dynamic>> cards = [
    {
      'name': '벤',
      'age': '22',
      'major': '기계공학',
      'img':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=800&auto=format&fit=crop',
      'desc_short': '음주: 가끔/사회적 흡연: 비흡연',
      'desc_long':
          '음주: 가끔/사회적 흡연: 비흡연\nMBTI: INTP | 종교: 없음\n[본인소개]\n기술과 트렌드에 관심 많고, 주말엔 보드게임, 영화, 공모전도 좋아함.\n#AI #IoT #디자인씽킹 #보드게임',
    },
    {
      'name': '지아',
      'age': '21',
      'major': '시각디자인',
      'img':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=800&auto=format&fit=crop',
      'desc_short': '카페투어 & 필름카메라 좋아함',
      'desc_long': '필름카메라로 사진 찍고 감성 글귀 쓰는 걸 좋아함! 디자인, 전시, 감성글귀 좋아하는 분 환영!',
    },
    {
      'name': '준서',
      'age': '24',
      'major': '컴퓨터공학',
      'img':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=800&auto=format&fit=crop',
      'desc_short': '알고리즘 스터디 환영! 커피챗 O',
      'desc_long': '알고리즘 스터디, 커피챗/진로/IT트렌드 이야기, 토론, 사이드 프로젝트/캡스톤 환영!',
    },
    {
      'name': '가은',
      'age': '23',
      'major': '경영학',
      'img':
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=800&auto=format&fit=crop',
      'desc_short': 'MBTI T지만 말랑한 성격!',
      'desc_long': '팀플, 토론, 발표 다 좋아함. 여행, 운동, 파스타, 자기계발, 넷플릭스, 책 좋아함!',
    },
    {
      'name': '형준',
      'age': '24',
      'major': '건축학',
      'img':
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=800&auto=format&fit=crop',
      'desc_short': '도면보다 커피가 더 좋아',
      'desc_long': '커피, 사진, 여행, 건축 덕후! 커피 내리며 음악 듣는 시간, 건축 답사 환영!',
    },
  ];

  // 3. initState에서 컨트롤러 초기화
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  // 4. dispose에서 컨트롤러 해제
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<int> get visibleCardIndexes {
    final list = <int>[];
    for (int i = 0; i < cards.length; i++) {
      if (!hiddenIndexes.contains(i)) list.add(i);
    }
    return list;
  }

  void nextCard({bool isLike = false}) async {
    if (visibleCardIndexes.isEmpty) return;
    int removeIdx = visibleCardIndexes[0];

    // '좋아요' 애니메이션이 끝난 후 카드가 넘어가는 딜레이
    await Future.delayed(Duration(milliseconds: isLike ? 100 : 260));
    hiddenIndexes.add(removeIdx);
    expanded = false;

    setState(() {
      if (visibleCardIndexes.isEmpty) showEnd = true;
    });
  }

  // 5. '좋아요' 애니메이션을 실행하는 함수
  void _runLikeAnimation() {
    // 이미 애니메이션 중이면 중복 실행 방지
    if (_isAnimating) return;

    final currentCardIdx = visibleCardIndexes[0];

    // 위치와 크기 애니메이션 정의
    _alignmentAnimation = AlignmentTween(
      begin: Alignment.center,
      end: const Alignment(-0.88, -0.82), // 최종 위치 (좌상단)
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _sizeAnimation = Tween<double>(begin: 74, end: 36).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    setState(() {
      _isAnimating = true;
    });

    // 애니메이션 실행 후 처리
    _animationController.forward().then((_) {
      setState(() {
        _isAnimating = false;
        likedIndexes.add(currentCardIdx); // 애니메이션 끝나고 '좋아요' 목록에 추가
      });
      _animationController.reset();
      nextCard(isLike: true); // 다음 카드로 넘기기
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (showEnd || visibleCardIndexes.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.cyan,
                size: 60,
              ),
              const SizedBox(height: 24),
              const Text(
                '추천 친구 카드는 여기까지야!\n내일 또 만나요 :)',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final currentCardIdx = visibleCardIndexes[0];
    final card = cards[currentCardIdx];

    final double cardWidth = size.width * 0.95;
    final double cardHeight = size.height * (expanded ? 0.91 : 0.78);
    final double imgHeight = cardHeight * (expanded ? 0.56 : 0.75);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Stack(
          children: [
            // 진행바
            Positioned(
              top: 18,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  visibleCardIndexes.length,
                  (idx) => Container(
                    width: 38,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color:
                          idx == 0
                              ? Colors.cyanAccent
                              : Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
            // 카드
            Center(
              child: Dismissible(
                key: ValueKey(currentCardIdx),
                direction: DismissDirection.endToStart,
                movementDuration: const Duration(milliseconds: 340),
                onDismissed: (direction) {
                  nextCard();
                },
                child: GestureDetector(
                  // 6. onDoubleTap에서 애니메이션 함수 호출
                  onDoubleTap: _runLikeAnimation,
                  child: buildCard(
                    card,
                    cardWidth,
                    cardHeight,
                    imgHeight,
                    currentCardIdx,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard(
    Map<String, dynamic> card,
    double cardWidth,
    double cardHeight,
    double imgHeight,
    int cardIdx,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 42,
            offset: const Offset(0, 13),
          ),
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // 사진/상단 아이콘
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: SizedBox(
                  width: cardWidth,
                  height: imgHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(card['img'], fit: BoxFit.cover),
                      if (expanded)
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            color: Colors.black.withOpacity(0.23),
                          ),
                        ),
                      // 7. 정적 하트: 애니메이션 중이 아닐 때만 표시
                      if (likedIndexes.contains(cardIdx) && !_isAnimating)
                        Positioned(
                          left: 18,
                          top: 15,
                          child: Icon(
                            Icons.favorite_rounded,
                            color: Colors.cyanAccent,
                            size: 36,
                            shadows: [
                              Shadow(
                                color: Colors.cyanAccent.withOpacity(0.33),
                                blurRadius: 18,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      Positioned(
                        right: 18,
                        top: 15,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white70,
                            size: 28,
                          ),
                        ),
                      ),
                      // 8. 애니메이션 하트: 애니메이션 중일 때만 표시
                      if (_isAnimating)
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Align(
                              alignment: _alignmentAnimation!.value,
                              child: Icon(
                                Icons.favorite_rounded,
                                size: _sizeAnimation!.value,
                                color: Colors.cyanAccent,
                                shadows: [
                                  Shadow(
                                    color: Colors.cyanAccent.withOpacity(0.5),
                                    blurRadius: 34,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // 하단 정보영역
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이름, 나이
                  Row(
                    children: [
                      Text(
                        '${card['name']}, ${card['age']}',
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // 학과
                  Text(
                    '${card['major']}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 소개 텍스트
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Text(
                        expanded ? card['desc_long']! : card['desc_short']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          height: 1.48,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 더보기/닫기 버튼
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() => expanded = !expanded);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 24,
                        ),
                        margin: const EdgeInsets.only(top: 8, bottom: 6),
                        decoration: BoxDecoration(
                          color: Colors.cyanAccent.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          expanded ? '닫기' : '더보기',
                          style: TextStyle(
                            color: Colors.cyanAccent.shade200,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
