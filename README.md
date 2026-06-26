# 工作台 - 课表/晚托表/作息表管理系统

版本: v1.0.3 (2026-06-26 更新)

## 文件说明

- `schedule_v103.html` — 主应用文件（单文件 HTML/JS/CSS）

## 最近更新 (v1.0.3)

### 导出图片 UI 优化
1. **课程表导出**：四周圆角改为方形；"上午"/"下午"字段文字白色，两字中间空4个字符
2. **边框统一**：三表导出统一使用 `border-collapse:collapse` + `1px solid #000` 细边框，消除重叠
3. **晚托表导出**：整个学期导出时仅第一个月显示表头（月/周次），后续月份隐藏表头但保留分割行
4. **晚托表格子对齐**：统一列宽（月52px/周次64px/7天均分），统一 padding 和行高

## 初始化 Git

```bash
# 1. 安装 Git for Windows: https://git-scm.com/download/win
# 2. 打开命令行进入项目目录
cd C:\Users\Administrator\Desktop\schedule-workbench

# 3. 初始化 Git 仓库
git init
git add .
git commit -m "v1.0.3: 导出图片UI优化 - 课程表方形边框/白色上午下午/边框统一/晚托表表头优化"

# 4. 下班后在家继续开发
# 可以用 U盘/网盘 同步此文件夹，或者推送到 GitHub/Gitee
```

## 在家继续开发

下班后将 `schedule-workbench` 文件夹复制到家里电脑即可继续开发。
