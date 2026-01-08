import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 링크 공유 유틸리티
///
/// 모든 화면에서 동일한 링크 공유 다이얼로그를 사용할 수 있도록 제공
class ShareLinkUtils {
  /// 링크 공유 다이얼로그 표시
  ///
  /// [context]: BuildContext
  /// [linkUrl]: 공유할 링크 URL
  static void showLinkDialog(BuildContext context, String linkUrl) {
    bool isLinkCopied = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 제목
                  const Text(
                    '약속방 링크 공유하기',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 18,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      height: 1.33,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 설명
                  const Text(
                    '약속방 링크를 친구에게 공유하고\n모잇에서 편리하게 약속을 정해보세요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF505050),
                      fontSize: 13,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      height: 1.38,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 링크 박스 (탭 가능)
                  GestureDetector(
                    onTap: () {
                      _copyLinkToClipboard(context, linkUrl);
                      setDialogState(() {
                        isLinkCopied = true;
                      });
                      // 2초 후 원래 색상으로 복귀
                      Future.delayed(const Duration(seconds: 2), () {
                        if (context.mounted) {
                          setDialogState(() {
                            isLinkCopied = false;
                          });
                        }
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: ShapeDecoration(
                        color: isLinkCopied
                            ? const Color(0xFFE8EDFE) // main010 (복사 후)
                            : const Color(0xFFE9EBEE), // grey040 (기본)
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              linkUrl,
                              style: TextStyle(
                                color: isLinkCopied
                                    ? const Color(0xFF1A49F1) // main050 (복사 후)
                                    : const Color(0xFF999999), // color-disable (기본)
                                fontSize: 16,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w400,
                                height: 1.50,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SvgPicture.asset(
                            'assets/icons/copy.svg',
                            width: 18,
                            height: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 클립보드에 링크 복사 + 토스트 표시
  ///
  /// [context]: BuildContext
  /// [linkUrl]: 복사할 링크 URL
  static void _copyLinkToClipboard(BuildContext context, String linkUrl) {
    Clipboard.setData(ClipboardData(text: linkUrl));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('링크가 복사되었습니다'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
