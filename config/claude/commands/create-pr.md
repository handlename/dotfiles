---
description: 現在のブランチからPull Requestを作成する
argument-hint: [--base-branch=<branch>] [--draft]
allowed-tools: mcp__acp__Bash(git *), mcp__acp__Bash(gh *), mcp__acp__Read
---

## 前提・背景

現在のブランチから指定ベースブランチへのPull Requestを作成する。
GitHub CLI (`gh`) を使用し、コミット履歴と変更内容から適切なタイトル・説明文を自動生成せよ。

現在のリポジトリ状態:
```
!git status --short --branch
```

## タスク

以下のタスクを順次実行せよ。
各タスクは完了後、次タスクへ進む前に結果を検証せよ。

1. 現在のブランチとリポジトリ状態を確認
2. ベースブランチを決定
3. リモートへのpush状況を確認し、必要に応じて対処
4. コミット履歴と変更内容を分析
5. PRテンプレート有無を確認し、説明文を生成
6. PRタイトルを生成
7. PR作成内容をユーザーに提示し承認を得る
8. PRを作成し、結果を報告

## オプション

$ARGUMENTS を以下のように分解せよ。

- `--base-branch=<branch>`: PR作成対象のベースブランチ名。未指定時はリポジトリのデフォルトブランチを使用
- `--draft`: 指定時、draft PRとして作成

## 完了条件

以下をすべて満たした時点で完了とする。

- PRが正常に作成され、URLを取得できた
- PR内容(タイトル、説明文要約、変更ファイル数、URL)をユーザーに報告した

## 実行規約

### 1. 事前確認

以下を実行し、PR作成可能性を検証せよ。

```bash
# 現在のブランチ名
CURRENT_BRANCH=$(git branch --show-current)

# ベースブランチの決定
BASE_BRANCH=${1:-$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name')}

# 同一ブランチチェック
if [ "$CURRENT_BRANCH" = "$BASE_BRANCH" ]; then
  echo "ERROR: 現在のブランチとベースブランチが同一"
  exit 1
fi

# リモート追跡状況
git status --porcelain --branch | grep '##'
```

**リモートブランチ未存在またはunpushedコミット存在時:**
- 状況をユーザーに報告
- pushの実行を提案し、承認後に `git push -u origin HEAD` を実行

**既存PR確認:**
```bash
gh pr list --head "$CURRENT_BRANCH" --base "$BASE_BRANCH" --json url,title
```
既存PRが存在する場合、URLを提示し中断せよ。

### 2. コミット履歴と変更内容の分析

```bash
# コミット履歴(ベースブランチとの差分)
git log "$BASE_BRANCH..HEAD" --oneline --no-decorate

# 変更ファイル統計
git diff --stat "$BASE_BRANCH...HEAD"

# 変更ファイル一覧(詳細)
git diff --name-status "$BASE_BRANCH...HEAD"
```

これらの情報から:
- 変更の主目的を特定
- 影響範囲を把握
- Conventional Commits typeを判断

### 3. 使用言語の決定

PRのタイトルと説明文で使用する言語は、リポジトリの `README.md` で使われている言語に合わせよ。

```bash
# README.mdの存在確認と内容取得
README_PATH="README.md"
test -f "$README_PATH" && echo "exists" || echo "not_found"
```

**README.md存在時:**
- `mcp__acp__Read` で内容を読み込み、使用言語を判定
- 判定した言語をPRタイトル・説明文の記述に適用

**README.md非存在時:**
- 日本語をデフォルトとして使用

### 4. PRテンプレートの確認と説明文生成

```bash
TEMPLATE_PATH=".github/PULL_REQUEST_TEMPLATE.md"
test -f "$TEMPLATE_PATH" && echo "exists" || echo "not_found"
```

**テンプレート存在時:**
- テンプレートを読み込み(`mcp__acp__Read`)
- 各セクションに対し、コミット履歴と変更内容から具体的内容を記述
- チェックリスト項目は `[ ]` 形式を維持

**テンプレート非存在時:**
以下の構成で説明文を生成:

```markdown
## 概要
[変更の目的と背景をコミットメッセージから推測して記述]

## 変更内容
- [主要な変更点1: 変更ファイルとコミットから抽出]
- [主要な変更点2]
- [...]

## 影響範囲
- [影響を受けるコンポーネント/モジュール]
- [変更されたファイル数と主要ファイル]

## テスト
- [ ] 関連テストが通過済み
- [ ] 新規テストを追加(該当する場合)

## 備考
[追加の注意事項や依存関係があれば記述]
```

### 5. PRタイトルの生成

以下のロジックでタイトルを生成せよ。

```
コミット数 == 1:
  タイトル = そのコミットメッセージの1行目
コミット数 > 1:
  1. 全コミットのConventional Commits typeを集計
  2. 最頻出または最重要(feat > fix > refactor > docs > ...)のtypeを選択
  3. 変更内容を要約(例: "複数の認証機能改善")
  タイトル = "{type}: {要約}"
```

- 50文字以内に収める
- 末尾にピリオドを付けない

### 6. 作成内容の確認

PR作成前に、以下をユーザーに提示し承認を得よ。

```
=== Pull Request作成確認 ===

タイトル: [生成したタイトル]

ベースブランチ: [ベースブランチ名]
変更ファイル: [N]件

説明文:
---
[生成した説明文の全文または最初の200文字 + "..."]
---

Draft PR: [Yes/No]

このPRを作成しますか？
```

承認時のみ次ステップへ進め。

### 7. PR作成の実行

```bash
TITLE="[生成したタイトル]"
BODY="[生成した説明文]"
BASE="[ベースブランチ]"
DRAFT_FLAG=""
[[ "$DRAFT" == "true" ]] && DRAFT_FLAG="--draft"

gh pr create \
  --title "$TITLE" \
  --body "$BODY" \
  --base "$BASE" \
  $DRAFT_FLAG
```

実行結果のURLを変数に保存せよ。

### 8. 作成結果の報告

以下の形式で報告せよ。

```
✓ Pull Requestを作成しました

URL: [PR URL]
タイトル: [タイトル]
ベースブランチ: [ベースブランチ]
変更ファイル: [N]件
Draft: [Yes/No]

説明文(要約):
[最初の200文字程度]

--- 補足 ---
- レビュアー設定: gh pr edit [PR_URL] --add-reviewer [username]
- ラベル追加: gh pr edit [PR_URL] --add-label [label]
```

## 中断条件

以下の条件満了時、作業を中断し状況と残タスクを報告せよ。

- 現在のブランチとベースブランチが同一
- 既存PRが同一ブランチペアに存在(既存PRのURLを提示)
- GitHub CLI未インストールまたは認証未完了(インストール・認証方法を案内)
- `git push`が失敗し、ユーザーが再試行を拒否
- ユーザーが作成内容確認時に承認を拒否
- 同一エラーが3回以上発生し進捗なし

## 禁止事項

- タスクに無関係なファイルの変更を禁ずる
- ユーザー確認なしのPR作成を禁ずる
- ファイル内容の推測を禁ずる。参照必要時は必ず `mcp__acp__Read` で読み込め
- PRテンプレート存在時、その構造の無視を禁ずる
- 提案のみで実行しないことを禁ずる。すべてのタスクを完遂せよ
- 冗長なコメントを禁ずる。コードに明白な処理にコメント不要

## 補足事項

- タスク実行を妨げる不明瞭さや情報欠損がある場合、ユーザーへ報告し追加情報を求めよ
- CLAUDE.mdに従い、PR作成前に関連テストの通過が推奨される
- コミットメッセージ不十分時、変更内容から適切なタイトル・説明文を推測せよ
- 複数Conventional Commits type混在時、影響最大の変更をタイトルに採用せよ
- `gh` コマンドエラー時、`--help` で正しい使用法を確認してから再実行せよ
