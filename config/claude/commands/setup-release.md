---
description: GitHub Actionsによるリリースの自動化設定をセットアップする
---

## 前提・背景

プロジェクトにGitHub Actionsを用いた自動リリースフローを導入する。
tagpr、GoReleaser、BRATなど適切なツールを選択し、immutableなリリースを実現する。

## タスク

実行するべきタスクを以下に示す。
内容をよく読み、複数並行して進められると判断した場合は、並行して実行すること。

- プロジェクトの種類を判定し、適切なリリース戦略を決定する
- GitHub Secrets に GH_PAT が設定されていることを確認する
- tagprによるバージョン管理とリリース自動化ワークフローを作成する
- 成果物の種類に応じたリリースフローを実装する
- README.mdにリリース方法を追記する
- pinactでActionsをhash値固定し、actionlintで検証する

## 完了条件

タスクの完了条件は以下の通りとする。
完了条件、または次の項目で述べる中断条件を満たすまで作業を継続すること。

- GitHub Secrets に `GH_PAT` が設定されている
- `.github/workflows/tagpr.yml`が作成され、tagpr設定が完了している
- プロジェクト種別に応じたリリースワークフローが作成されている
- 全てのワークフローで `secrets.GH_PAT` を使用している
- 全てのActionsがhash値で固定されている
- actionlintによる検証が通過している
- README.mdにリリース手順とGH_PATの前提条件が記載されている

## 実行規約

タスクの実行中は常に以下の規約に従え。

### 1. プロジェクト種別の判定

以下の順序でプロジェクト種別を判定せよ。

```bash
# Goプロジェクトの判定
test -f go.mod && echo "Go"

# Obsidianプラグインの判定
test -f manifest.json && grep -q "obsidian" manifest.json && echo "Obsidian"

# その他のプロジェクト
echo "Generic"
```

判定結果に応じて適切なリリースフローを選択せよ。

### 2. GitHub Secrets の確認

GitHub Secrets に `GH_PAT` が設定されているか確認せよ。

```bash
# リポジトリのsecrets一覧を確認
gh secret list
```

`GH_PAT` が存在しない場合、以下の手順をユーザーに案内し、設定完了後に作業を継続せよ。

**GH_PAT 設定手順:**

1. GitHub Personal Access Token (classic) を作成:
   - https://github.com/settings/tokens にアクセス
   - "Generate new token (classic)" を選択
   - Note: "Release automation" など識別可能な名前を入力
   - Expiration: 適切な期限を選択
   - Scopes: 最低限 `repo` (Full control of private repositories) を選択
   - "Generate token" をクリックし、トークンをコピー

2. GitHub Secrets に登録:
```bash
# 対話的に登録
gh secret set GH_PAT

# または、トークンを直接指定
echo "YOUR_TOKEN" | gh secret set GH_PAT
```

3. 設定確認:
```bash
gh secret list | grep GH_PAT
```

### 3. tagpr設定ファイルの作成

`.tagpr`ファイルを以下の内容で作成せよ。

**Goプロジェクトの場合:**
```yaml
# .tagpr
tagpr:
  vPrefix: true
  command:
    - git tag -d {tag}
  release:
    immutable: true
```

**その他のプロジェクトの場合:**
```yaml
# .tagpr
tagpr:
  vPrefix: true
  release:
    immutable: true
```

### 4. tagpr ワークフローの作成

`.github/workflows/tagpr.yml`を作成せよ。

```yaml
name: tagpr
on:
  push:
    branches:
      - main

jobs:
  tagpr:
    runs-on: ubuntu-latest
    outputs:
      
      tagpr-tag: ${{ steps.tagpr.outputs.tag }}
    steps:
      - uses: actions/checkout@v4
      - uses: Songmu/tagpr@v1
        id: tagpr
        env:
          GITHUB_TOKEN: ${{ secrets.GH_PAT }}
```

作成後、必ずpinactでActions versionをhash値固定せよ。

### 5. プロジェクト種別ごとのリリースフロー

**Goプロジェクトの場合:**

1. `.goreleaser.yml`の作成または確認
2. `.github/workflows/release.yml`の作成:

```yaml
name: release
on:
  push:
    tags:
      - "v*.*.*"

permissions:
  contents: write

jobs:
  goreleaser:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: actions/setup-go@v5
        with:
          go-version-file: go.mod
      - uses: goreleaser/goreleaser-action@v6
        with:
          version: latest
          args: release --clean
        env:
          GITHUB_TOKEN: ${{ secrets.GH_PAT }}
```

作成後、`pinact run --update`を実行して最新のActionバージョンを取得し、hash値固定せよ。

3. `.goreleaser.yml`が存在しない場合は基本設定を作成:

```yaml
version: 2

before:
  hooks:
    - go mod tidy

builds:
  - env:
      - CGO_ENABLED=0
    goos:
      - linux
      - windows
      - darwin
    goarch:
      - amd64
      - arm64

archives:
  - format: tar.gz
    name_template: >-
      {{ .ProjectName }}_
      {{- title .Os }}_
      {{- if eq .Arch "amd64" }}x86_64
      {{- else if eq .Arch "386" }}i386
      {{- else }}{{ .Arch }}{{ end }}
    format_overrides:
      - goos: windows
        format: zip

changelog:
  sort: asc
  filters:
    exclude:
      - "^docs:"
      - "^test:"
```

**Obsidianプラグインの場合:**

1. `.github/workflows/release.yml`の作成:

```yaml
name: release
on:
  push:
    tags:
      - "v*.*.*"

permissions:
  contents: write

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
          
      - name: Build
        run: |
          npm ci
          npm run build
          
      - name: Create release
        env:
          GITHUB_TOKEN: ${{ secrets.GH_PAT }}
        run: |
          tag="${GITHUB_REF#refs/tags/}"
          gh release create "$tag" \
            main.js \
            manifest.json \
            styles.css \
            --title "$tag" \
            --notes "Release $tag"
```

作成後、`pinact run --update`を実行して最新のActionバージョンを取得し、hash値固定せよ。

**その他のプロジェクトの場合:**

基本的なtagprワークフローのみを設定し、リリースノートの自動生成を有効化せよ。
必要に応じて成果物のビルド・アップロード処理を追加せよ。

### 6. pinactによるActionsのhash値固定

全てのワークフローファイルに対して`pinact run --update`を実行せよ。
`--update`フラグにより、最新のActionバージョンを取得した上でhash値固定される。

```bash
# pinactのインストール(未インストールの場合)
go install github.com/suzuki-shunsuke/pinact/cmd/pinact@latest

# 全ワークフローファイルのhash値固定(最新バージョン取得)
find .github/workflows -name "*.yml" -o -name "*.yaml" | while read file; do
  pinact run --update "$file"
done
```

### 7. actionlintによる検証

ワークフローファイルの構文と設定を検証せよ。

```bash
# actionlintのインストール(未インストールの場合)
brew install actionlint  # macOSの場合

# 検証実行
actionlint .github/workflows/*.yml
```

エラーが検出された場合は修正し、再度検証せよ。

### 8. README.mdへのリリース手順追記

README.mdに以下の内容を追記せよ。既存の「リリース」セクションがある場合はそこに追記、なければ新規作成せよ。

**Goプロジェクトの場合:**
```markdown
## リリース

このプロジェクトは[tagpr](https://github.com/Songmu/tagpr)と[GoReleaser](https://goreleaser.com/)による自動リリースを採用しています。

### 前提条件

リリース自動化には GitHub Secrets に `GH_PAT` (Personal Access Token) の設定が必要です。

### リリース手順

1. `main`ブランチへのマージ時、tagprが自動的にバージョンアップPRを作成します
2. バージョンアップPRをマージすると、自動的にタグが作成されます
3. タグプッシュをトリガーに、GoReleaserがビルドとGitHub Releaseを作成します

### 手動リリース

緊急時は以下のコマンドで手動リリース可能です:

\`\`\`bash
git tag v1.0.0
git push origin v1.0.0
\`\`\`
```

**Obsidianプラグインの場合:**
```markdown
## リリース

このプラグインは[tagpr](https://github.com/Songmu/tagpr)による自動リリースを採用しています。
[BRAT](https://github.com/TfTHacker/obsidian42-brat)経由でのインストールをサポートしています。

### 前提条件

リリース自動化には GitHub Secrets に `GH_PAT` (Personal Access Token) の設定が必要です。

### リリース手順

1. `main`ブランチへのマージ時、tagprが自動的にバージョンアップPRを作成します
2. バージョンアップPRをマージすると、自動的にタグとリリースが作成されます

### BRATでのインストール

1. Obsidianで[BRAT](https://github.com/TfTHacker/obsidian42-brat)プラグインをインストール
2. BRATの設定で「Add Beta plugin」を選択
3. このリポジトリのURL(`ユーザー名/リポジトリ名`)を入力
```

**その他のプロジェクトの場合:**
```markdown
## リリース

このプロジェクトは[tagpr](https://github.com/Songmu/tagpr)による自動リリースを採用しています。

### 前提条件

リリース自動化には GitHub Secrets に `GH_PAT` (Personal Access Token) の設定が必要です。

### リリース手順

1. `main`ブランチへのマージ時、tagprが自動的にバージョンアップPRを作成します
2. バージョンアップPRをマージすると、自動的にタグとリリースが作成されます
```

### 9. 作成内容の確認

全ての設定完了後、以下を確認せよ。

```bash
# ワークフローファイルの存在確認
ls -la .github/workflows/

# tagpr設定の確認
cat .tagpr

# GH_PAT secretの存在確認
gh secret list | grep GH_PAT

# actionlint検証
actionlint .github/workflows/*.yml
```

問題がなければ、作成したファイル一覧と設定内容をユーザーに報告せよ。

## 中断条件

以下の条件を満たした場合は作業を中断し、その旨を報告すること。
また、現在の状況と残タスクを簡潔にまとめて提示すること。

- `.github/workflows`ディレクトリが作成できない場合(Gitリポジトリでない等)
- GitHub CLIが利用できず、`GH_PAT`の確認・設定ができない場合
- `GH_PAT`が設定されておらず、ユーザーが設定を完了していない場合
- pinactまたはactionlintのインストールに失敗し、代替手段がない場合
- 同一エラーが3回以上発生し進捗なし
- Goプロジェクトで`go.mod`の内容が不正な場合
- Obsidianプラグインで`manifest.json`の内容が不正な場合

## 禁止事項

- タスクに直接関係しないファイルの変更を禁じる
- 既存のワークフローファイルを確認なしに上書きすることを禁じる
- プロジェクト種別の誤判定を禁じる。不明な場合はユーザーに確認せよ
- pinact実行前のワークフローファイルのコミットを禁じる
- actionlint検証なしでの完了報告を禁じる
- 冗長なコメントを禁じる

## 補足事項

タスクに関する補足事項を以下に示す。

- タスクを実行するにあたり、その円滑な進行を妨げる点がある場合は、その旨をユーザーに報告し、追加の情報を求めよ
- immutableなリリースについては https://songmu.jp/riji/entry/2025-09-05-coordinate-tagpr-and-goreleaser-with-immutable-releases.html を参照
- pinactが利用できない環境では、手動でのhash値固定方法を案内せよ
- 既存のリリースフローがある場合は、それを尊重しつつ改善を提案せよ
- プロジェクト固有の要件(特定のビルドコマンド等)がある場合は、ユーザーに確認してから反映せよ
