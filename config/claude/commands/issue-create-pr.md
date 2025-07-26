---
description: Issueをもとに実行した変更について、Pull Requestを作成する。
argument-hint: --base-branch=[baseBranch] --language=[language] [issueURL]
---

# Context

- ベースブランチ名: コマンド引数の `--base-branch` で指定された値
- PullRequest作成に使用する言語: コマンド引数の `--language` で指定された値。指定がなければ日本語
- 作成するPullRequestが解決するIssueのURL: コマンド引数の `[issueURL]` で指定された値

# Your task

現在のブランチからメインブランチをベースブランチとしたPull Requestを作成せよ。

# Notice

以下の注意点をよく読み、これらに従え。

- Issue $ARGUMENTS を解決するものであることを明確にせよ
- 現在のブランチはすでにリモートにpush済みである
- Pull Requestはタイトル・本文ともに日本語で作成せよ
- CLAUDE.md にPull Requestに関する指示がある場合は、それらの指示を優先せよ
- GitHub上のリソース操作には `gh` コマンドを用いよ
