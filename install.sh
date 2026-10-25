#!/usr/bin/env bash
# 安装 dsh-session-notes 里的 Agent Skill。
# 用法：./install.sh [--claude] [--dest=/some/skills/dir]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO_ROOT/skills"

if [ ! -d "$SRC" ]; then
    echo "找不到 skills 目录：$SRC" >&2
    exit 1
fi

targets=("$HOME/.agents/skills")

for arg in "$@"; do
    case "$arg" in
        --claude) targets+=("$HOME/.claude/skills") ;;
        --dest=*) targets+=("${arg#--dest=}") ;;
        *) echo "未知参数：$arg" >&2; exit 1 ;;
    esac
done

for skill_dir in "$SRC"/*/; do
    [ -d "$skill_dir" ] || continue
    name="$(basename "$skill_dir")"
    for target in "${targets[@]}"; do
        mkdir -p "$target"
        dest="$target/$name"
        if [ -e "$dest" ]; then
            rm -rf "$dest"
            echo "覆盖旧版本：$dest"
        fi
        cp -R "$skill_dir" "$dest"
        echo "已安装：$dest"
    done
done

echo
echo "完成。记得改 skills/conclude/SKILL.md 里的「默认仓库」占位符。"
