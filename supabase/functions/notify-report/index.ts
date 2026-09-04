// 신고 알림 Edge Function.
//
// `report` 는 SELECT 정책이 없어서 앱에서 신고 내역을 읽을 수 없다(의도된 설계다 —
// 신고 내용이 신고자에게도, 피신고자에게도 보이면 안 된다). 그래서 "신고가 들어왔다"는
// 사실만 운영자 메일로 알리고, 내용 확인과 조치는 Supabase 대시보드에서 한다.
// EULA 8조가 "24시간 이내 검토"를 약속하고 있어서 알림이 없으면 그 약속을 지킬 수 없다.
//
// 부르는 쪽은 사람이 아니라 Database Webhook 이다. 호출자 JWT 가 없으므로 JWT 검증을
// 끄고, 대신 공유 비밀 헤더로 발신자를 확인한다.
//
// 배포: supabase functions deploy notify-report --no-verify-jwt --project-ref <ref>
//
// 필요한 secret (supabase secrets set KEY=VALUE):
//   REPORT_ALERT_SECRET  웹훅이 보내는 x-webhook-secret 헤더와 같은 값
//   RESEND_API_KEY       https://resend.com 에서 발급한 API 키
//   REPORT_ALERT_TO      알림을 받을 운영자 메일 주소
//   REPORT_ALERT_FROM    (선택) 보내는 주소. 기본값은 도메인 인증 없이 쓸 수 있는
//                        테스트 주소이며, 이 경우 Resend 계정 소유자 본인에게만
//                        배달된다. 운영자가 자기 자신에게 보내는 지금 용도에는 충분하다.

const ALERT_SECRET = Deno.env.get('REPORT_ALERT_SECRET') ?? ''
const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY') ?? ''
const ALERT_TO = Deno.env.get('REPORT_ALERT_TO') ?? ''
const ALERT_FROM = Deno.env.get('REPORT_ALERT_FROM') ?? 'onboarding@resend.dev'

Deno.serve(async (req) => {
  if (!ALERT_SECRET || !RESEND_API_KEY || !ALERT_TO) {
    console.error(
      'secret 이 없다. REPORT_ALERT_SECRET · RESEND_API_KEY · REPORT_ALERT_TO 를 설정해야 한다.',
    )
    return json({ code: 'not_configured' }, 500)
  }

  // 이 함수는 JWT 검증 없이 배포되므로 주소만 알면 누구나 부를 수 있다.
  // 공유 비밀이 유일한 관문이다.
  if (!timingSafeEqual(req.headers.get('x-webhook-secret') ?? '', ALERT_SECRET)) {
    return json({ code: 'unauthorized' }, 401)
  }

  const payload = await req.json().catch(() => null)
  const record = payload?.record

  if (payload?.type !== 'INSERT' || !record) {
    return json({ code: 'bad_request' }, 400)
  }

  const body = [
    '새 신고가 접수되었습니다.',
    '',
    `접수 시각   : ${record.created_at}`,
    `신고자      : ${record.reporter_user_name} (${record.reporter_user_uid})`,
    `피신고자    : ${record.reported_user_name} (${record.reported_user_uid})`,
    `대상 콘텐츠 : ${record.report_content_id}`,
    '',
    '신고 사유',
    '--------',
    record.report_reason,
    '',
    'report 테이블은 앱에서 조회할 수 없다. 확인과 조치는 Supabase 대시보드에서 한다.',
  ].join('\n')

  const res = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${RESEND_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      from: ALERT_FROM,
      to: [ALERT_TO],
      subject: `[DDAI] 신고 접수 — ${record.reported_user_name}`,
      // 신고 사유는 이용자가 쓴 자유 입력이다. html 로 보내면 메일 본문에 마크업이
      // 그대로 주입되므로 text 로만 보낸다.
      text: body,
    }),
  })

  if (!res.ok) {
    console.error('메일 발송 실패', res.status, await res.text())
    return json({ code: 'send_failed' }, 502)
  }

  return json({ ok: true }, 200)
})

/// 공유 비밀을 상수 시간으로 비교한다.
///
/// `===` 는 첫 글자가 다르면 즉시 끝나서 비밀값을 한 글자씩 맞춰 볼 여지를 준다.
/// (길이는 드러나지만 그것만으로는 값을 복원할 수 없다)
function timingSafeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) {
    return false
  }

  let diff = 0
  for (let i = 0; i < a.length; i++) {
    diff |= a.charCodeAt(i) ^ b.charCodeAt(i)
  }

  return diff === 0
}

function json(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  })
}
