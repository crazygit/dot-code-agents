#!/bin/bash
#
# dot-code-agents 一键安装脚本
#
# 用法：
#   curl -fsSL https://raw.githubusercontent.com/crazygit/dot-code-agents/main/install.sh | bash
#   wget -qO- https://raw.githubusercontent.com/crazygit/dot-code-agents/main/install.sh | bash
#

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
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

header() {
    echo ""
    echo -e "${BOLD}${BLUE}$1${NC}"
    echo "────────────────────────────────────────"
}

# 检查必要命令
check_commands() {
    local missing=()

    for cmd in git; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        error "缺少必要命令: ${missing[*]}"
        echo "请先安装缺少的命令后重试"
        exit 1
    fi
}

# 备份目录
backup_dir() {
    local dir="$1"
    if [ -e "$dir" ]; then
        local backup="${dir}.bak.$(date +%Y%m%d%H%M%S)"
        warn "备份现有配置: $dir -> $backup"
        mv "$dir" "$backup"
    fi
}

# 主安装流程
main() {
    header "dot-code-agents 安装程序"

    info "检查必要命令..."
    check_commands

    # 设置安装目录
    local install_dir="$HOME/dot-code-agents"

    # 检查是否已安装
    if [ -d "$install_dir" ]; then
        warn "安装目录已存在: $install_dir"
        read -p "是否更新现有安装? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "安装已取消"
            exit 0
        fi
        info "更新现有安装..."
        cd "$install_dir"
        git pull origin main
    else
        # 克隆仓库
        info "克隆仓库到: $install_dir"
        git clone https://github.com/crazygit/dot-code-agents.git "$install_dir"
    fi

    success "仓库已就绪: $install_dir"
    echo ""

    # 配置 Claude Code
    header "配置 Claude Code"
    local claude_dir="$HOME/.claude"
    backup_dir "$claude_dir"
    ln -s "$install_dir/claude" "$claude_dir"
    success "Claude Code 配置完成: $claude_dir → $install_dir/claude"

    # 配置 Codex
    header "配置 Codex"
    local codex_dir="$HOME/.codex"
    backup_dir "$codex_dir"
    ln -s "$install_dir/codex" "$codex_dir"
    success "Codex 配置完成: $codex_dir → $install_dir/codex"

    # 同步 agents 配置
    header "同步 Codex Agents 配置"
    if [ -f "$install_dir/agents/setup.sh" ]; then
        cd "$install_dir/agents"
        bash setup.sh sync
    else
        warn "agents/setup.sh 不存在，跳过"
    fi

    # 完成
    echo ""
    header "安装完成！"
    echo ""
    echo -e "${GREEN}✓${NC} Claude Code 配置: $claude_dir"
    echo -e "${GREEN}✓${NC} Codex 配置:     $codex_dir"
    echo -e "${GREEN}✓${NC} 仓库位置:       $install_dir"
    echo ""
    echo -e "${BOLD}后续步骤:${NC}"
    echo ""
    echo "1. 重启 Claude Code，配置自动生效"
    echo ""
    echo "2. 在 Codex 中安装插件:"
    echo "   - 打开插件目录 (Ctrl/Cmd + Shift + P → Plugins)"
    echo "   - 从 'Local Plugins' 源安装 issue-flow"
    echo ""
    echo "3. 更新配置:"
    echo "   cd $install_dir"
    echo "   git pull"
    echo "   cd agents && ./setup.sh sync"
    echo ""
    echo -e "${BOLD}卸载:${NC}"
    echo ""
    echo "   rm $claude_dir $codex_dir"
    echo "   rm -rf $install_dir"
    echo "   (备份文件会保留在 *.bak.* 目录中)"
    echo ""
}

main
