// 계정 삭제 Edge Function.
//
// 클라이언트는 자기 계정을 지울 수 없다(`auth.admin` 은 secret 키 전용).
// 현재 탈퇴 플로우가 "비밀번호 재확인 -> 삭제" 이므로 그 검증까지 여기서 처리한다.
// 응답의 code 문자열은 앱의 AuthExceptionCode 와 값을 맞춘다.
//
// 배포: supabase functions deploy delete-account
import { createClient } from 'jsr:@supabase/supabase-js@2'

// Edge Function 런타임에 자동 주입되는 값. 신규/레거시 이름을 모두 받아둔다.
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const PUBLISHABLE_KEY =
  Deno.env.get('SUPABASE_ANON_KEY') ?? Deno.env.get('SUPABASE_PUBLISHABLE_KEY')!
const SECRET_KEY =
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? Deno.env.get('SUPABASE_SECRET_KEY')!

Deno.serve(async (req) => {
  const authHeader = req.headers.get('Authorization')
  if (!authHeader) return json({ code: 'session_not_found' }, 401)

  const { password } = await req.json().catch(() => ({ password: null }))

  // 1) 요청자 신원 확인 — 호출자의 JWT 를 그대로 써서 "누가 부르는지"를 서버가 판정한다.
  const userClient = createClient(SUPABASE_URL, PUBLISHABLE_KEY, {
    global: { headers: { Authorization: authHeader } },
  })
  const { data: { user } } = await userClient.auth.getUser()
  if (!user) return json({ code: 'session_not_found' }, 401)

  // 2) 비밀번호 재확인. 익명 유저는 비밀번호가 없으므로 건너뛴다.
  if (!user.is_anonymous) {
    if (typeof password !== 'string' || password.length === 0) {
      return json({ code: 'invalid_credentials' }, 401)
    }

    const checkClient = createClient(SUPABASE_URL, PUBLISHABLE_KEY)
    const { error } = await checkClient.auth.signInWithPassword({
      email: user.email!,
      password,
    })
    if (error) return json({ code: 'invalid_credentials' }, 401)
  }

  // 3) secret 키로 실제 삭제. profile / board / comment / chat 등은 FK CASCADE 로 함께 지워진다.
  const adminClient = createClient(SUPABASE_URL, SECRET_KEY)
  const { error } = await adminClient.auth.admin.deleteUser(user.id)
  if (error) {
    console.error(error)
    return json({ code: 'unknown_error' }, 500)
  }

  return json({ ok: true }, 200)
})

function json(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  })
}
