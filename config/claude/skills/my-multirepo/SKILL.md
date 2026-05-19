---
name: multirepo
description: メッセージ中に `multirepo: <repo1>, <repo2>, ...` 宣言が含まれた時点で発火する複数リポジトリ調査・編集 skill。各 repo に専用 sub-agent (multirepo-worker) を並列で割り当て、メインセッションは指示と結果集約のみを担う。worktree は edit 時のみ作成、コミット/PR は別 skill に委ねる。
argument-hint: "<repo1>, <repo2>, ... <指示>"
---

# multirepo

ローカルに clone 済みの複数 git リポジトリに対し、調査または編集を**並列に**実行する skill。

メインセッションは orchestrator として動作する。実コードには触れず、各リポジトリへの作業を専用 sub-agent (`multirepo-worker`) に委譲し、進捗表示と結果集約のみを担う。

## 起動条件

メッセージ中に次の宣言が含まれていれば、文中の任意の位置で発火する:

```
multirepo: <repo-path1>, <repo-path2>, ...
```

例:
- `multirepo: ~/src/foo, ~/src/bar 認証ライブラリの利用箇所を調査して`
- `先に状況を整理して。そのあと multirepo: ~/src/a, ~/src/b で v2 に移行`

宣言以降そのセッションは **multi-repo モード**となる。新たな `multirepo: ...` 宣言で repo セットは上書きされる。明示的な解除キーワードは設けない（セッション終了で消滅）。

magic keyword の検出はモデル推論依存のため、確実に発火させたい場合は `/multirepo` でも明示起動できる。

## Phase 1: keyword 検出と repo リスト解析

メッセージから `multirepo:` 宣言を抽出し、続くカンマ区切りトークンを repo パスとして解析する。

- 絶対パスのみを受け付ける（チルダ展開は許容）
- 相対パスや空文字は invalid として弾く
- パースした repo リストはセッションスコープで保持

## Phase 2: タスク種別判定 (investigate vs edit)

同じメッセージ内の自然言語指示から判定する:

- **investigate** (read-only): 「調査」「確認」「報告」「探す」「分析」など → worktree を作らない
- **edit**: 「修正」「更新」「適用」「変更」「リファクタ」「移行」など書き込みを伴う動詞 → worktree を作る

判別不能なら **investigate** として扱い、worktree を作成しない（安全側 = 不要な worktree／ブランチを作らない）。

## Phase 3: リポジトリ事前検証

各 repo について順にチェックする:

1. パス存在: `test -d <repo>`
2. git リポジトリ: `git -C <repo> rev-parse --git-dir`
3. (edit のみ) working tree が clean: `git -C <repo> status --porcelain` が空

検証に失敗した repo は V-table に `failed` + 原因を表示し、**dispatch 対象から除外**する。残りの repo はそのまま並列起動する。**全 repo が検証失敗** の場合のみタスク全体を中止する。

## Phase 4: Slug 衝突チェックと worktree 準備

### Slug 生成

orchestrator はユーザー指示から英語の主要キーワードを 1〜3 語抽出し（指示が日本語なら和訳または要約して英語キーワード化）、kebab-case にして日時 suffix を付与する:

```bash
# 例: task_summary="auth client v2 migration"
slug="$(printf %s "$task_summary" | tr 'A-Z' 'a-z' | tr -cs 'a-z0-9' '-' | sed 's/^-//;s/-$//' | cut -c1-30)"
slug="${slug:-task}-$(date +%Y%m%d-%H%M%S)"
branch="multirepo/${slug}"
```

> ユーザー指示が日本語など非 ASCII の場合、上記 bash パイプラインでは空になるため、orchestrator は **先にモデル推論で英語キーワードへ変換**（例: `認証ライブラリの利用箇所を調査` → `auth-usage-audit`）してから適用する。

orchestrator は dispatch 前に各 repo で `git -C <repo> --no-pager branch --list <branch>` を確認し、衝突があれば末尾に `-2`, `-3` を付与する。

### Worktree 作成（edit のみ）

```bash
git -C "$repo" worktree add ".git/worktrees/multirepo-${slug}" -b "$branch"
```

- 作業ディレクトリ: `<repo>/.git/worktrees/multirepo-<slug>`（spec L41、git により許可される）
- ブランチ: `multirepo/<slug>`

investigate では worktree を作らず、現在ブランチで読み取りのみ行う。

## Phase 5: Sub-agent dispatch

各 repo に対し `multirepo-worker` を Agent ツールで並列起動する。

dispatch の prompt は本 skill 同梱の `agents/multirepo-worker.md` を読み込み、以下のコンテキスト変数を置換して構成する:

| 変数 | 内容 |
|------|------|
| `<TARGET_REPO>` | リポジトリ絶対パス |
| `<WORKING_DIR>` | investigate なら repo パス、edit なら worktree パス |
| `<TASK_KIND>` | `investigate` / `edit` |
| `<USER_INSTRUCTION>` | ユーザー指示（`multirepo: ...` 宣言を除いた本文） |
| `<BRANCH>` | edit のみ、`multirepo/<slug>` |

`subagent_type="general-purpose"` を使用する。

並列度は既定で repo 数（全並列）。orchestrator はユーザー指示中の以下の手がかりで並列度を調整する:

- 「順番に」「1 つずつ」「sequentially」 → 並列度 **1**（順次実行）
- 「N 個ずつ」「並列 N で」 → バッチサイズ **N**
- 依存関係を示唆する語（「先に X、その後 Y」） → 依存順に逐次 dispatch
- 上記の指定が無い場合 → 全並列

repo 数が極端に多い（例: 10+）場合は、Agent ツールの並列起動上限に応じてバッチ分割を行ってよい（バッチ間は順次実行）。

> **重要**: メインセッションは sub-agent への dispatch・進捗表示・結果集約のみを担当する。ファイル編集、git コマンド実行などの実作業は **すべて sub-agent 側**で行う。

## Phase 6: 進捗監視 (V-table)

各 sub-agent の起動・完了に応じてメインセッションは進捗テーブルを更新表示する:

```
| Repo       | Status   | Branch                              | Summary             |
|------------|----------|-------------------------------------|---------------------|
| ~/src/foo  | done     | multirepo/auth-v2-20260507-163000   | 3 箇所更新          |
| ~/src/bar  | running  | multirepo/auth-v2-20260507-163000   | (実行中)            |
| ~/src/baz  | pending  | -                                   | -                   |
```

ステータス値: `pending` / `running` / `done` / `failed` / `cancelled`

更新タイミング:
- dispatch 直前: 全 repo を `pending`
- 起動完了: `running`
- sub-agent 完了: `done` または `failed`
- F-fast 発動時の未完了: `cancelled`

## Phase 7: F-fast (失敗時の即時中断)

いずれかの sub-agent が `failed` を返した時点で:

1. その repo を `failed` に更新
2. 未起動の dispatch をキャンセル
3. 起動中の sub-agent には TaskStop でソフト中断を試みる（best-effort）
4. 失敗原因と既完了 repo の状況を即時表示

> **既知の制約**: Agent ツールで起動した sub-agent の即時キャンセルは Claude Code 側の制約により best-effort で、実行中の sub-agent は完走する場合がある。spec の F-fast 要件は「未起動分は確実に止める／実行中は best-effort で中断」と運用解釈する。

S-all 仕様により、1 件でも `failed` があれば全体として失敗扱い。

## Phase 8: 完了報告 (S-all)

### 全 sub-agent 成功時

```
✓ multirepo: 全 N リポジトリで作業完了

| Repo       | Status | Branch                              | Summary             |
|------------|--------|-------------------------------------|---------------------|
| ~/src/foo  | done   | multirepo/auth-v2-20260507-163000   | 3 箇所更新          |
| ~/src/bar  | done   | multirepo/auth-v2-20260507-163000   | 2 箇所更新          |

各 worktree に diff が残っています。コミット・PR 作成は別 skill (`github-resource-access` 等)
で実行してください。
```

### 1 件以上失敗時

```
✗ multirepo: 失敗 (S-all 不成立)

| Repo       | Status    | Branch                | Summary             |
|------------|-----------|-----------------------|---------------------|
| ~/src/foo  | done      | multirepo/...         | 完了                |
| ~/src/bar  | failed    | multirepo/...         | (エラー要因)        |
| ~/src/baz  | cancelled | -                     | F-fast によりキャンセル |

部分完了は成功ではありません。次のいずれかを選択してください:
- 失敗原因を修正して再実行
- 完了済み repo の worktree 変更を破棄
- そのまま手動レビュー
```

## スコープ外

| 項目 | 委譲先 / 備考 |
|------|--------------|
| コミット作成・push・PR 作成 | `github-resource-access` 等の別 skill |
| GitHub Issue 同期 | 別 skill |
| agent teams | 採用しない（本 skill は 1 repo = 1 sub-agent） |
| 解除キーワード | 不要（再宣言で上書き、セッション終了で消滅） |
| リモート repo の自動 clone | 前提（ローカル clone 済み） |
| 言語/フレームワーク別の sub-agent 出し分け | 採用しない（全 repo 共通の `multirepo-worker`） |

## トラブルシューティング

| 症状 | 原因と対処 |
|------|-----------|
| skill が発火しない | description ベースの自動検出はモデル推論依存。`multirepo:` を文頭に置くと発火率が上がる |
| 蓄積した worktree | 自動削除しない。`git worktree prune` および `git worktree remove <path>` で整理 |
| dirty working tree でエラー | edit 前に commit / stash すること（自動 stash はしない） |
| sub-agent がキャンセルできない | 既知の制約。F-fast はソフト中断（best-effort） |

## Sub-agent 指示テンプレート

dispatch に使うプロンプトは `agents/multirepo-worker.md` を参照。orchestrator が当該ファイルを読み、コンテキスト変数を埋めて Agent ツールの prompt として渡す。
