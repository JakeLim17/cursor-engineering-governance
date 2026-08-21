# Cursor Engineering Governance

Cursor용 **글로벌 엔지니어링 거버넌스** 룰 템플릿입니다.  
보안 · 정확성 · 계정 검증 · 시크릿 · 멀티테넌트 · 배포 안전 등 **제품 요구사항이 아닌** 공통 엔지니어링 규칙을 Agent에 주입합니다.

회사명·개인 이메일·내부 프로젝트명은 **모두 플레이스홀더**로 비워 두었습니다. 포크하거나 받은 뒤 `YOUR_*`만 채우면 됩니다.

| 파일 | 역할 |
|------|------|
| [`.cursor/rules/engineering-governance.mdc`](.cursor/rules/engineering-governance.mdc) | Cursor에 바로 넣는 **요약 룰** (`alwaysApply: true`) |
| [`GOVERNANCE.md`](GOVERNANCE.md) | §0–§42 **전문** (읽기·커스터마이즈용) |
| [`templates/account-map.example.mdc`](templates/account-map.example.mdc) | 프로젝트별 계정 맵 예시 |
| [`install.sh`](install.sh) | 한 줄 설치 스크립트 |

---

## 적용 방법 (권장 순서)

### A. 유저 전역 (모든 프로젝트에 적용)

모든 Cursor 작업에 공통으로 걸립니다.

```bash
git clone https://github.com/JakeLim17/cursor-engineering-governance.git
cd cursor-engineering-governance
chmod +x install.sh
./install.sh
```

설치 위치: `~/.cursor/rules/engineering-governance.mdc`

### B. 프로젝트만 (해당 레포에만 적용)

```bash
# 적용할 프로젝트 루트에서
curl -fsSL https://raw.githubusercontent.com/JakeLim17/cursor-engineering-governance/main/install.sh -o /tmp/ceg-install.sh
# 또는 clone 후:
# /path/to/cursor-engineering-governance/install.sh --project
```

클론한 폴더에서:

```bash
cd /path/to/your-app
/path/to/cursor-engineering-governance/install.sh --project
```

설치 위치:

- `your-app/.cursor/rules/engineering-governance.mdc`
- `your-app/.cursor/rules/account-map.mdc` (없으면 생성 → `YOUR_*` 수정)

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

## 설치 후 꼭 할 일

1. **계정 맵 채우기** (이메일·계정 ID만, 비밀번호/키는 넣지 말 것)

```text
GitHub:    YOUR_GITHUB_ACCOUNT_OR_EMAIL
Supabase:  YOUR_SUPABASE_ACCOUNT_OR_EMAIL
Vercel:    YOUR_VERCEL_ACCOUNT_OR_EMAIL
```

- 팀 공통 기본값 → `GOVERNANCE.md` §6 또는 전역 룰 옆 메모  
- 프로젝트마다 다르면 → **프로젝트** `account-map.mdc`만 수정 (글로벌 룰은 건드리지 않기)

2. **검증**: 새 Agent 채팅에서  
   > “지금 적용 중인 글로벌 엔지니어링 거버넌스 우선순위가 뭐야?”  
   라고 물어보고, Security > Correctness … 순서가 나오면 적용된 것입니다.

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

1. `./install.sh` → user-global `~/.cursor/rules/`  
2. `./install.sh --project` → current repo `.cursor/rules/` + account-map template  
3. Fill `YOUR_*` placeholders (identity only, no secrets)  
4. Restart Cursor / new Agent chat  

Full text: [`GOVERNANCE.md`](GOVERNANCE.md). Compact always-on rule: [`.cursor/rules/engineering-governance.mdc`](.cursor/rules/engineering-governance.mdc).
