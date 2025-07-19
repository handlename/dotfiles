---
description: 変更をcommitする。
---

stageされた変更をcommitせよ。
commitメッセージには変更内容の概要を端的に表した文章を含めよ。
commitメッセージの見出し(1行目)の内容に指定がある場合は、それをそのまま採用せよ。
commitメッセージの見出しには、下記に示すルールに基づいてprefixを付与せよ。
ひとつのprefixで表すことができない場合は、commitを分割せよ。

# commitメッセージの見出し

以下の `<text>` タグで示されたテキストをcommitメッセージの見出しに使用せよ。
ただし、同タグの内容が空文字列、または空白文字のみである場合は、適切なメッセージを生成せよ。

<text>
$ARGUMENTS
</text>

# prefixルール

- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- **refactor**: A code change that neither fixes a bug nor adds a feature
- **perf**: A code change that improves performance
- **test**: Adding missing or correcting existing tests
- **chore**: Changes to the build process or auxiliary tools and libraries such as documentation generation
