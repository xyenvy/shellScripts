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

mem_usage(){
  # 获取当前内存使用率
  mem_usage=$(free | awk 'NR==2{printf "%.2f\n", $3*100/$2 }')

  # 设置阈值为85%
  threshold=85

  # 检查内存使用率是否超过阈值
  if (( $(echo "$mem_usage > $threshold" | bc -l) )); then
      echo -e "${RED}内存使用率已超过${threshold}%。当前使用率：${mem_usage}%${NC}"
      # 在这里可以添加你希望执行的操作，比如发送警报或执行一些清理操作
  else
      echo -e "${GREEN}内存使用率正常。当前使用率：${mem_usage}%${NC}"
  fi
}



while true; do
    # 显示菜单选项
    echo -e "${RED}=============== 运维菜单 ===============${NC}"
    echo -e "${GREEN}1. 清理2天前拉取，未使用的Docker镜像${NC}"
    echo -e "${GREEN}2. 查看磁盘空间${NC}"
    echo -e "${GREEN}3. 查看进程列表${NC}"
    echo -e "${GREEN}4. 查看当前主机内存使用百分比${NC}"
    echo -e "${GREEN}20. 退出${NC}"
    echo -e "${RED}========================================${NC}"
    
    # 读取用户输入
    read -p "请输入选项数字：" choice
    
    # 根据用户选择执行相应的操作
    case $choice in
        1)
            # 清理2天前拉取，未使用的镜像
            echo -e "${GREEN}正在清理两天前拉取并未使用的Docker镜像${NC}"
            clean_unused_docker_images
            ;;
        2)
            echo -e "${RED}磁盘空间:${NC}"
            df -h  # 示例命令，查看磁盘空间
            ;;
        3)
            echo -e "${GREEN}进程列表:${NC}"
            ps aux  # 示例命令，查看进程列
            ;;
        4)
            echo -e "${GREEN}当前主机内存使用百分比：${NC}"
            mem_usage
            ;;
        20)
            echo -e "${GREEN}即将退出运维菜单${NC}"
            break  # 退出循环，结束脚本执行
            ;;
        *)
            echo -e "${RED}无效的选项，请重新输入:${NC}"
            ;;
    esac
    
    # 暂停一段时间以便用户阅读结果
    sleep 2
    echo
done
