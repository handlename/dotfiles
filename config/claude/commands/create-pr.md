---
description: 現在のブランチからPull Requestを作成する
argument-hint: [--base-branch=<branch>] [--draft]
allowed-tools: mcp__acp__Bash(git *), mcp__acp__Bash(gh *), mcp__acp__Read
---

## 前提・背景

現在のブランチから指定ベースブランチへのPull Requestを作成せよ。
GitHub CLI (`gh`) を使用し、コミット履歴と変更内容から適切なタイトル・説明文を自動生成せよ。

現在のリポジトリ状態:
```
!git status --short --branch
```

## タスク

以下のタスクを実行せよ。
並行実行可能なタスクは積極的に並行実行せよ。

**フェーズ1（並行実行可能）:**
- 現在のブランチとリポジトリ状態を確認
- README.mdを読み込み、PRで使用する言語を決定
- ベースブランチを決定し、既存PRの有無を確認

**フェーズ2（順次実行）:**
1. リモートへのpush状況を確認し、必要に応じてpush
2. コミット履歴と変更内容を分析
3. PRテンプレート有無を確認し、説明文を生成
4. PRタイトルを生成
5. PR作成内容をユーザーに提示し承認を得る
6. PRを作成し、結果を報告

## オプション

$ARGUMENTS を以下のように分解せよ。

- `--base-branch=<branch>`: PR作成対象のベースブランチ名。未指定時はリポジトリのデフォルトブランチを使用
- `--draft`: 指定時、draft PRとして作成

## 完了条件

以下をすべて満たした時点で完了とする。

- PRが正常に作成され、URLを取得できた
- PR内容（タイトル、説明文要約、変更ファイル数、URL）をユーザーに報告した

## 実行規約

### 使用言語の決定（最重要）

PRのタイトルと説明文で使用する言語は、リポジトリの`README.md`で使われている言語に合わせよ。

- **README.md存在時**: `mcp__acp__Read`で内容を読み込み、使用言語を判定。その言語をPRタイトル・説明文に適用せよ
- **README.md非存在時**: 日本語をデフォルトとして使用せよ

### 事前確認

以下を検証し、PR作成可能性を確認せよ。

```bash
# 現在のブランチ名
CURRENT_BRANCH=$(git branch --show-current)

# ベースブランチの決定（未指定時はデフォルトブランチ）
BASE_BRANCH=${指定値:-$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name')}

# 同一ブランチチェック
[ "$CURRENT_BRANCH" = "$BASE_BRANCH" ] && echo "ERROR: 同一ブランチ"

# 既存PR確認
gh pr list --head "$CURRENT_BRANCH" --base "$BASE_BRANCH" --json url,title
```

- 現在のブランチとベースブランチが異なること
- 同一ブランチペアに既存PRが存在しないこと（存在時はURL提示し中断）
- リモートブランチへのpush状況（unpushedコミット存在時はユーザーに報告し`git push -u origin HEAD`を提案）

### コミット履歴と変更内容の分析

以下のコマンドで情報を収集せよ。

```bash
# コミット履歴（ベースブランチとの差分）
git log "$BASE_BRANCH..HEAD" --oneline --no-decorate

# 変更ファイル統計
git diff --stat "$BASE_BRANCH...HEAD"

# 変更ファイル一覧（詳細）
git diff --name-status "$BASE_BRANCH...HEAD"
```

これらから以下を把握せよ:
- 変更の主目的
- 影響範囲
- Conventional Commits type

### PRテンプレートの確認と説明文生成

`.github/PULL_REQUEST_TEMPLATE.md`の有無を確認せよ。

**テンプレート存在時:**
- テンプレートを読み込み、各セクションにコミット履歴と変更内容から具体的内容を記述
- チェックリスト項目は`[ ]`形式を維持

**テンプレート非存在時:**
以下の構成で説明文を生成せよ。見出しと本文は上記「使用言語の決定」で判定した言語を使用せよ。

```markdown
## 概要
[変更の目的と背景]

## 変更内容
- [主要な変更点]

## 影響範囲
- [影響を受けるコンポーネント/モジュール]

## テスト
- [ ] 関連テストが通過済み

## 備考
[追加の注意事項]
```

### PRタイトルの生成

- コミット数1件: そのコミットメッセージの1行目を使用
- コミット数複数: 最重要のConventional Commits type（feat > fix > refactor > docs > ...）と変更要約から生成
- 50文字以内、末尾ピリオドなし
- **使用言語はREADME.mdの言語に従う**

### 作成内容の確認

PR作成前に以下をユーザーに提示し承認を得よ。

```
=== Pull Request作成確認 ===
タイトル: [タイトル]
ベースブランチ: [ブランチ名]
変更ファイル: [N]件
Draft PR: [Yes/No]

説明文:
---
[説明文]
---

このPRを作成しますか？
```

### PR作成の実行

```bash
gh pr create \
  --title "$TITLE" \
  --body "$BODY" \
  --base "$BASE_BRANCH" \
  $DRAFT_FLAG  # --draftオプション指定時のみ
```

### 作成結果の報告

```
✓ Pull Requestを作成しました

URL: [PR URL]
タイトル: [タイトル]
ベースブランチ: [ブランチ名]
変更ファイル: [N]件

--- 補足 ---
- レビュアー設定: gh pr edit [URL] --add-reviewer [username]
- ラベル追加: gh pr edit [URL] --add-label [label]
```

## 中断条件

以下の条件を満たした場合は作業を中断し、状況と残タスクを報告せよ。

- 現在のブランチとベースブランチが同一
- 既存PRが同一ブランチペアに存在（URLを提示）
- GitHub CLI未インストールまたは認証未完了
- `git push`失敗かつユーザーが再試行を拒否
- ユーザーがPR作成を承認しない
- 同一エラーが3回以上発生し進捗なし

## 禁止事項

- ユーザー確認なしのPR作成を禁ずる
- ファイル内容の推測を禁ずる。参照必要時は必ず`mcp__acp__Read`で読み込め
- PRテンプレート存在時、その構造の無視を禁ずる
- タスクに無関係なファイルの変更を禁ずる

## 補足事項

- タスク実行を妨げる不明瞭さや情報欠損がある場合、ユーザーへ報告し追加情報を求めよ
- コミットメッセージ不十分時、変更内容から適切なタイトル・説明文を推測せよ
- 複数Conventional Commits type混在時、影響最大の変更をタイトルに採用せよ
- `gh`コマンドエラー時、`--help`で正しい使用法を確認してから再実行せよ
