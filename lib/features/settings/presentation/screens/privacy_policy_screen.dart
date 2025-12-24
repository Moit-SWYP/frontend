import 'package:flutter/material.dart';
import 'package:moit/core/constants/app_colors.dart';
import 'package:moit/core/constants/app_text_styles.dart';

/// 개인정보 처리 방침 화면
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          '개인정보처리방침',
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

              _buildBodyText(
                '본 개인정보처리방침은 모잇(이하 "회사"라 함)이 제공하는 서비스에서 수집하는 개인정보의 항목, 수집 및 이용 목적, 보유 및 이용 기간, 파기 절차 및 파기 방법 등에 관한 사항을 안내합니다.',
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('1. 수집하는 개인정보 항목'),
              const SizedBox(height: 12),
              _buildBodyText(
                '회사는 서비스 제공을 위해 다음과 같은 개인정보를 수집하고 있습니다.\n\n'
                '【 필수항목 】\n'
                '• 이메일 주소\n'
                '• 닉네임\n'
                '• 생년월일\n'
                '• 성별\n\n'
                '【 선택항목 】\n'
                '• 프로필 사진\n'
                '• 선호하는 모임 유형',
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('2. 개인정보의 수집 및 이용 목적'),
              const SizedBox(height: 12),
              _buildBodyText(
                '회사는 수집한 개인정보를 다음의 목적을 위해 활용합니다.\n\n'
                '• 서비스 제공에 관한 계약 이행 및 서비스 제공에 따른 요금정산\n'
                '• 회원 관리: 회원제 서비스 이용에 따른 본인확인, 개인 식별, 불량회원의 부정 이용 방지와 비인가 사용 방지, 가입 의사 확인\n'
                '• 마케팅 및 광고에 활용: 이벤트 등 광고성 정보 전달, 접속 빈도 파악 또는 회원의 서비스 이용에 대한 통계',
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('3. 개인정보의 보유 및 이용 기간'),
              const SizedBox(height: 12),
              _buildBodyText(
                '회사는 개인정보 수집 및 이용목적이 달성된 후에는 예외 없이 해당 정보를 지체 없이 파기합니다.\n\n'
                '단, 다음의 정보에 대해서는 아래의 이유로 명시한 기간 동안 보존합니다.\n\n'
                '• 보존 항목: 이메일, 닉네임, 가입일시\n'
                '• 보존 근거: 전자상거래 등에서의 소비자보호에 관한 법률\n'
                '• 보존 기간: 3년',
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('4. 개인정보의 파기 절차 및 방법'),
              const SizedBox(height: 12),
              _buildBodyText(
                '회사는 원칙적으로 개인정보 수집 및 이용목적이 달성된 후에는 해당 정보를 지체 없이 파기합니다.\n\n'
                '【 파기절차 】\n'
                '회원님이 입력하신 정보는 목적이 달성된 후 별도의 DB로 옮겨져(종이의 경우 별도의 서류함) 내부 방침 및 기타 관련 법령에 의한 정보보호 사유에 따라(보유 및 이용기간 참조) 일정 기간 저장된 후 파기됩니다.\n\n'
                '【 파기방법 】\n'
                '• 전자적 파일 형태로 저장된 개인정보는 기록을 재생할 수 없는 기술적 방법을 사용하여 삭제합니다.\n'
                '• 종이에 출력된 개인정보는 분쇄기로 분쇄하거나 소각을 통하여 파기합니다.',
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('5. 개인정보의 제3자 제공'),
              const SizedBox(height: 12),
              _buildBodyText(
                '회사는 원칙적으로 이용자의 개인정보를 외부에 제공하지 않습니다. 다만, 아래의 경우에는 예외로 합니다.\n\n'
                '• 이용자들이 사전에 동의한 경우\n'
                '• 법령의 규정에 의거하거나, 수사 목적으로 법령에 정해진 절차와 방법에 따라 수사기관의 요구가 있는 경우',
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('6. 이용자의 권리와 그 행사방법'),
              const SizedBox(height: 12),
              _buildBodyText(
                '이용자는 언제든지 등록되어 있는 자신의 개인정보를 조회하거나 수정할 수 있으며 가입해지를 요청할 수도 있습니다.\n\n'
                '개인정보 조회 및 수정은 "내 정보" 메뉴에서, 가입해지(동의철회)는 "회원탈퇴"를 통해 가능합니다.',
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
