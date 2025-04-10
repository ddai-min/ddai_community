import 'package:ddai_community/common/component/default_elevated_button.dart';
import 'package:ddai_community/common/component/default_loading_overlay.dart';
import 'package:ddai_community/common/layout/default_layout.dart';
import 'package:ddai_community/common/util/data_utils.dart';
import 'package:ddai_community/common/view/home_tab.dart';
import 'package:ddai_community/user/model/user_model.dart';
import 'package:ddai_community/user/provider/user_me_provider.dart';
import 'package:ddai_community/user/view/sign_up_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EulaScreen extends ConsumerStatefulWidget {
  final bool isAnonymous;

  static get routeName => 'eula';

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
      child: const Padding(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          bottom: 70,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _Body(),
            ],
          ),
        ),
      ),
    );
  }

  void _onBottomButtonPressed() async {
    if (widget.isAnonymous) {
      DefaultLoadingOverlay.showLoading(context);

      final userCredential = await FirebaseAuth.instance.signInAnonymously();

      ref.read(userMeProvider.notifier).update(
            (user) => UserModel(
              id: userCredential.user!.uid,
              userName: DataUtils.setAnonymousName(
                uid: userCredential.user!.uid,
              ),
              isAnonymous: true,
            ),
          );

      DefaultLoadingOverlay.hideLoading(context);

      context.goNamed(
        HomeTab.routeName,
      );
    } else {
      context.goNamed(
        SignUpScreen.routeName,
      );
    }
  }
}

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
            text: '\n본 앱을 설치하고 사용하는 경우, 귀하는 아래의 조건에 동의하는 것으로 간주됩니다. '
                '본 약관에 동의하지 않는 경우 앱을 사용하지 마십시오.\n\n',
          ),
          _sectionTitle('1. 사용자 의무'),
          const TextSpan(
            text: '- 귀하는 본 앱을 합법적이고 책임 있는 방식으로 사용해야 합니다.\n'
                '- 타인의 권리를 침해하거나 불쾌감을 주는 콘텐츠를 생성, 공유, 게시하거나 '
                '타 사용자에게 피해를 주는 행위를 해서는 안 됩니다.\n\n',
          ),
          _sectionTitle('2. 금지된 행위'),
          const TextSpan(
            text: '본 앱은 다음 행위를 엄격히 금지합니다:\n'
                '- 욕설, 혐오 표현, 폭력적 또는 선정적인 콘텐츠 게시\n'
                '- 타인을 괴롭히거나, 차별하거나, 학대하는 행위\n'
                '- 사칭, 허위 정보 유포\n'
                '- 스팸 또는 악의적인 자동화 활동\n'
                '- 기타 사회적으로 부적절하거나 불쾌한 행위\n\n'
                '이러한 행위가 발견될 경우, 사전 경고 없이 계정이 일시 정지되거나 영구적으로 삭제될 수 있습니다.\n\n',
          ),
          _sectionTitle('3. 무관용 정책 (Zero Tolerance Policy)'),
          const TextSpan(
            text:
                '본 앱은 모든 형태의 혐오 표현, 괴롭힘, 학대 행위에 대해 무관용 원칙(zero tolerance)을 따릅니다.\n'
                '어떤 이유로든 위와 같은 행위가 발견되면 즉시 조치가 취해지며, '
                '운영자는 법적 대응을 포함한 추가 조치를 취할 수 있습니다.\n\n',
          ),
          _sectionTitle('4. 사용자 콘텐츠 책임'),
          const TextSpan(
            text: '사용자가 앱 내에 게시한 모든 콘텐츠는 사용자의 책임 하에 있으며, '
                '운영자는 콘텐츠의 적절성, 신뢰성, 법적 책임 등에 대해 어떠한 보증도 하지 않습니다.\n'
                '불쾌하거나 위법한 콘텐츠는 신고 기능을 통해 제보해주시기 바랍니다.\n\n',
          ),
          _sectionTitle('5. 약관 변경'),
          const TextSpan(
            text:
                '운영자는 사전 통지 없이 본 약관을 변경할 수 있으며, 변경된 약관은 앱 내 공지 또는 업데이트 시점부터 효력이 발생합니다.\n\n',
          ),
          _sectionTitle('6. 동의'),
          const TextSpan(
            text: '본 앱을 설치하고 사용하는 경우, 귀하는 본 계약의 모든 조항에 동의한 것으로 간주됩니다.\n\n',
          ),
        ],
      ),
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
      height: 70,
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
