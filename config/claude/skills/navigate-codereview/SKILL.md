---
name: navigate-codereview
description: ユーザー主導のPRコードレビューをナビゲートするスキル。処理フロー順にコードを案内し、1箇所ずつエディタで開きながらアドバイスを提供し、最終的にインラインコメントをPRに投稿する。
argument-hint: "<PR URL>"
disable-model-invocation: true
---

ユーザーが PR のコードレビューを行う際に、コードの読み順を案内し、各箇所で解説・アドバイスを行い、最後に pending review として指摘を投稿する。
**レビュー主体はユーザー**であり、Claude Code はナビゲーション・解説・アドバイスに徹する。Claude 主体の自動レビューが目的なら `codereview` スキルを使う。

スクリプトはこのスキル同梱の `scripts/` 以下にある。SKILL.md はフローと判断基準に集中し、実装詳細はスクリプトに寄せる。

引数: $ARGUMENTS (PR URL)

## Phase 1: PR 情報取得

PR URL から `OWNER`, `REPO`, `NUMBER` を抽出し:

```bash
gh pr view NUMBER --repo OWNER/REPO --json title,body,files,additions,deletions,baseRefName,headRefName
gh pr diff NUMBER --repo OWNER/REPO
```

`baseRefName` / `headRefName` は以降のフェーズで使う。

## Phase 2: ブランチ切り替え

1. `git status` で未コミット変更を確認。ある場合は続行可否をユーザーに確認
2. base ブランチを最新化: `git fetch origin <baseRefName>`
   （古い base のまま diff を取ると base にマージ済みコミットが混入し誤指摘になる）
3. `git fetch origin <headRefName> && git checkout <headRefName>`

## Phase 3: 処理順の決定・アウトライン提示

変更ファイルを処理フロー順に並べてアウトラインを提示する。

### 垂直スライスグルーピング

複数の独立した機能・修正を含む PR ではまず機能単位にグルーピングする。手がかり:

- 共通する命名パターン（例: `tesla_*.go`）
- import チェーン（`internal/X` を import する `models/`, `services/`, `routes/` のファイル群）
- PR description の機能区分

スライス間は依存関係順（被依存スライスを先）、各スライス内はレイヤー順。単一機能の PR ならグルーピング不要。

### レイヤー順序

データフロー上流から下流へ:

| 優先度 | ディレクトリ | 役割 |
|---|---|---|
| 1 | `db/migrations/` | スキーマ変更（後続の理解の基盤） |
| 2 | `internal/` | インフラ・外部連携。`models/`/`services/`/`routes/` から依存される |
| 3 | `models/` | データアクセス |
| 4 | `services/` | ビジネスロジック |
| 5 | `routes/` | HTTP ハンドラー |
| 6 | `middlewares/` | ミドルウェア |
| 7 | `cmd/`, `nature-cli/` | エントリーポイント |
| 8 | `templates/`, 静的アセット | UI |
| 9 | `l10n/`, `db/onetime/`, `.github/`, `Makefile` 等 | 設定・その他 |

### 補足ルール

- **同一レイヤー内**: import・関数呼び出しの被依存側を先に
- **テストファイル**: 対応する実装ファイルの直後（`foo.go` → `foo_test.go`）。テストヘルパー・フィクスチャはテストファイルの直前
- **削除ファイル**: diff のみ表示し、エディタでは開かない
- **バイナリ・生成ファイル** (CSS, `db/create.sql` 等): 存在のみ報告し行単位ナビは省略
- **レイヤー外のみの PR**: アルファベット順にフォールバック
- **分岐**: 読み順に実質的な差がない場合のみ番号付き選択肢を提示。順序が明確なら自動で進める

### アウトライン形式

```
## レビューアウトライン

変更ファイル: N 件

### Slice 1: [機能名]
1. internal/tesla/oauth2.go (L41-L87) -- OAuth2 クライアントの nonce 検証追加
2. internal/tesla/oauth2_test.go (L23-L165) -- テスト
3. services/tesla/oauth2.go (L36-L117) -- ビジネスロジック
4. routes/teslaauth/teslaauth.go (L1-L99) -- ハンドラー（新規）
5. routes/routes.go (L337-L339, L1710) -- エンドポイント登録

### その他
6. models/template.go (L160-L170) -- エラーテンプレートヘルパー追加
7. l10n/active.ja.json, l10n/active.en.json -- i18n 文字列追加
```

## Phase 4: ナビゲーションループ

アウトラインに沿って1箇所ずつナビゲートする。**ユーザーの指示があるまで次へ進まない**（解説直後にユーザーが追加の質問や観察をしたい可能性があるため、次のファイルの diff / エディタ起動を勝手に実行しない）。「次に進んでよろしいですか？」等の促しは可。

### 4.1 エディタ起動

レビュー開始時に使用エディタを一度だけユーザーに確認しセッション中保持する。`$EDITOR` を参考に提示し、未設定または TUI エディタ（`vim`, `nvim`, `emacs -nw`, `nano`）の場合は代替を尋ねる。

**TUI エディタが使えない理由**: Claude Code の非対話 bash subprocess からは tty 制御を奪えず、`Output is not to a terminal` 等で失敗する。`zed`, `code`, `subl`, GUI `emacs` のような非ブロッキング GUI 起動系のみ実用的。

起動は `scripts/open_editor.sh` を使う:

```bash
.claude/skills/navigate-codereview/scripts/open_editor.sh <editor> <filepath> <line>
```

スクリプトがエディタごとの行番号構文の違いを吸収する。TUI エディタが指定されると exit code 2 を返すので、その場合はエディタ起動を諦めて「次は `path:line` です。手元で開いてください」と伝え、4.2.1 の diff 表示を自動で併せる運用に切り替える。

### 4.2 箇所の解説

開いた箇所について以下を提示する:

1. **変更内容の要約**: この変更が何をしているか
2. **PR 全体における位置づけ**: 他ファイルとの関係（例: 「このモデルメソッドは `services/foo.go` から呼ばれる」）
3. **アドバイス**: Phase 5 のチェックリストに基づく指摘。指摘がなければその旨

#### 4.2.1 周辺 diff の表示

ユーザーが「diff を見せて」等と要求したとき、または TUI エディタの都合でエディタ起動をスキップしているときに:

```bash
.claude/skills/navigate-codereview/scripts/show_hunk_diff.sh <baseRefName> <path> [start-line] [end-line]
```

スクリプトが `origin/<base>...HEAD` を base にしてハンクを抜き出し、`git config diff.tool` → `bat` → 素の git diff の順で色付き出力する。Claude 側で `sed`/`--no-pager`/ツール選択を組み立てない。

### 4.3 ユーザーヒアリング

解説後、反応を待つ:

- 気になる点を述べた → 観察メモに `[User]` タグで記録
- 質問 → 回答
- 「次」「next」等 → 次へ移動
- 次候補が複数で読み順に差がない場合 → 番号付き選択肢を提示

### 4.4 観察メモ

ナビゲーション全体で以下の形式を維持し、各ステップで件数を表示する:

```
## 観察メモ (N 件)
1. [Claude] services/tesla/oauth2.go:8 - `testing` パッケージの本番コード import
2. [User] routes/teslaauth/teslaauth.go:25 - ヘッダー設定順序が気になる
3. [Claude] internal/tesla/oauth2.go:50 - PR説明では署名検証しないとあるが実装は検証している
```

## Phase 5: アドバイス観点チェックリスト

各箇所を開く度に以下をチェックする。網羅的ではないので、文脈に応じてリスト外の観点でも気づきは共有する。

| 観点 | 説明 | 参照 |
|---|---|---|
| PR 説明との整合性 | description の変更意図と実装が一致しているか | -- |
| テストコード混入 | 本番コードに `testing` パッケージや `t *testing.T` への依存が混入していないか | -- |
| 潜在的バグ | nil チェック漏れ、境界値、エラーハンドリング漏れ、ヘッダー設定順序 | -- |
| プロジェクト慣習 | Go 規約への準拠 | `go-internal-conventions` スキル |
| アーキテクチャ | パッケージ配置、レイヤー間依存の方向、connect1 パターン | `go-internal-conventions` architecture |
| セキュリティ | 認証・認可チェック、入力バリデーション、機密情報の露出 | -- |

## Phase 6: レビューまとめ・PR コメント投稿

### 6.1 レビューまとめ

全ナビゲーション完了後、観察メモ全件を提示する:

- Claude のアドバイス一覧（ファイル・行番号付き）
- ユーザーが述べた気になる点一覧

提示後「投稿する指摘を選択してください」と促す。

### 6.2 pending review として投稿

指摘は **pending review** として一括投稿する。pending はドラフト状態で保存され、ユーザーが GitHub 画面で最終確認してから "Submit review" で公開する運用。**Claude から直接 submit はしない**（誤投稿を防ぐため）。

手順:

1. 採用候補の指摘を1件ずつ **含める / 編集する / スキップ** のいずれかに振り分ける
2. 採用分を次のスキーマの JSON 配列にしてファイルに書き出す（例: `/tmp/pending_review_comments.json`）:

   ```json
   [
     {"path": "src/example.go", "line": 15, "side": "RIGHT", "body": "単一行コメント"},
     {"path": "src/example.go", "start_line": 10, "start_side": "RIGHT", "line": 15, "side": "RIGHT", "body": "複数行コメント"}
   ]
   ```

   `side` は `RIGHT`（追加行）/ `LEFT`（削除行）。複数行は `start_line`/`start_side` と `line`/`side` の対で指定する。

3. `scripts/post_pending_review.sh` で投稿:

   ```bash
   .claude/skills/navigate-codereview/scripts/post_pending_review.sh \
     OWNER/REPO NUMBER /tmp/pending_review_comments.json "（任意の総評、不要なら省略）"
   ```

   スクリプトが head SHA 取得・既存 pending review チェック・POST を行い、成功時は review の HTML URL を出力する。URL をユーザーに伝え、GitHub 画面での "Submit review" を促す。

4. 既存 pending review がある場合、スクリプトは exit code 3 で既存 review の `id` / `html_url` を出力する。GitHub は 1 PR につき 1 pending/ユーザーという制約があるため、破棄するか既存に追記するかをユーザーに判断してもらう。

参考: [Create a review for a pull request — GitHub REST API](https://docs.github.com/ja/rest/pulls/reviews#create-a-review-for-a-pull-request)
