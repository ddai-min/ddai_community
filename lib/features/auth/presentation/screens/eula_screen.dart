import 'package:ddai_community/core/constants/colors.dart';
import 'package:ddai_community/core/widgets/default_dialog.dart';
import 'package:ddai_community/core/widgets/default_elevated_button.dart';
import 'package:ddai_community/core/widgets/default_layout.dart';
import 'package:ddai_community/core/widgets/default_loading_overlay.dart';
import 'package:ddai_community/features/auth/data/auth_repository.dart';
import 'package:ddai_community/features/auth/presentation/screens/login_screen.dart';
import 'package:ddai_community/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:ddai_community/features/home/presentation/screens/home_tab.dart';
import 'package:ddai_community/features/user/presentation/providers/user_me_provider.dart';
import 'package:ddai_community/features/user/presentation/screens/privacy_policy_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EulaScreen extends ConsumerStatefulWidget {
  final bool isAnonymous;

  /// 하단 [_BottomButton] 의 높이. 본문 아래 여백을 이만큼 확보하는 데 쓴다.
  static const double _bottomButtonHeight = 70;

  static String get routeName => 'eula';

  const EulaScreen({
    super.key,
    required this.isAnonymous,
  });

  @override
  ConsumerState<EulaScreen> createState() => _EulaScreenState();
}

class _EulaScreenState extends ConsumerState<EulaScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      resizeToAvoidBottomInset: false,
      title: '이용 약관',
      bottomSheet: _BottomButton(
        onPressed: _onBottomButtonPressed,
      ),
      child: const Column(
        children: [
          _Body(),
          // bottomSheet 는 본문을 밀어내지 않고 그 위를 덮는다.
          // 이 여백이 없으면 맨 아래까지 스크롤해도 마지막 조항이 버튼에 가려 안 보인다.
          SizedBox(height: EulaScreen._bottomButtonHeight),
        ],
      ),
    );
  }

  /// 약관 동의 후 분기: 익명 진입이면 즉시 익명 로그인, 아니면 회원가입 화면으로 이동한다.
  void _onBottomButtonPressed() async {
    if (widget.isAnonymous) {
      DefaultLoadingOverlay.showLoading(context);

      final result = await AuthRepository.loginAnonymous();

      if (result.isSuccess) {
        ref.read(userMeProvider.notifier).update((user) => result.user!);

        DefaultLoadingOverlay.hideLoading(context);

        context.goNamed(
          HomeTab.routeName,
        );
      } else {
        DefaultLoadingOverlay.hideLoading(context);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return DefaultDialog(
              contentText: switch (result.errorCode) {
                AuthExceptionCode.tooManyRequests =>
                  '너무 많은 익명 생성 요청이 발생했습니다.\n회원가입을 하시거나\n잠시 후 다시 시도해주세요.',
                AuthExceptionCode.captchaFailed =>
                  '자동 가입 방지 확인에 실패했습니다.\n네트워크 상태를 확인한 뒤\n다시 시도해주세요.',
                _ => '오류가 발생했습니다.\n다시 시도해주세요.',
              },
              buttonText: '확인',
              onPressed: () {
                context.goNamed(
                  LoginScreen.routeName,
                );
              },
            );
          },
        );
      }
    } else {
      context.goNamed(
        SignUpScreen.routeName,
      );
    }
  }
}

/// 이용 약관 본문.
///
/// 문구를 고칠 때는 앱의 실제 동작과 어긋나지 않는지 확인한다.
/// (신고·차단·계정 삭제·강제 업데이트·익명 계정의 한계를 조문에 그대로 적어 두었다)
class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
        children: [
          _sectionTitle('최종 사용자 사용권 계약 (EULA)'),
          const TextSpan(
            text:
                '\n최종 수정일: 2026년 9월 4일\n\n'
                '본 앱(이하 "서비스")을 설치하고 사용하는 경우, 귀하는 아래의 조건에 동의하는 것으로 간주됩니다. '
                '본 약관에 동의하지 않는 경우 서비스를 사용하지 마십시오.\n\n',
          ),
          _sectionTitle('1. 계약 당사자 및 적용 범위'),
          const TextSpan(
            text:
                '- 본 약관은 서비스 운영자(이하 "운영자")와 이용자 사이에 체결되는 계약입니다.\n'
                '- Apple Inc. 및 Google LLC 등 앱 마켓 사업자는 본 약관의 당사자가 아닙니다. '
                '서비스의 내용, 유지·보수, 고객 지원, 이용자 문의 및 콘텐츠에 관한 책임은 전적으로 운영자에게 있으며, '
                '앱 마켓 사업자는 이에 대해 어떠한 의무도 지지 않습니다.\n'
                '- 서비스가 법령이나 제3자의 권리를 침해한다는 주장이 제기되는 경우, 그 대응과 해결은 운영자의 책임입니다.\n'
                '- Apple Inc. 및 그 자회사는 본 약관의 제3수익자로서 본 약관을 이용자에게 직접 집행할 권리를 가집니다.\n'
                '- 이용자는 미국 정부의 금수 조치 대상 국가에 소재하지 않으며, '
                '미국 정부가 지정한 금지 당사자 목록에 포함되어 있지 않음을 확인합니다.\n'
                '- 본 약관에 정하지 않은 사항은 관계 법령 및 상관례에 따릅니다.\n\n',
          ),
          _sectionTitle('2. 계정'),
          const TextSpan(
            text:
                '- 서비스는 이메일 회원가입 계정과 익명 계정 두 가지 이용 방법을 제공합니다.\n'
                '- 계정 정보(이메일·비밀번호)의 관리 책임은 이용자에게 있으며, '
                '이용자의 관리 소홀로 발생한 손해에 대해 운영자는 책임지지 않습니다.\n'
                '- 닉네임에 타인을 사칭하거나 불쾌감을 주는 표현을 사용할 수 없습니다. '
                '운영자는 부적절한 닉네임을 사전 통지 없이 변경하거나 해당 계정의 이용을 제한할 수 있습니다.\n'
                '- 익명 계정은 별도의 식별 정보 없이 기기에 저장된 인증 정보로만 유지됩니다. '
                '앱을 삭제하거나 기기를 변경·초기화하면 해당 계정과 이미 작성한 게시물에 다시 접근할 수 없으며, '
                '운영자는 이를 복구해 드릴 수 없습니다. '
                '작성한 내용을 계속 이용하시려면 이메일 회원가입을 권장합니다.\n'
                '- 이용 제한을 회피할 목적으로 다수의 계정을 생성하는 행위는 금지됩니다.\n\n',
          ),
          _sectionTitle('3. 이용 연령'),
          const TextSpan(
            text:
                '서비스는 만 14세 이상만 이용할 수 있습니다. '
                '만 14세 미만임이 확인된 계정은 사전 통지 없이 삭제될 수 있습니다.\n\n',
          ),
          _sectionTitle('4. 사용자 의무'),
          const TextSpan(
            text:
                '- 귀하는 본 앱을 합법적이고 책임 있는 방식으로 사용해야 합니다.\n'
                '- 타인의 권리를 침해하거나 불쾌감을 주는 콘텐츠를 생성, 공유, 게시하거나 '
                '타 사용자에게 피해를 주는 행위를 해서는 안 됩니다.\n\n',
          ),
          _sectionTitle('5. 금지된 행위'),
          const TextSpan(
            text:
                '본 앱은 다음 행위를 엄격히 금지합니다:\n'
                '- 욕설, 혐오 표현, 폭력적 또는 선정적인 콘텐츠 게시\n'
                '- 타인을 괴롭히거나, 차별하거나, 학대하는 행위\n'
                '- 사칭, 허위 정보 유포\n'
                '- 스팸 또는 악의적인 자동화 활동\n'
                '- 타인의 개인정보를 동의 없이 수집하거나 게시하는 행위\n'
                '- 사전 승인 없는 광고, 홍보, 영리 목적의 게시\n'
                '- 타인의 저작권·상표권 등 지식재산권을 침해하는 콘텐츠 게시\n'
                '- 서비스의 취약점을 악용하거나, 정상적인 앱을 거치지 않고 서버에 접근·조작하는 행위\n'
                '- 기타 사회적으로 부적절하거나 불쾌한 행위\n\n'
                '이러한 행위가 발견될 경우, 사전 경고 없이 계정이 일시 정지되거나 영구적으로 삭제될 수 있습니다.\n\n',
          ),
          _sectionTitle('6. 무관용 정책 (Zero Tolerance Policy)'),
          const TextSpan(
            text:
                '본 앱은 모든 형태의 혐오 표현, 괴롭힘, 학대 행위에 대해 무관용 원칙(zero tolerance)을 따릅니다.\n'
                '어떤 이유로든 위와 같은 행위가 발견되면 즉시 조치가 취해지며, '
                '운영자는 법적 대응을 포함한 추가 조치를 취할 수 있습니다.\n\n',
          ),
          _sectionTitle('7. 사용자 콘텐츠 책임'),
          const TextSpan(
            text:
                '사용자가 앱 내에 게시한 모든 콘텐츠는 사용자의 책임 하에 있으며, '
                '운영자는 콘텐츠의 적절성, 신뢰성, 법적 책임 등에 대해 어떠한 보증도 하지 않습니다.\n'
                '불쾌하거나 위법한 콘텐츠는 신고 기능을 통해 제보해주시기 바랍니다.\n\n',
          ),
          _sectionTitle('8. 신고 및 차단'),
          const TextSpan(
            text:
                '- 이용자는 게시글 상세 화면에서 해당 게시물 또는 작성자를 신고할 수 있습니다.\n'
                '- 운영자는 접수된 신고를 24시간 이내에 검토하고, 본 약관을 위반한 콘텐츠를 삭제하거나 '
                '해당 계정의 이용을 제한하는 등 필요한 조치를 취합니다.\n'
                '- 이용자는 특정 이용자를 차단할 수 있습니다. '
                '차단하면 해당 이용자가 작성한 게시글·댓글·채팅이 즉시 보이지 않습니다.\n'
                '- 운영자는 신고가 없더라도 약관을 위반한 콘텐츠를 발견한 경우 사전 통지 없이 삭제할 수 있습니다.\n\n',
          ),
          _sectionTitle('9. 이용 제한 및 이의 제기'),
          const TextSpan(
            text:
                '- 운영자는 약관 위반에 대해 콘텐츠 삭제, 일시 이용 정지, 영구 이용 제한 등의 조치를 취할 수 있습니다.\n'
                '- 조치에 이의가 있는 이용자는 제19조의 문의처로 사유를 기재하여 이의를 제기할 수 있으며, '
                '운영자는 접수 후 합리적인 기간 내에 재검토 결과를 회신합니다.\n\n',
          ),
          _sectionTitle('10. 지식재산권'),
          const TextSpan(
            text:
                '- 서비스 자체와 그 구성요소(디자인, 상표, 소프트웨어)에 대한 권리는 운영자에게 있습니다.\n'
                '- 이용자가 작성한 콘텐츠의 저작권은 이용자에게 있습니다. '
                '다만 이용자는 서비스의 운영·전시·백업에 필요한 범위에서 운영자가 해당 콘텐츠를 사용할 수 있도록 '
                '무상의 비독점적 이용을 허락합니다. 이 허락은 해당 콘텐츠가 삭제되면 종료되며, '
                '백업본 및 법령상 보존 의무가 있는 경우는 예외로 합니다.\n'
                '- 서비스에 포함된 오픈소스 소프트웨어는 프로필 > 오픈소스 라이센스에서 확인할 수 있으며, '
                '해당 소프트웨어에는 각 라이선스 조건이 본 약관에 우선하여 적용됩니다.\n\n',
          ),
          _sectionTitle('11. 개인정보'),
          const TextSpan(
            text:
                '- 운영자는 서비스 제공에 필요한 최소한의 정보(이메일 주소, 닉네임, 이용자가 작성한 콘텐츠, 접속 기록)를 '
                '수집·이용합니다. 익명 계정은 이메일 주소를 수집하지 않습니다.\n'
                '- 수집한 정보는 이용자의 동의 없이 제3자에게 제공하지 않습니다. '
                '다만 법령에 따른 적법한 요구가 있는 경우는 예외로 합니다.\n'
                '- 신고 기능을 이용하면 신고자와 피신고자의 닉네임 및 식별자, 신고 사유가 '
                '신고 처리 목적으로 운영자에게 전달되어 보관됩니다.\n'
                '- 수집 항목과 보유 기간, 처리 위탁 및 국외 이전, 이용자의 권리 등 자세한 사항은 '
                '개인정보처리방침에서 확인하실 수 있습니다.\n',
          ),
          _privacyPolicyLink(context),
          const TextSpan(text: '\n\n'),
          _sectionTitle('12. 제3자 서비스'),
          const TextSpan(
            text:
                '서비스는 아래의 외부 서비스를 이용해 제공됩니다. '
                '해당 서비스의 장애 또는 정책 변경으로 인한 이용 제약에 대해 운영자는 책임을 지지 않습니다.\n'
                '- Supabase — 인증, 데이터 저장, 실시간 통신\n'
                '- Cloudflare Turnstile — 자동 가입 방지\n\n',
          ),
          _sectionTitle('13. 서비스의 제공·변경·중단'),
          const TextSpan(
            text:
                '- 운영자는 서비스의 전부 또는 일부를 사전 통지 없이 변경하거나 중단할 수 있습니다.\n'
                '- 운영자는 안정적인 운영을 위해 최소 지원 버전을 정할 수 있으며, '
                '이용자의 앱이 이보다 낮은 버전인 경우 업데이트 전까지 이용이 제한될 수 있습니다.\n'
                '- 채팅은 전체 공개로 운영됩니다. '
                '작성한 메시지는 서비스를 이용하는 누구나 볼 수 있으므로 개인정보나 민감한 내용을 입력하지 마십시오.\n\n',
          ),
          _sectionTitle('14. 계정 삭제 및 데이터 처리'),
          const TextSpan(
            text:
                '- 이용자는 프로필 > 프로필 관리 > 계정 삭제에서 언제든지 계정을 삭제할 수 있습니다. '
                '이메일 계정은 본인 확인을 위해 비밀번호 재확인 절차를 거칩니다.\n'
                '- 계정을 삭제하면 해당 계정이 작성한 게시글, 댓글, 채팅과 차단 기록이 함께 삭제되며 '
                '복구할 수 없습니다.\n'
                '- 다만 신고 기록은 반복 위반 확인과 분쟁 대응을 위해 신고 접수일로부터 3년간 보관합니다. '
                '탈퇴 시점에 계정 식별자와의 연결은 즉시 제거되어, 이후에는 특정 개인을 알아볼 수 없는 형태로만 남습니다.\n'
                '- 그 밖의 정보는 관계 법령에 따른 보존 의무가 있는 경우를 제외하고 지체 없이 파기됩니다.\n\n',
          ),
          _sectionTitle('15. 보증의 부인'),
          const TextSpan(
            text:
                '- 서비스는 "있는 그대로" 제공됩니다. '
                '운영자는 서비스가 중단되지 않거나 오류가 없을 것임을 보증하지 않습니다.\n'
                '- 운영자는 이용자가 게시한 콘텐츠의 정확성·신뢰성·적법성을 보증하지 않으며, '
                '이용자 사이에 발생한 분쟁에 개입할 의무를 지지 않습니다.\n\n',
          ),
          _sectionTitle('16. 책임의 제한'),
          const TextSpan(
            text:
                '관계 법령이 허용하는 범위에서, 운영자는 서비스 이용과 관련하여 발생한 간접손해, 특별손해, '
                '결과적 손해 및 데이터 유실에 대해 책임을 지지 않습니다. '
                '다만 운영자의 고의 또는 중대한 과실로 인한 손해는 그러하지 아니합니다.\n\n',
          ),
          _sectionTitle('17. 준거법 및 분쟁 해결'),
          const TextSpan(
            text:
                '본 약관은 대한민국 법률에 따라 해석되며, '
                '서비스 이용과 관련하여 발생한 분쟁은 민사소송법상 관할 법원에 제기합니다.\n\n',
          ),
          _sectionTitle('18. 약관 변경'),
          const TextSpan(
            text:
                '운영자는 사전 통지 없이 본 약관을 변경할 수 있으며, '
                '변경된 약관은 앱 내 공지 또는 업데이트 시점부터 효력이 발생합니다.\n'
                '변경된 약관에 동의하지 않는 경우 서비스 이용을 중단하고 계정을 삭제할 수 있으며, '
                '변경 이후에도 서비스를 계속 이용하면 변경된 약관에 동의한 것으로 봅니다.\n\n',
          ),
          _sectionTitle('19. 문의처'),
          const TextSpan(
            text:
                '서비스 이용, 콘텐츠 신고, 이의 제기 및 본 약관에 대한 문의는 아래로 연락해 주시기 바랍니다.\n'
                '이메일: yoda3714@gmail.com\n\n',
          ),
          _sectionTitle('20. 동의'),
          const TextSpan(
            text:
                '본 앱을 설치하고 사용하는 경우, 귀하는 본 계약의 모든 조항에 동의한 것으로 간주됩니다.\n'
                '또한 "동의하고 계속하기" 를 누르면 개인정보처리방침을 확인하였으며, '
                '서비스 제공에 필요한 범위에서 개인정보를 수집·이용하는 데 동의하는 것으로 봅니다.\n\n',
          ),
        ],
      ),
    );
  }

  /// 개인정보처리방침으로 나가는 인라인 링크.
  ///
  /// [TextSpan] + `TapGestureRecognizer` 가 아니라 [WidgetSpan] 을 쓴다.
  /// recognizer 는 직접 dispose 해야 해서 이 위젯을 stateful 로 바꿔야 하는데,
  /// 링크 하나 때문에 그럴 이유가 없다.
  WidgetSpan _privacyPolicyLink(BuildContext context) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: GestureDetector(
        onTap: () {
          _openPrivacyPolicy(context);
        },
        child: const Text(
          '개인정보처리방침 전문 보기',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: primaryColor,
            decoration: TextDecoration.underline,
            decorationColor: primaryColor,
          ),
        ),
      ),
    );
  }

  /// 방침 전문을 앱 안의 웹뷰로 연다.
  ///
  /// 가입 전에는 프로필 화면에 갈 수 없으므로, 동의 시점에 방침을 볼 수 있는 곳은 여기뿐이다.
  /// `pushNamed` 라야 방침을 닫고 이 동의 화면으로 되돌아온다.
  void _openPrivacyPolicy(BuildContext context) {
    context.pushNamed(
      PrivacyPolicyScreen.routeName,
    );
  }

  TextSpan _sectionTitle(String title) {
    return TextSpan(
      text: '\n$title\n',
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }
}

class _BottomButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BottomButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: EulaScreen._bottomButtonHeight,
      child: DefaultElevatedButton(
        onPressed: onPressed,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.zero),
        ),
        padding: const EdgeInsets.only(bottom: 16.0),
        text: '동의하고 계속하기',
      ),
    );
  }
}
