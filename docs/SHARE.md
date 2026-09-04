# 팀 전파 절차 (Share / Propagate)

<!-- 설치·공유 도구 문서 — GOVERNANCE.md 조항 버전과 별도 트랙, 2026-09-04 -->


이 문서는 **다른 개발자 머신에 ChronoCode Cursor 설정(거버넌스 룰 + 모델 라우팅 MCP)을 그대로 심는 방법**의 SSOT다. 두 레포가 짝을 이룬다:

| 레포 | 역할 | 설치 대상 |
|------|------|-----------|
| [`cursor-engineering-governance`](https://github.com/JakeLim17/cursor-engineering-governance) (이 레포) | 보안·정확성·계정 검증 등 **엔지니어링 규칙** — `alwaysApply: true`로 매 Agent 채팅에 자동 주입 | `~/.cursor/rules/engineering-governance.mdc` (+ `account-map.mdc`) |
| [`compass-mcp`](https://github.com/JakeLim17/compass-mcp) | 작업 문장을 보고 **모델(Task slug)을 추천**하는 로컬 MCP | Cursor/Claude/Codex MCP 설정(`mcp.json` 등) |

둘 다 **로컬 개발자 머신**에 설치되는 것이며, GitHub Actions 같은 CI 파이프라인이 아니다.

---

## A. 새 머신 / 한 번도 클론 안 한 팀원 — 원커맨드

```bash
# 1) 거버넌스 룰 (알아서 클론 → 설치, 계정은 대화형으로 물어봄)
curl -fsSL https://raw.githubusercontent.com/JakeLim17/cursor-engineering-governance/main/install.sh \
  | bash -s -- --from-remote

# 2) compass-mcp (모델 추천 MCP, cursor|claude|codex 중 선택)
curl -fsSL https://raw.githubusercontent.com/JakeLim17/compass-mcp/main/scripts/remote-install.sh \
  | bash -s -- cursor

# 3) Cursor에서 MCP 재연결
#    Customize → MCPs → compass-mcp OFF → ON (또는 Cursor 재시작)
```

- 1번은 계정 맵(GitHub/Vercel/Supabase 등 이메일)을 물어본다. 모르면 그냥 Enter(빈 칸 = 미검증으로 남고, 나중에 Agent가 사용 전 확인).
- CI/스크립트로 무인 설치하려면 `--from-remote --yes` + `SOURCE_CONTROL_ACCOUNT=...` 등 env (README §설치 옵션 참고).
- 프로젝트 전용으로만 설치하려면 `--from-remote --project` (현재 폴더 `.cursor/rules`에만 적용).

## B. 이미 두 레포 다 클론해 둔 팀원 — 업데이트만

```bash
cd cursor-engineering-governance && git pull --ff-only && ./install.sh --skip-accounts
cd ../compass-mcp && npm run sync
# 그 다음: Customize → MCPs → compass-mcp OFF/ON
```

- `install.sh --skip-accounts`는 룰 파일만 덮어쓰고 `account-map.mdc`(이미 입력한 계정)는 그대로 둔다.
- `npm run sync`는 compass-mcp에서 `git pull` → `npm install` → `npm run build` → smoke test까지 한 번에 돈다.

## C. 설치 확인

새 Agent 채팅에서:

> "account-map에 등록된 Source control / Hosting / Database 계정이 뭐야?"

값이 나오면 거버넌스 룰 적용됨. compass-mcp는:

> "지금 이 작업에 어떤 모델이 맞아?"

라고 물어서 추천이 나오면(또는 에이전트가 `start_session`/`recommend_model`을 호출하면) 연결됨.

---

## 이 저장소만 (거버넌스 단독)

compass-mcp 없이 거버넌스 룰만 필요하면 [README.md](../README.md) §적용 방법을 그대로 따르면 된다 (A: 유저 전역 / B: 프로젝트만 / C: 수동 복사 / D: Cursor Settings UI).

---

## 검토한 자동화 옵션 (우선순위)

실제 구현한 것 위주로 정리 — 새로 자동화를 고민하는 사람을 위한 참고:

1. **`install.sh --from-remote` / `remote-install.sh` (구현됨, 이 문서 §A)** — 클론을 스크립트가 대신 해주는 `curl | bash` 원커맨드. 로컬 dotfiles류 도구와 동일한 패턴, 추가 인프라 없음, 오프라인/사설 미러로도 `*_REPO_URL` env만 바꾸면 재사용 가능. **팀 배포 첫 단계로 권장.**
2. **모노레포/각 앱에 git submodule로 심기** — 앱 저장소 자체에 룰을 고정(핀)하고 싶을 때만 고려. 서브모듈은 팀원 전원이 `git submodule update`를 기억해야 해서 실제로는 자주 stale — 개인 dotfiles류(사람에 귀속) 성격의 룰에는 과함. **비권장** (앱별로 룰이 갈릴 필요가 없는 한).
3. **Cursor Team Rules / Hooks로 pull 시 자동 sync** — Cursor가 팀 단위 룰 배포 기능이나 `git pull` 훅으로 자동 재설치를 지원하면 가장 매끈하지만, 이 레포가 대상으로 하는 “유저 전역 `~/.cursor/rules`”와는 스코프가 다르고(팀/프로젝트 룰은 이미 리포별 `.cursor/rules`로 커밋됨), 개인 계정 프롬프트(account-map)가 있어 완전 자동화는 부적합. **보류 — 기능이 성숙하면 재검토.**
4. **GitHub Action으로 자동 배포** — 대상이 아님. 이 레포는 **로컬 개발자 머신**의 Cursor/Claude/Codex 설정을 채우는 것이 목적이라 CI 파이프라인이 실행할 서버 자원이 없다. (CI에서 쓸 일이 있다면 `--yes` + env로 무인 설치는 되지만, 그건 "배포"가 아니라 "머신 셋업"이다.)

**결론:** 1번(원커맨드 스크립트)이 인프라 비용 0으로 실제 팀 전파 문제를 해결한다. 2·3번은 지금 규모에서 이득보다 유지비가 크고, 4번은 애초에 대상이 다르다.
