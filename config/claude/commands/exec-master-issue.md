---
description: issue とそのサブ issue を読んでタスクを実行する
---

GitHub issue $ARGUMENTS を `gh` コマンドを用いて取得し、その内容を注意深く読め。
対象の issue にリストアップされている未完了のサブ issue を順に処理せよ。
その際、以下の注意点を留意せよ。

- 各 issue の背景や前提条件を十分に理解した後に、タスクを実行せよ
    - タスクを開始する前に、対象の issue を再度読み直せ
    - その際、issue のコメントも含めて注意深く読め
- issue ごとにブランチを作成せよ
    - ブランチの名前は issue 番号に紐づけよ(例: feature/issue-4)
    - ブランチは直前に実行していた issue 用ブランチをベースとして作成せよ
- 実装を進めた結果、issue に書かれた実装項目に矛盾が生じた場合は、その旨を各 issue のコメントにて補足せよ
- issue で示された実装が完了するまで作業を実行し続けよ
- 各 issue の作業の結果を .claude/logs/ 以下にレポート形式の Markdown ファイルで保存せよ
    - Markdown ファイル名は対象の issue が属する organization、repository、および issue 番号に紐づけよ(例: logs/{organization}/{repository}/issue-{number}.md)
    - .claude/logs 自体、及び必要なサブディレクトリが存在しない場合は適宜作成せよ
