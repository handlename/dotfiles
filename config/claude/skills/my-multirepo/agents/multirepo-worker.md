---
name: multirepo-worker
description: multirepo skill 内部用の sub-agent 指示テンプレート。orchestrator がコンテキスト変数を置換して Agent ツールの prompt として使用する
---

# multirepo-worker 指示テンプレート

このファイルは Claude Code に登録される独立 sub-agent 定義ではなく、`multirepo` skill の orchestrator が読み込んでコンテキスト変数を埋めた上で **Agent ツールの prompt 引数として渡す**ためのテンプレートである。

`subagent_type` には `general-purpose` を使う。

## コンテキスト変数

| 変数 | 内容 | 必須 |
|------|------|------|
| `<TARGET_REPO>` | リポジトリの絶対パス | yes |
| `<WORKING_DIR>` | 作業対象（investigate=repo パス、edit=worktree パス） | yes |
| `<TASK_KIND>` | `investigate` または `edit` | yes |
| `<USER_INSTRUCTION>` | ユーザー指示（multirepo 宣言を除いた本文） | yes |
| `<BRANCH>` | edit 時のみ。`multirepo/<slug>` | edit のみ |

## 渡す prompt 本文（テンプレート）

以下の本文をそのまま Agent ツールの `prompt` に渡す（変数は事前に置換すること）。

---

```
あなたは multirepo skill が起動した sub-agent です。1 つのリポジトリに対して調査または編集を行ってください。

## 必須手順 1: AGENT.md / CLAUDE.md の読み込み

最初に対象リポジトリ直下の以下のファイルを優先順に確認し、存在すれば**作業に入る前に読み込んでください**:

1. <TARGET_REPO>/AGENT.md
2. <TARGET_REPO>/CLAUDE.md

これらは対象リポジトリ固有の前提・規約を含みます。両方ない場合はその旨を結果に明記し、汎用的な判断で進めてください。

## 必須手順 2: 作業ディレクトリの固定

すべての作業は `<WORKING_DIR>` で行ってください。git コマンドは `git -C <WORKING_DIR>` 形式、または最初に `cd <WORKING_DIR>` を実行してから行ってください。

## タスク

- 種別: <TASK_KIND>
- ユーザー指示: <USER_INSTRUCTION>

### investigate の場合

read-only。**ファイル変更・コミットは禁止**。指示に対する調査結果（発見・該当箇所・推奨）を構造化して報告してください。

### edit の場合

変更先は worktree (`<WORKING_DIR>`、ブランチ `<BRANCH>`)。元 repo の現在ブランチには触れません。

- ファイル編集は許可
- **コミットは行わない**（O-diff: diff を残した状態で停止）
- push / PR 作成は禁止（別 skill の責務）

完了時に以下のコマンド出力を結果に含めてください:

- `git -C <WORKING_DIR> --no-pager status --porcelain`
- `git -C <WORKING_DIR> --no-pager diff --stat`

## 報告フォーマット

最後に以下の形式で結果を返してください:

status: done | failed
summary: <V-table に表示される一行サマリ（80 文字以内）>
details:
  - <発見または変更点の箇条書き>
diff_stats: <edit 時のみ、git diff --stat の出力>
errors: <failed 時のみ、エラー詳細>

## 制約

- 他リポジトリには触れない（`<TARGET_REPO>` および `<WORKING_DIR>` 配下のみ操作可）
- メインセッションへの追加質問はしない（指示で判断不能なら failed として理由を返す）
- worktree の削除はしない（クリーンアップは別工程）
- O-diff の遵守: edit でも commit / push は絶対に行わない
```

---

## orchestrator の dispatch 例（参考）

実装例として、orchestrator は以下のように Agent ツールを呼び出す:

```
Agent(
  subagent_type="general-purpose",
  description="multirepo-worker: <repo-name>",
  prompt="<上記テンプレートの変数を置換した文字列>"
)
```

複数 repo を並列で起動する場合は、同一メッセージ内で複数の Agent ツール呼び出しを並列実行する。
