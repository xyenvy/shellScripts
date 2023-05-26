#!/bin/bash

set -e -u

# 定义颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # 重置颜色代码

# 清理未使用镜像
clean_unused_docker_images(){
  echo -e "${RED}正在删除未使用的镜像，请稍等······${NC}"
  
  # 清理2天前拉取，未使用的镜像
  docker image prune -a --filter "until=48h" -f

  echo -e "${GREEN}删除状态：····················[OK]${NC}"
}

while true; do
    # 显示菜单选项
    echo -e "${RED}=============== 运维菜单 ===============${NC}"
    echo -e "${GREEN}1. 清理2天前拉取，未使用的Docker镜像${NC}"
    echo -e "${GREEN}2. 查看磁盘空间${NC}"
    echo -e "${GREEN}3. 查看进程列表${NC}"
    echo -e "${GREEN}4. 退出${NC}"
    echo -e "${RED}========================================${NC}"
    
    # 读取用户输入
    read -p "请输入选项数字：" choice
    
    # 根据用户选择执行相应的操作
    case $choice in
        1)
            # 清理2天前拉取，未使用的镜像
            clean_unused_docker_images
            ;;
        2)
            echo "磁盘空间："
            df -h  # 示例命令，查看磁盘空间
            ;;
        3)
            echo "进程列表："
            ps aux  # 示例命令，查看进程列表
            ;;
        4)
            echo "退出运维菜单"
            break  # 退出循环，结束脚本执行
            ;;
        *)
            echo "无效的选项，请重新输入"
            ;;
    esac
    
    # 暂停一段时间以便用户阅读结果
    sleep 2
    echo
done
