各見出しの括弧書きは、それぞれの重要度である。
重要度の定義は以下の通り。

- MUST: 必ず守られなければならない
- SHOULD: 望ましいが、守らなくても問題ない

# (MUST) 適切なskillの利用

タスク開始前に、使用できるskillを確認せよ。
タスク遂行に適したskillを積極的に活用せよ。

# (MUST) 適切なsub agentの利用

タスク開始前に、使用できるsub agentを確認せよ。
作業完了後は、タスクの内容に応じた適切なsub agentにレビューを依頼せよ。

# (SHOULD) 純粋関数の使用

積極的に純粋関数を使用せよ。
副作用がない純粋関数は、テストしやすく、動作の把握も用意である。

ただし、既存関数の純粋関数化は、指示があるまで行ってはならない。

# (SHOULD) immutable な型の利用

積極的に immutable な型を使用せよ。
immutable な型は、変更ができないため、不変性を保ち、並列処理や並列化が容易である。

ただし、指示にない既存の型の immutable 化は禁ずる。

# (MUST) 冗長なコメントの禁止

単純な処理(単発の関数呼び出しなど)に対する冗長なコメントは禁ずる。

# (SHOULD) コードの意図を補足するコメントの記述

コードのみからではその糸が伝わりにくい処理には、その糸を説明するコメントを記述せよ。

# (MUST) commit前のテスト通過確認

git commit する前には、関連するテストが通過することを確認しなければならない。
関連するテストはタスクと同時に与えられる場合もあるが、関連すると判断したテストは追加で通過の確認を行うこと。

# (MAY) GitHub CLI を用いた GitHub 上リソースの取得

GitHub 上のリソース取得には GitHub CLI (`gh`) を用いよ。
ただし、GitHub 上のリソース変更(Issueの作成/更新、Pull Requestの作成など)は、指示があるまで行ってはならない。

# (MUST) git commit時のGPGサイン

すべてのcommitについて、GPGサインを必須とする。
`--no-gpg-sign` フラグを用いてGPGサインを無効化してはならない。
GPGサインが行えない場合は、ユーザーの指示があるまで待機せよ。

# (MUST) git commit時のco-author設定

すべてのcommitについて、co-autherとしてClaude Codeを追加せよ。
commitメッセージの末尾に以下のメッセージを追加すればよい。

```
🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

co-autherについては以下のドキュメントを参照せよ。
https://docs.github.com/en/pull-requests/committing-changes-to-your-project/creating-and-editing-commits/creating-a-commit-with-multiple-authors

# (SHOULD) git コマンドを実行する際は --no-pager フラグを付与する

pager の使用によりコマンドの実行が終了せず、その後の処理に進めなくなってしまう。
git コマンドには --no-pager フラグを付与し、pager を使わずその出力を確認すること。
