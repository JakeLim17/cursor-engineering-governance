# Cursor Engineering Governance

Cursor용 **글로벌 엔지니어링 거버넌스 v1.5** 룰 템플릿입니다.  
보안 · 정확성 · 계정 검증 · 시크릿 · 멀티테넌트 · 배포 안전 · AI/웹훅 · 비용 가드레일 등 **제품 요구사항이 아닌** 공통 엔지니어링 규칙을 Agent에 주입합니다.

**동작:** `.cursor/rules/engineering-governance.mdc`는 ‘개발 전 항상 열어 보는 문서’가 아니라 Cursor `alwaysApply: true`로 **매 Agent 채팅에 자동 주입**됩니다. 에이전트는 룰 텍스트에 **없는** 프레임워크 함정(예: Next `"use server"`의 모든 export가 공개 엔드포인트)을 추측하지 말고, **명시된 조항**을 따릅니다. 새 함정이 보이면 이 레포에 조항을 추가하세요.

회사명·개인 이메일·내부 프로젝트명은 **플레이스홀더를 넣지 않습니다**.  
`./install.sh` 실행 시 **프로바이더 카테고리별 계정(이메일)** 을 물어보고 `account-map.mdc`에 저장합니다. (비밀번호·API 키는 절대 입력하지 마세요.)

**습관:** 하루 한 번, 그날 작업에서 드러난 갭(보안 사고, AI티 나는 카피, 프레임워크 함정 등)을 짧은 조항으로 보강한 뒤 `./install.sh --skip-accounts`로 재설치하고 이 레포만 커밋 - 자세한 내용은 §46.

**핵심 안내:**

> 전역 account-map은 팀 **기본 힌트**입니다. 설치 시 아는 계정만 입력하고, 모르는 카테고리는 비워 두세요. Supabase·Vercel 등은 **프로젝트 생성·연동할 때** 개발자가 그 레포에 맞게 조정합니다. 프로젝트별 계정이 다르면 `<repo>/.cursor/rules/account-map.mdc`를 추가하면 전역보다 우선합니다.

| 파일 | 역할 |
|------|------|
| [`.cursor/rules/engineering-governance.mdc`](.cursor/rules/engineering-governance.mdc) | **설치 SSOT** — `install.sh`가 복사하는 요약 룰 (`alwaysApply: true`) |
| [`GOVERNANCE.md`](GOVERNANCE.md) | 같은 규칙의 §0-§45 **전문** (읽기·커스터마이즈용). 조항 변경 시 **mdc와 함께** 맞춤 |
| [`templates/account-map.example.mdc`](templates/account-map.example.mdc) | 계정 맵 템플릿 (설치 스크립트가 채움) |
| [`install.sh`](install.sh) | 설치 + **계정 입력 프롬프트** |

---

## 적용 방법 (권장 순서)

### A. 유저 전역 (모든 프로젝트에 적용)

```bash
git clone https://github.com/JakeLim17/cursor-engineering-governance.git
cd cursor-engineering-governance
chmod +x install.sh
./install.sh
```

실행 중 예시:

```text
Source control (GitHub/GitLab/Bitbucket): you@example.com
Hosting/Deploy (Vercel/Netlify/Railway/Render): you@example.com
Database/BaaS (Supabase/Firebase/PlanetScale/Neon): you@example.com
Cloud (AWS/GCP/Azure) (Enter to skip):
CDN/Edge (Cloudflare) (Enter to skip):
```

설치 위치:

- `~/.cursor/rules/engineering-governance.mdc`
- `~/.cursor/rules/account-map.mdc` ← 입력한 메일/계정 (빈 칸 = 미검증)

### B. 프로젝트만 (해당 레포에만 적용)

```bash
cd /path/to/your-app
/path/to/cursor-engineering-governance/install.sh --project
```

설치 위치:

- `your-app/.cursor/rules/engineering-governance.mdc`
- `your-app/.cursor/rules/account-map.mdc` ← 설치 시 입력

프로젝트 맵이 있으면 **전역 맵보다 우선**합니다.

### C. 수동 복사

1. [`.cursor/rules/engineering-governance.mdc`](.cursor/rules/engineering-governance.mdc) 내용을 복사  
2. 아래 중 하나에 저장  
   - 전역: `~/.cursor/rules/engineering-governance.mdc`  
   - 프로젝트: `<repo>/.cursor/rules/engineering-governance.mdc`  
3. (선택) `templates/account-map.example.mdc`를 복사해 사용하는 프로바이더 행만 채우기  
4. Cursor를 다시 열거나 **새 Agent 채팅**을 시작

### D. Cursor Settings UI

1. Cursor → **Settings** → **Rules** (또는 Project Rules)  
2. **Add Rule** / 파일 추가  
3. 이 레포의 `.mdc`를 붙이거나 Import  

UI 메뉴명은 Cursor 버전에 따라 조금 다를 수 있습니다. 파일이 `~/.cursor/rules/` 또는 프로젝트 `.cursor/rules/`에 있으면 Agent가 읽습니다.

---

## 계정 맵 동작 (v1.1+)

| 상태 | 의미 |
|------|------|
| 값이 있음 | 해당 프로바이더 작업 전 CLI/콘솔 계정과 대조 |
| **빈 칸** | **미검증** — Agent는 해당 프로바이더를 건드리기 전 사용자에게 확인 |
| `YOUR_*` 플레이스홀더 | 사용하지 않음 (v1.0 잔여 맵은 직접 수정 권장) |

카테고리: Source control · Hosting/Deploy · Database/BaaS · Cloud(선택) · CDN/Edge(선택)

---

## 설치 옵션

| 옵션 / 환경변수 | 의미 |
|-----------------|------|
| (기본) | 대화형으로 카테고리별 계정 입력 (Cloud/CDN은 Enter로 건너뛰기) |
| `--project` | 현재 폴더 `.cursor/rules`에 설치 |
| `--skip-accounts` | 룰만 설치, 계정 질문 생략 (빈 행 템플릿) |
| `--yes` | 질문 없이 env 값으로 기록; env 없으면 **빈 칸** (CI용) |
| `SOURCE_CONTROL_ACCOUNT` | GitHub / GitLab / Bitbucket |
| `HOSTING_ACCOUNT` | Vercel / Netlify / Railway / Render |
| `DATABASE_ACCOUNT` | Supabase / Firebase / PlanetScale / Neon |
| `CLOUD_ACCOUNT` | AWS / GCP / Azure (선택) |
| `CDN_ACCOUNT` | Cloudflare (선택) |
| `GITHUB_ACCOUNT` 등 (v1.0) | 하위 호환 — 위 새 변수로 매핑 |

예 (스크립트):

```bash
SOURCE_CONTROL_ACCOUNT=dev@example.com \
HOSTING_ACCOUNT=dev@example.com \
DATABASE_ACCOUNT=dev@example.com \
./install.sh --yes
```

나중에 바꾸려면 `account-map.mdc`를 직접 수정하거나, 설치를 다시 실행하면 됩니다.

이미 설치한 뒤 이 레포를 업데이트했다면, 룰만 덮어쓰려면:

```bash
./install.sh --skip-accounts
```

(`account-map.mdc`는 유지되고 `engineering-governance.mdc`만 갱신됩니다.)

## 설치 후 검증

새 Agent 채팅에서:

> “account-map에 등록된 Source control / Hosting / Database 계정이 뭐야?”

입력한 값이 나오면 적용된 것입니다. 빈 카테고리는 “미검증”으로 안내되어야 합니다.

---

## 레포 전용 룰과의 관계

```text
플랫폼/시스템 > 보안 > 프로젝트 AGENTS.md / .cursor/rules > 이 글로벌 룰 > 일반 선호
```

이미 프로젝트에 상세 하네스가 있으면 **그대로 두고**, 이 룰은 공통 안전망으로만 쓰면 됩니다.

---

## v1.5 주요 변경

- **일일 거버넌스 보강 습관** (§46): 하루 한 번(또는 의미 있는 작업 마무리 시) 그날 드러난 실제 갭을 GOVERNANCE.md·mdc에 짧은 명시 조항으로 추가 → `install.sh --skip-accounts` → 거버넌스 레포만 커밋·푸시. 장황한 에세이·중복 조항·앱 레포에 전문 복붙은 금지

## v1.4 주요 변경

- **긴 대시 금지** (§44): UI 카피·커밋 메시지·문서·채팅 응답·코드 주석에서 en dash(U+2013)·em dash(U+2014)·전각 대시 금지, ASCII 하이픈 `-`만 사용 (범위 표기도 `2020-2024`처럼)

## v1.3 주요 변경

- **alwaysApply 주입**임을 README·mdc에 명시 — 에이전트는 없는 함정을 추측하지 말고 조항을 따름
- **서버 호출 가능 export** (§9.1): 핸들러 모듈의 모든 export = 공개 엔드포인트. 헬퍼·토큰 조회·내부 알림 함수를 같은 파일에서 export 금지. OAuth `provider_token` / 세션 시크릿을 액션 응답으로 반환 금지 (Next `"use server"` 예시)
- **Side-effect mutation** (§13.4): `requireAuth` + actor/owner를 세션과 비교. null이면 **fail closed**
- **SSRF** (§13.3), **XSS/JSON-LD** (§13.5), **IDOR** (§11 보강), 공개 **쓰기 API** rate limit (§13.1)
- **CI completeness** (§24.1): unit/build green ≠ 전체 CI green. E2E skip으로 배지 위장 금지
- Agent NEVER: 범위 밖 리팩터, force push, 푸시된 커밋 amend, `git config --global` 변경

## v1.1 주요 변경

- 프로바이더 **카테고리형** 계정 맵 (GitHub/Supabase/Vercel 고정 → 5개 카테고리)
- 빈 계정 = **미검증, 사용자에게 확인** (플레이스홀더 자동 삽입 제거)
- DB **백업·복구** (§10.1), API **rate limiting·웹훅 검증** (§13.1–13.2)
- **AI·프롬프트 인젝션** 방어 (§15.1), **비용 가드레일** (§41), **모바일/PWA** (§42)
- **가짜 완료 금지** 강화 (§43), **최종 판단 규칙** 확장 (§45)

---

## 포함하지 않는 것

- 제품 기능 요구사항  
- 특정 회사·서비스 브랜드  
- 실제 이메일·시크릿·내부 포트/레포 경로  

원문 전문은 [`GOVERNANCE.md`](GOVERNANCE.md)를 참고하세요.

---

## License

[MIT](LICENSE)

---

## English (short)

**How it is applied:** `engineering-governance.mdc` is **injected** into every Agent chat (`alwaysApply`). It is not a “read before coding” doc. Agents follow **written clauses** — they must not invent framework pitfalls that are not in the rule text.

**Key guidance:**

> The global account-map is a **team default hint**. Enter only accounts you know at install time; leave unknown categories blank. Adjust Supabase, Vercel, etc. per repo when creating or linking projects. For project-specific accounts, add `<repo>/.cursor/rules/account-map.mdc` — it overrides the global map.

1. `./install.sh` — installs rules and **prompts for provider-category emails**  
2. `./install.sh --project` — same, into the current repo  
3. Identity only (no passwords/API keys). Blank field = unverified — agent must ask. Set `SOURCE_CONTROL_ACCOUNT` etc. with `--yes`  
4. Legacy `GITHUB_ACCOUNT` / `SUPABASE_ACCOUNT` / `VERCEL_ACCOUNT` still work  
5. Restart Cursor / new Agent chat  

Full text: [`GOVERNANCE.md`](GOVERNANCE.md). Compact rule: [`.cursor/rules/engineering-governance.mdc`](.cursor/rules/engineering-governance.mdc).
