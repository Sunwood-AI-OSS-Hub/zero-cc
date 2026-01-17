#!/bin/bash
# tmux 3分割スクリプト (L字分割)
# 使い方: ./tmux-split-3.sh
#
# ペイン構成:
#   ┌─────────────┬─────────────┐
#   │  Pane 0     │  Pane 1     │
#   │  Manager    │  Worker 1   │
#   ├─────────────┼─────────────┤
#   │             │  Pane 2     │
#   │             │  Worker 2   │
#   └─────────────┴─────────────┘

# 新しいセッション名（任意）
SESSION_NAME="dev"

# 既存のセッションにアタッチするか、新規作成する
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "既存のセッション '$SESSION_NAME' にアタッチします"
    tmux attach-session -t "$SESSION_NAME"
else
    # 新規セッション作成（最初のペインは自動的に作られる）
    tmux new-session -d -s "$SESSION_NAME"

    # 左右に分割（右側のペインを作成）
    tmux split-window -h -t "$SESSION_NAME:0.0"

    # 右側のペインを上下に分割
    tmux split-window -v -t "$SESSION_NAME:0.1"

    # すべてのペインで ccd-glm を実行（画面をクリアしてから）
    tmux send-keys -t "$SESSION_NAME:0.0" "clear && ccd-glm" C-m
    tmux send-keys -t "$SESSION_NAME:0.1" "clear && ccd-glm" C-m
    tmux send-keys -t "$SESSION_NAME:0.2" "clear && ccd-glm" C-m

    # セッションにアタッチ
    tmux select-pane -t "$SESSION_NAME:0.0"
    tmux attach-session -t "$SESSION_NAME"
fi
