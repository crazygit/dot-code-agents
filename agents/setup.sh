#!/bin/bash
#
# Codex Agents 配置同步脚本
#
# 用法：
#   ./setup.sh        # 同步配置到本地
#   ./setup.sh check  # 检查配置状态
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
AGENTS_DIR="$HOME/.agents"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查配置状态
check_config() {
    info "检查 Codex 配置状态..."

    # 检查 ~/.agents 目录
    if [ ! -d "$AGENTS_DIR" ]; then
        error "~/.agents 目录不存在，请先安装 Codex"
        return 1
    fi

    # 检查 marketplace.json
    if [ -f "$AGENTS_DIR/plugins/marketplace.json" ]; then
        success "marketplace.json 已存在"
    else
        warn "marketplace.json 不存在"
    fi

    # 检查 ~/.codex 软链接
    if [ -L "$HOME/.codex" ]; then
        success "~/.codex 已软链接到: $(readlink $HOME/.codex)"
    elif [ -d "$HOME/.codex" ]; then
        warn "~/.codex 是普通目录，建议使用软链接"
    else
        warn "~/.codex 不存在"
    fi

    # 检查 local-plugins
    if [ -L "$HOME/.codex/local-plugins" ]; then
        success "local-plugins 已软链接到: $(readlink $HOME/.codex/local-plugins)"
    elif [ -d "$HOME/.codex/local-plugins" ]; then
        warn "local-plugins 是普通目录"
    else
        warn "local-plugins 不存在"
    fi
}

# 同步配置
sync_config() {
    info "同步 Codex 配置..."

    # 复制 marketplace.json
    mkdir -p "$AGENTS_DIR/plugins"
    cp "$SCRIPT_DIR/plugins/marketplace.json" "$AGENTS_DIR/plugins/"
    success "marketplace.json 已同步"

    # 确保 ~/.codex 软链接存在
    if [ -L "$HOME/.codex" ]; then
        info "~/.codex 软链接已存在"
    elif [ -d "$HOME/.codex" ]; then
        warn "~/.codex 是普通目录，跳过创建软链接"
    else
        if [ -d "$REPO_DIR/codex" ]; then
            ln -s "$REPO_DIR/codex" "$HOME/.codex"
            success "~/.codex 软链接已创建"
        else
            error "codex/ 目录不存在"
            return 1
        fi
    fi

    # 确保 local-plugins 软链接存在
    if [ ! -L "$HOME/.codex/local-plugins" ] && [ ! -d "$HOME/.codex/local-plugins" ]; then
        if [ -d "$REPO_DIR/codex/local-plugins" ]; then
            ln -s "$REPO_DIR/codex/local-plugins" "$HOME/.codex/local-plugins"
            success "local-plugins 软链接已创建"
        else
            warn "local-plugins 源目录不存在"
        fi
    fi

    echo ""
    info "配置同步完成！"
    info "请在 Codex 中打开插件目录，从 'Local Plugins' 源安装插件"
}

# 主函数
main() {
    case "${1:-sync}" in
        check)
            check_config
            ;;
        sync)
            sync_config
            ;;
        *)
            echo "用法: $0 [check|sync]"
            echo ""
            echo "命令:"
            echo "  check  - 检查配置状态"
            echo "  sync   - 同步配置到本地（默认）"
            exit 1
            ;;
    esac
}

main "$@"
