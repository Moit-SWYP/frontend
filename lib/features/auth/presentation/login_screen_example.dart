import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moit/features/auth/data/models/signup_request.dart';
import 'package:moit/features/auth/providers/auth_provider.dart';
import 'package:moit/features/member/data/models/character_type.dart';

/// 로그인 화면 예시
class LoginScreenExample extends ConsumerWidget {
  const LoginScreenExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // 로딩 중
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 로그인 화면
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 에러 메시지
            if (authState.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  authState.errorMessage!,
                  style: TextStyle(color: Colors.red.shade900),
                ),
              ),
            ],

            // 카카오 로그인 버튼
            ElevatedButton(
              onPressed: () async {
                await ref.read(authProvider.notifier).loginWithKakao();

                // 로그인 후 상태 확인
                final newState = ref.read(authProvider);

                if (newState.isAuthenticated) {
                  // 로그인 성공 → 메인 화면으로
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/main');
                  }
                } else if (newState.requiresSignup) {
                  // 회원가입 필요 → 회원가입 화면으로
                  if (context.mounted) {
                    Navigator.pushNamed(context, '/signup');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEE500),
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('카카오 로그인'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 회원가입 화면 예시
class SignupScreenExample extends ConsumerStatefulWidget {
  const SignupScreenExample({super.key});

  @override
  ConsumerState<SignupScreenExample> createState() =>
      _SignupScreenExampleState();
}

class _SignupScreenExampleState extends ConsumerState<SignupScreenExample> {
  final _nicknameController = TextEditingController();
  final _birthDateController = TextEditingController();
  Gender _selectedGender = Gender.male;
  CharacterType _selectedCharacter = CharacterType.FOODIE;

  @override
  void dispose() {
    _nicknameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: authState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 닉네임 입력
                  TextField(
                    controller: _nicknameController,
                    decoration: const InputDecoration(
                      labelText: '닉네임',
                      hintText: '닉네임을 입력하세요',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 생년월일 입력
                  TextField(
                    controller: _birthDateController,
                    decoration: const InputDecoration(
                      labelText: '생년월일',
                      hintText: 'yyyy-MM-dd',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 성별 선택
                  const Text('성별'),
                  Row(
                    children: [
                      Radio<Gender>(
                        value: Gender.male,
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                      ),
                      const Text('남성'),
                      Radio<Gender>(
                        value: Gender.female,
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                      ),
                      const Text('여성'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 캐릭터 타입 선택
                  const Text('캐릭터 타입'),
                  DropdownButton<CharacterType>(
                    value: _selectedCharacter,
                    isExpanded: true,
                    items: CharacterType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getCharacterTypeLabel(type)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCharacter = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // 에러 메시지
                  if (authState.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        authState.errorMessage!,
                        style: TextStyle(color: Colors.red.shade900),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 회원가입 버튼
                  ElevatedButton(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).signup(
                            nickname: _nicknameController.text,
                            birthDate: _birthDateController.text,
                            gender: _selectedGender,
                            characterType: _selectedCharacter,
                          );

                      // 회원가입 후 상태 확인
                      final newState = ref.read(authProvider);

                      if (newState.isAuthenticated) {
                        // 회원가입 성공 → 메인 화면으로
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/main');
                        }
                      }
                    },
                    child: const Text('회원가입'),
                  ),
                ],
              ),
            ),
    );
  }

  String _getCharacterTypeLabel(CharacterType type) {
    switch (type) {
      case CharacterType.FOODIE:
        return '미식가';
      case CharacterType.DRINKER:
        return '술고래';
      case CharacterType.HEALER:
        return '힐러';
      case CharacterType.CULTURE_LOVER:
        return '문화애호가';
      case CharacterType.TRAVELER:
        return '여행가';
      case CharacterType.ACTIVE:
        return '액티브';
      case CharacterType.TREND_SETTER:
        return '트렌드세터';
      case CharacterType.STUDYER:
        return '공부벌레';
    }
  }
}

/// 프로필 화면 예시 (로그아웃 기능)
class ProfileScreenExample extends ConsumerWidget {
  const ProfileScreenExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('로그인 상태: ${authState.isAuthenticated ? "로그인됨" : "로그아웃"}'),
            const SizedBox(height: 24),

            // 로그아웃 버튼
            ElevatedButton(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();

                // 로그아웃 후 로그인 화면으로
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              child: const Text('로그아웃'),
            ),

            const SizedBox(height: 16),

            // 회원 탈퇴 버튼
            TextButton(
              onPressed: () async {
                // 확인 다이얼로그
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('회원 탈퇴'),
                    content: const Text('정말 탈퇴하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('탈퇴'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref.read(authProvider.notifier).withdraw();

                  // 탈퇴 후 로그인 화면으로
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('회원 탈퇴'),
            ),
          ],
        ),
      ),
    );
  }
}
