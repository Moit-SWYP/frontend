import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:moit/core/constants/app_colors.dart';

/// 회원탈퇴 화면
class WithdrawAccountScreen extends StatefulWidget {
  const WithdrawAccountScreen({super.key});

  @override
  State<WithdrawAccountScreen> createState() => _WithdrawAccountScreenState();
}

class _WithdrawAccountScreenState extends State<WithdrawAccountScreen> {
  // 선택된 탈퇴 사유
  String? selectedReason;

  // 기타사항 직접 입력 모드 여부
  bool isCustomInput = false;

  // 기타사항 직접 입력 내용
  String customReason = '';

  // 기타사항 입력 컨트롤러
  final TextEditingController _customReasonController = TextEditingController();

  // 탈퇴 사유 옵션
  final List<String> _withdrawalReasons = [
    '일정 생성이 불편해요',
    '원하는 기능이 없어요',
    '버그가 자주 발생해요',
    '기타사항 (직접 입력)',
  ];

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  /// 탈퇴하기 버튼 활성화 여부
  bool get _isButtonEnabled {
    if (isCustomInput) {
      return customReason.trim().isNotEmpty;
    }
    return selectedReason != null && selectedReason != '기타사항 (직접 입력)';
  }

  /// 확인 다이얼로그 표시
  Future<void> _showWithdrawConfirmDialog() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 캐릭터 이미지
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/group_misik.svg',
                    width: 72.9,
                    height: 75.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '정말 탈퇴하실 건가요?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.33,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '회원탈퇴시 모잇에서 제공되는 다양한 혜택과\n편의 기능의 이용이 불가합니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.38,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // 탈퇴하기 버튼 (왼쪽)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC5C8CE),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        minimumSize: const Size(0, 44),
                      ),
                      child: const Text(
                        '탈퇴하기',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 다시 생각하기 버튼 (오른쪽)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        minimumSize: const Size(0, 44),
                      ),
                      child: const Text(
                        '다시 생각하기',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      // TODO: 백엔드 API 연동 필요
      // 엔드포인트: POST /api/members/me/withdraw
      // 요청 바디: {"reason": selectedReason ?? customReason}

      // 임시: 바로 로그인 화면으로 이동
      if (mounted) {
        context.go('/login');
      }
    } else if (confirmed == false) {
      // 다시 생각하기 선택 시 home_profile_my로 이동
      if (mounted) {
        context.go('/profile/my');
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
        toolbarHeight: 56,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 24),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text(
          '회원탈퇴',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // 메인 텍스트
              const Text(
                '모잇 서비스 개선을 위해\n탈퇴 사유를 알려주세요',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.33, // 32px / 24px = 1.33
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 32),
              // 드롭다운 또는 직접 입력 필드
              if (!isCustomInput)
                // 드롭다운
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppColors.grey040,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonFormField<String>(
                    value: selectedReason,
                    hint: const Text(
                      '탈퇴 사유를 선택해주세요',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(16),
                    menuMaxHeight: 300,
                    items: _withdrawalReasons.map((String reason) {
                      return DropdownMenuItem<String>(
                        value: reason,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                          child: Text(
                            reason,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.43, // 20px / 14px = 1.43
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        if (value == '기타사항 (직접 입력)') {
                          // 기타사항 선택 시 직접 입력 모드로 전환
                          isCustomInput = true;
                          selectedReason = null;
                        } else {
                          selectedReason = value;
                        }
                      });
                    },
                    ),
                  ),
                )
              else
                // 직접 입력 필드
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.grey040,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextFormField(
                    controller: _customReasonController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: '탈퇴 사유를 입력해주세요',
                      hintStyle: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: AppColors.textSecondary,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            // 직접 입력 모드 해제
                            isCustomInput = false;
                            customReason = '';
                            _customReasonController.clear();
                          });
                        },
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: AppColors.textPrimary,
                    ),
                    onChanged: (value) {
                      setState(() {
                        customReason = value;
                      });
                    },
                  ),
                ),
              const SizedBox(height: 24),
              // 경고 메시지
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    'assets/icons/warning.svg',
                    width: 16,
                    height: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '탈퇴 시 모잇 서비스 내 개인정보는 모두 파기됩니다.',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.38,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // 탈퇴하기 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled ? _showWithdrawConfirmDialog : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isButtonEnabled
                        ? AppColors.primaryBlue
                        : AppColors.buttonDisabled,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    disabledBackgroundColor: AppColors.buttonDisabled,
                    disabledForegroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    minimumSize: const Size(0, 56),
                  ),
                  child: const Text(
                    '탈퇴하기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
