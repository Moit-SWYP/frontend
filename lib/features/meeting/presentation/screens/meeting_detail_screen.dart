import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moit/core/utils/date_formatter.dart';
import 'package:moit/features/meeting/data/models/meeting_brief.dart';
import 'package:moit/features/meeting/providers/vote_provider.dart';

/// 모임 상세 화면
/// MeetingBrief 기본 정보 + 투표 요약 정보 표시
class MeetingDetailScreen extends ConsumerStatefulWidget {
  final MeetingBrief meeting;

  const MeetingDetailScreen({
    super.key,
    required this.meeting,
  });

  @override
  ConsumerState<MeetingDetailScreen> createState() =>
      _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends ConsumerState<MeetingDetailScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 투표 요약 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('📋 [MeetingDetail] 투표 요약 로드 시작: ${widget.meeting.meetingId}');
      ref
          .read(voteProvider(widget.meeting.meetingId).notifier)
          .loadVoteSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final voteState = ref.watch(voteProvider(widget.meeting.meetingId));

    // 에러 메시지 표시
    if (voteState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(voteState.errorMessage!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        ref
            .read(voteProvider(widget.meeting.meetingId).notifier)
            .clearError();
      });
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF111111)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '모임 상세',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
            height: 1.33,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // 모임 제목
                Text(
                  widget.meeting.title,
                  style: const TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 24,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 1.33,
                  ),
                ),

                const SizedBox(height: 16),

                // 상태 정보
                _buildInfoRow('상태', widget.meeting.statusText),

                const SizedBox(height: 12),

                // 날짜 정보
                _buildInfoRow(
                  '날짜',
                  widget.meeting.date != null
                      ? DateFormatter.toKoreanDate(widget.meeting.date)
                      : '날짜 미정',
                ),

                const SizedBox(height: 32),

                // 투표 정보 (투표 요약이 로드된 경우)
                if (voteState.summary != null) ...[
                  // 확정된 날짜 표시
                  if (voteState.summary!.confirmedDate != null)
                    _buildInfoRow(
                      '확정 날짜',
                      DateFormatter.toKoreanDate(voteState.summary!.confirmedDate),
                    ),

                  // 확정된 시간 표시
                  if (voteState.summary!.confirmedTime != null) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow('확정 시간', voteState.summary!.confirmedTime!),
                  ],

                  // 날짜 투표 정보
                  if (voteState.isDateVoting &&
                      voteState.summary!.dateSummary != null) ...[
                    const SizedBox(height: 32),
                    const Text(
                      '날짜 투표 현황',
                      style: TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 16,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF7F8F9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (voteState.summary!.dateSummary!.topDates.isNotEmpty) ...[
                            const Text(
                              '최다 득표 날짜',
                              style: TextStyle(
                                color: Color(0xFF111111),
                                fontSize: 14,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...voteState.summary!.dateSummary!.topDates.map(
                              (date) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '📅 ${DateFormatter.toKoreanDate(date)}',
                                  style: const TextStyle(
                                    color: Color(0xFF505050),
                                    fontSize: 13,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (voteState.hasVotedDate) ...[
                            const SizedBox(height: 12),
                            const Text(
                              '내가 투표한 날짜',
                              style: TextStyle(
                                color: Color(0xFF111111),
                                fontSize: 14,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...voteState.summary!.dateSummary!.votedDates.map(
                              (date) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '✓ ${DateFormatter.toKoreanDate(date)}',
                                  style: const TextStyle(
                                    color: Color(0xFF1A49F1),
                                    fontSize: 13,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  // 시간 투표 정보
                  if (voteState.isTimeVoting &&
                      voteState.summary!.timeSummary != null) ...[
                    const SizedBox(height: 24),
                    const Text(
                      '시간 투표 현황',
                      style: TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 16,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF7F8F9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (voteState.summary!.timeSummary!.topTimes.isNotEmpty) ...[
                            const Text(
                              '최다 득표 시간',
                              style: TextStyle(
                                color: Color(0xFF111111),
                                fontSize: 14,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...voteState.summary!.timeSummary!.topTimes.map(
                              (time) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '🕐 $time',
                                  style: const TextStyle(
                                    color: Color(0xFF505050),
                                    fontSize: 13,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (voteState.hasVotedTime) ...[
                            const SizedBox(height: 12),
                            const Text(
                              '내가 투표한 시간',
                              style: TextStyle(
                                color: Color(0xFF111111),
                                fontSize: 14,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...voteState.summary!.timeSummary!.votedTimes.map(
                              (time) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '✓ $time',
                                  style: const TextStyle(
                                    color: Color(0xFF1A49F1),
                                    fontSize: 13,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],

                // 로딩 중
                if (voteState.isLoading && voteState.summary == null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF7F8F9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 정보 행 위젯
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF999999),
              fontSize: 14,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111111),
              fontSize: 14,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
