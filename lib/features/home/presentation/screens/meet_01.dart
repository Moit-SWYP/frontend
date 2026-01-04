import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moit/features/home/presentation/screens/meet_03.dart';
import 'package:moit/features/meeting/data/models/meeting_create_request.dart';
import 'package:moit/features/meeting/providers/meeting_provider.dart';

/// 모임 만들기 1단계 - 약속 이름 입력 화면
class Meet01Screen extends ConsumerStatefulWidget {
  const Meet01Screen({super.key});

  @override
  ConsumerState<Meet01Screen> createState() => _Meet01ScreenState();
}

class _Meet01ScreenState extends ConsumerState<Meet01Screen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isFocused = false;
  bool _isCreating = false; // API 호출 중 상태

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// 모임 생성 API 호출
  Future<void> _createMeetingAndProceed() async {
    final meetingName = _nameController.text.trim();
    if (meetingName.isEmpty) return;

    setState(() {
      _isCreating = true;
    });

    print('🔄 [Meet01] 모임 생성 시작: $meetingName');

    try {
      // API 호출
      final request = MeetingCreateRequest(title: meetingName);
      final meetingId = await ref.read(meetingProvider.notifier).createMeeting(request);

      if (!mounted) return;

      if (meetingId != null) {
        print('✅ [Meet01] 모임 생성 성공 → 다음 화면으로 이동 (meetingId: $meetingId)');

        // 성공 시 다음 화면으로 이동 (meetingId 전달)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Meet03Screen(
              meetingName: meetingName,
              meetingId: meetingId,
            ),
          ),
        );
      } else {
        print('❌ [Meet01] 모임 생성 실패 (meetingId null)');

        // 실패 시 SnackBar 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('모임 생성에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ [Meet01] 모임 생성 에러: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모임 생성 중 오류가 발생했습니다.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          '새 약속 만들기',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
            height: 1.33,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // 제목
              const Text(
                '약속 이름을 정해주세요',
                style: TextStyle(
                  color: Color(0xFF111111), // txt-primary
                  fontSize: 18,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  height: 1.33,
                ),
              ),

              const SizedBox(height: 16),

              // 입력 필드
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: _isFocused
                      ? const Color(0xFFFDFDFD) // grey020 (포커스 시 흰색)
                      : const Color(0xFFE9EBEE), // grey040 (기본 회색)
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: _isFocused ? 2 : 0,
                      color: _isFocused
                          ? const Color(0xFF1A49F1) // main050
                          : Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: TextField(
                  controller: _nameController,
                  onChanged: (value) {
                    setState(() {}); // 버튼 상태 업데이트
                  },
                  onTap: () {
                    setState(() {
                      _isFocused = true;
                    });
                  },
                  onEditingComplete: () {
                    setState(() {
                      _isFocused = false;
                    });
                  },
                  onSubmitted: (value) {
                    setState(() {
                      _isFocused = false;
                    });
                  },
                  style: const TextStyle(
                    color: Color(0xFF111111), // txt-primary
                    fontSize: 16,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    hintText: 'ex. 고등학교 동창회',
                    hintStyle: const TextStyle(
                      color: Color(0xFF999999), // color-disable
                      fontSize: 16,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    filled: false,
                    fillColor: Colors.transparent,
                  ),
                ),
              ),

              const Spacer(),

              // 다음으로 버튼
              GestureDetector(
                onTap: (_nameController.text.isNotEmpty && !_isCreating)
                    ? _createMeetingAndProceed
                    : null,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: ShapeDecoration(
                    color: (_nameController.text.isNotEmpty && !_isCreating)
                        ? const Color(0xFF1A49F1) // main050
                        : const Color(0xFFC5C8CE), // grey050
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 20,
                        offset: Offset(0, 0),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isCreating
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            '다음으로',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w700,
                              height: 1.50,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
