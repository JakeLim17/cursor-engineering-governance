# Cursor Engineering Governance

Cursor용 **글로벌 엔지니어링 거버넌스** 룰 템플릿입니다.  
보안 · 정확성 · 계정 검증 · 시크릿 · 멀티테넌트 · 배포 안전 등 **제품 요구사항이 아닌** 공통 엔지니어링 규칙을 Agent에 주입합니다.

회사명·개인 이메일·내부 프로젝트명은 **플레이스홀더**입니다.  
`./install.sh` 실행 시 **GitHub / Supabase / Vercel 계정(이메일)** 을 물어보고 `account-map.mdc`에 저장합니다. (비밀번호·API 키는 절대 입력하지 마세요.)

| 파일 | 역할 |
|------|------|
| [`.cursor/rules/engineering-governance.mdc`](.cursor/rules/engineering-governance.mdc) | Cursor에 바로 넣는 **요약 룰** (`alwaysApply: true`) |
| [`GOVERNANCE.md`](GOVERNANCE.md) | §0–§42 **전문** (읽기·커스터마이즈용) |
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
GitHub account/email: you@example.com
Supabase account/email: you@example.com
Vercel account/email: you@example.com
```

설치 위치:

- `~/.cursor/rules/engineering-governance.mdc`
- `~/.cursor/rules/account-map.mdc` ← 입력한 메일/계정

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
3. (선택) `templates/account-map.example.mdc`를 복사해 `YOUR_*` 채우기  
4. Cursor를 다시 열거나 **새 Agent 채팅**을 시작

### D. Cursor Settings UI

1. Cursor → **Settings** → **Rules** (또는 Project Rules)  
2. **Add Rule** / 파일 추가  
3. 이 레포의 `.mdc`를 붙이거나 Import  

UI 메뉴명은 Cursor 버전에 따라 조금 다를 수 있습니다. 파일이 `~/.cursor/rules/` 또는 프로젝트 `.cursor/rules/`에 있으면 Agent가 읽습니다.

---

## 설치 옵션

| 옵션 / 환경변수 | 의미 |
|-----------------|------|
| (기본) | 대화형으로 계정 3개 입력 |
| `--project` | 현재 폴더 `.cursor/rules`에 설치 |
| `--skip-accounts` | 룰만 설치, 계정 질문 생략 |
| `--yes` | 질문 없이 env/플레이스홀더로 기록 (CI용) |
| `GITHUB_ACCOUNT` / `SUPABASE_ACCOUNT` / `VERCEL_ACCOUNT` | 비대화형 값 |

예 (스크립트):

```bash
GITHUB_ACCOUNT=dev@example.com \
SUPABASE_ACCOUNT=dev@example.com \
VERCEL_ACCOUNT=dev@example.com \
./install.sh --yes
```

나중에 바꾸려면 `account-map.mdc`를 직접 수정하거나, 설치를 다시 실행하면 됩니다.

## 설치 후 검증

새 Agent 채팅에서:

> “account-map에 등록된 GitHub / Supabase / Vercel 계정이 뭐야?”

입력한 값이 나오면 적용된 것입니다.

---

## 레포 전용 룰과의 관계

```text
플랫폼/시스템 > 보안 > 프로젝트 AGENTS.md / .cursor/rules > 이 글로벌 룰 > 일반 선호
```

이미 프로젝트에 상세 하네스가 있으면 **그대로 두고**, 이 룰은 공통 안전망으로만 쓰면 됩니다.

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

1. `./install.sh` — installs rules and **prompts for GitHub / Supabase / Vercel emails**  
2. `./install.sh --project` — same, into the current repo  
3. Identity only (no passwords/API keys). Or set `GITHUB_ACCOUNT` etc. with `--yes`  
4. Restart Cursor / new Agent chat  

Full text: [`GOVERNANCE.md`](GOVERNANCE.md). Compact rule: [`.cursor/rules/engineering-governance.mdc`](.cursor/rules/engineering-governance.mdc).
