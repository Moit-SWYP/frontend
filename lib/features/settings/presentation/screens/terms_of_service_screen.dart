import 'package:flutter/material.dart';
import 'package:moit/core/constants/app_colors.dart';
import 'package:moit/core/constants/app_text_styles.dart';

/// 서비스 이용 약관 화면
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            size: 24,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '이용약관',
          style: AppTextStyles.heading2.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              _buildSectionTitle('제1조 (목적)'),
              const SizedBox(height: 12),
              _buildBodyText(
                '본 약관은 모잇(이하 "회사"라 함)이 제공하는 서비스의 이용과 관련하여 회사와 이용자 간의 권리, 의무 및 책임사항, 기타 필요한 사항을 규정함을 목적으로 합니다.',
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('제2조 (정의)'),
              const SizedBox(height: 12),
              _buildBodyText(
                '본 약관에서 사용하는 용어의 정의는 다음과 같습니다.\n\n'
                '1. "서비스"라 함은 회사가 제공하는 모든 서비스를 의미합니다.\n'
                '2. "이용자"라 함은 본 약관에 따라 회사가 제공하는 서비스를 이용하는 회원 및 비회원을 말합니다.\n'
                '3. "회원"이라 함은 회사와 서비스 이용계약을 체결하고 이용자 아이디를 부여받은 자를 의미합니다.\n'
                '4. "비회원"이라 함은 회원에 가입하지 않고 회사가 제공하는 서비스를 이용하는 자를 의미합니다.',
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('제3조 (이용 계약 등)'),
              const SizedBox(height: 12),
              _buildBodyText(
                '이용계약은 서비스를 이용하고자 하는 자가 본 약관의 내용에 동의한 후 회원가입신청을 하고, 회사가 이러한 신청에 대하여 승낙함으로써 체결됩니다.',
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('제4조 (서비스의 제공 및 변경)'),
              const SizedBox(height: 12),
              _buildBodyText(
                '회사는 다음과 같은 서비스를 제공합니다.\n\n'
                '1. 모임 생성 및 관리 서비스\n'
                '2. 모임 구성원 간 소통 서비스\n'
                '3. 기타 회사가 정하는 서비스',
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('제5조 (서비스의 중단)'),
              const SizedBox(height: 12),
              _buildBodyText(
                '회사는 컴퓨터 등 정보통신설비의 보수점검, 교체 및 고장, 통신의 두절 등의 사유가 발생한 경우에는 서비스의 제공을 일시적으로 중단할 수 있습니다.',
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('제6조 (회원가입)'),
              const SizedBox(height: 12),
              _buildBodyText(
                '이용자는 회사가 정한 가입 양식에 따라 회원정보를 기입한 후 본 약관에 동의한다는 의사표시를 함으로써 회원가입을 신청합니다.',
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('제7조 (회원 탈퇴 및 자격 상실 등)'),
              const SizedBox(height: 12),
              _buildBodyText(
                '회원은 회사에 언제든지 탈퇴를 요청할 수 있으며, 회사는 즉시 회원탈퇴를 처리합니다. 회원이 다음 각 호의 사유에 해당하는 경우, 회사는 회원자격을 제한 및 정지시킬 수 있습니다.\n\n'
                '1. 가입 신청 시 허위 내용을 등록한 경우\n'
                '2. 다른 사람의 서비스 이용을 방해하거나 정보를 도용하는 등 전자상거래 질서를 위협하는 경우\n'
                '3. 서비스를 이용하여 법령 또는 본 약관이 금지하거나 공서양속에 반하는 행위를 하는 경우',
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// 섹션 제목
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.subtitle1.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// 본문 텍스트
  Widget _buildBodyText(String text) {
    return Text(
      text,
      style: AppTextStyles.body1.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.6,
      ),
    );
  }
}
