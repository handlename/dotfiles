---
description: 要件に基づく実装
argument-hint: <要件> [--plan-only] [--force]
allowed-tools: Task, Bash, Glob, Grep, LS, Read, Edit, MultiEdit, Write, TodoWrite, NotebookEdit, NotebookRead
---

## 前提・背景

要件: $ARGUMENTS
プロジェクト構造: !`find . -name "package.json" -o -name "Cargo.toml" -o -name "pyproject.toml" -o -name "go.mod" | head -5`
テストコマンド: !`grep -E "test|check|lint" package.json 2>/dev/null || echo "テストコマンド未検出"`

## タスク

与えられた要件を以下の手順で実装せよ：

1. **分析** - 要件を分解しTodoWriteで計画作成
2. **調査** - 関連ファイルと既存パターンを特定
3. **実装** - 既存規約に従い段階的に実装
4. **検証** - テスト実行とlint/typecheck確認

## オプション

- `--plan-only`: 計画作成のみ、実装しない
- `--force`: 破壊的変更を許可
- `--no-test`: テストスキップ（非推奨）

## 完了条件

- 要件を完全に満たす実装
- 全関連テストの通過
- lint/typecheckエラーなし

## 実行規約

- 既存コード規約を調査し厳守せよ
- 最小限の変更で要件を満たせ
- 各実装段階でTodoを更新せよ

## 中断条件

- 要件が不明確で複数解釈が可能
- 大規模な設計変更が必要
- セキュリティリスクの発見

## 禁止事項

- 要件外の機能追加
- 無関係なファイルの変更
- コメントアウトされたコードの残留

## 補足事項

- CLAUDE.mdの指示を優先せよ
- 不明点は即座に質問せよ
