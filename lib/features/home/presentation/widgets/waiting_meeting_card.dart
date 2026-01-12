import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moit/features/home/presentation/screens/meet_07.dart';
import 'package:moit/features/home/presentation/screens/meet_09.dart';
import 'package:moit/features/home/presentation/screens/meet_17.dart';
import 'package:moit/features/meeting/data/models/meeting_brief.dart';
import 'package:moit/features/meeting/presentation/screens/meeting_detail_screen.dart';
import 'package:moit/features/meeting/providers/vote_provider.dart';

/// 대기 중인 모임 카드 위젯
/// 홈 화면과 vote_home 화면에서 재사용
class WaitingMeetingCard extends ConsumerWidget {
  final MeetingBrief meeting;

  const WaitingMeetingCard({
    super.key,
    required this.meeting,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        print('🔍 [WaitingMeetingCard] 대기 모임 카드 클릭: ${meeting.meetingId} - ${meeting.title}');

        // 로딩 표시
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // 투표 요약 로드
        await ref
            .read(voteProvider(meeting.meetingId).notifier)
            .loadVoteSummary();

        // 로딩 닫기
        if (!context.mounted) return;
        Navigator.pop(context);

        // 투표 상태 확인
        final voteState = ref.read(voteProvider(meeting.meetingId));

        if (!context.mounted) return;

        // 분기 처리
        if (voteState.summary == null) {
          // API 실패 → 기존 화면으로
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MeetingDetailScreen(meeting: meeting),
            ),
          );
        } else {
          // meetingStatus와 hasVotedDate 모두 확인
          // CREATED 상태 또는 투표하지 않은 경우 → meet_07
          final isCreatedStatus = voteState.summary!.meetingStatus == MeetingStatus.created;
          final hasNotVoted = !voteState.hasVotedDate;

          if (isCreatedStatus && hasNotVoted) {
            // 투표 안 함 → 투표 화면
            print('📋 [WaitingMeetingCard] 투표 안 함 (CREATED & no vote) → meet_07 이동');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Meet07Screen(
                  meetingName: meeting.title,
                  meetingId: meeting.meetingId,
                  initialTab: 1,
                ),
              ),
            );
          } else {
            // 투표 완료 또는 투표 진행 중
            if (voteState.isHost) {
              // 모임장 → meet_09
              print('👑 [WaitingMeetingCard] 모임장 & 투표 완료 → meet_09 이동');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Meet09Screen(
                    meetingName: meeting.title,
                    meetingId: meeting.meetingId,
                    votedDates: {},
                  ),
                ),
              );
            } else {
              // 모임원 → meet_17
              print('👤 [WaitingMeetingCard] 모임원 & 투표 완료 → meet_17 이동');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Meet17Screen(
                    meetingName: meeting.title,
                    meetingId: meeting.meetingId,
                    votedDates: {},
                  ),
                ),
              );
            }
          }
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFFF7F8F9), // grey030
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "일정 이야기 중" 배지
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFE8EDFE), // main010
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _getWaitingStatusMessage(meeting.status),
                          style: const TextStyle(
                            color: Color(0xFF1A49F1), // main050
                            fontSize: 13,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                            letterSpacing: -0.33,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 모임 제목
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meeting.title,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w700,
                            height: 1.50,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // 오른쪽 화살표 아이콘
            SvgPicture.asset(
              'assets/icons/right.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Color(0xFF999999),
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 대기 모임 카드 상태별 메시지 반환
  String _getWaitingStatusMessage(MeetingStatus status) {
    switch (status) {
      case MeetingStatus.created:
      case MeetingStatus.dateVoting:
      case MeetingStatus.timeVoting:
        return '일정 이야기 중';
      case MeetingStatus.placeVoting:
        return '장소 이야기 중';
      default:
        return '친구들이 기다려요';
    }
  }
}
