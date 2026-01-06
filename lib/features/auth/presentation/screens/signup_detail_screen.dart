import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moit/core/constants/app_colors.dart';
import 'package:moit/core/constants/app_text_styles.dart';
import 'package:moit/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:moit/features/auth/presentation/widgets/gender_selector.dart';
import 'package:moit/features/auth/providers/auth_provider.dart';
import 'package:moit/features/auth/data/models/signup_request.dart';
import 'package:moit/features/member/data/models/character_type.dart';

/// 회원가입 상세 정보 입력 화면
class SignupDetailScreen extends ConsumerStatefulWidget {
  const SignupDetailScreen({super.key});

  @override
  ConsumerState<SignupDetailScreen> createState() => _SignupDetailScreenState();
}

class _SignupDetailScreenState extends ConsumerState<SignupDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  Gender? _selectedGender;

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  /// 다음 버튼 활성화 여부
  bool get _isFormValid {
    return _nameController.text.isNotEmpty &&
        _selectedGender != null &&
        _birthDateController.text.length == 8;
  }

  /// 생년월일 유효성 검사
  String? _validateBirthDate(String? value) {
    if (value == null || value.isEmpty) {
      return '생년월일을 입력해주세요';
    }
    if (value.length != 8) {
      return 'YYYYMMDD 형식으로 입력해주세요';
    }
    // 간단한 날짜 유효성 검사
    final year = int.tryParse(value.substring(0, 4));
    final month = int.tryParse(value.substring(4, 6));
    final day = int.tryParse(value.substring(6, 8));

    if (year == null || month == null || day == null) {
      return '올바른 날짜를 입력해주세요';
    }
    if (year < 1900 || year > DateTime.now().year) {
      return '올바른 연도를 입력해주세요';
    }
    if (month < 1 || month > 12) {
      return '올바른 월을 입력해주세요';
    }
    if (day < 1 || day > 31) {
      return '올바른 일을 입력해주세요';
    }
    return null;
  }

  /// 다음 버튼 클릭
  void _handleNext() async {
    if (_formKey.currentState!.validate() && _selectedGender != null) {
      // 생년월일을 yyyy-MM-dd 형식으로 변환
      final birthDate = _birthDateController.text;
      final formattedBirthDate = '${birthDate.substring(0, 4)}-${birthDate.substring(4, 6)}-${birthDate.substring(6, 8)}';

      // 회원가입 API 호출
      await ref.read(authProvider.notifier).signup(
        nickname: _nameController.text,
        birthDate: formattedBirthDate,
        gender: _selectedGender!,
        characterType: CharacterType.FOODIE, // TODO: 캐릭터 선택 화면 추가 시 수정
      );

      if (!mounted) return;

      // 회원가입 후 상태 확인
      final newState = ref.read(authProvider);

      if (newState.isAuthenticated) {
        // 회원가입 성공 → 홈 화면으로
        context.go('/');
      } else if (newState.errorMessage != null) {
        // 에러 발생 시 스낵바 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(newState.errorMessage!)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: authState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),

                            // 타이틀
                            Text(
                              '모잇에서 쓰일\n사용자님의 프로필을 입력해주세요!',
                              style: AppTextStyles.heading2,
                            ),

                            const SizedBox(height: 40),

                            // 에러 메시지 표시
                            if (authState.errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  authState.errorMessage!,
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.red.shade900,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                      // 이름 입력
                      CustomTextField(
                        label: '이름',
                        hintText: '이름을 입력해주세요',
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        onChanged: (_) => setState(() {}),
                      ),

                      const SizedBox(height: 24),

                      // 성별 선택
                      GenderSelector(
                        label: '성별',
                        selectedGender: _selectedGender,
                        onChanged: (gender) {
                          setState(() {
                            _selectedGender = gender;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // 생년월일 입력
                      CustomTextField(
                        label: '생년월일',
                        hintText: '생년월일을 입력해주세요(YYYYMMDD)',
                        controller: _birthDateController,
                        keyboardType: TextInputType.number,
                        maxLength: 8,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: _validateBirthDate,
                        onChanged: (_) => setState(() {}),
                      ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),

                    // 다음 버튼 (하단 고정)
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isFormValid ? _handleNext : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFormValid
                                ? AppColors.primaryBlue
                                : AppColors.buttonDisabled,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.buttonDisabled,
                            disabledForegroundColor: AppColors.buttonTextDisabled,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            '다음',
                            style: AppTextStyles.button,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
