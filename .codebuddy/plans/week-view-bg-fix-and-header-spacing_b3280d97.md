---
name: week-view-bg-fix-and-header-spacing
overview: 修复周视图课表区白色底色问题（改用border-spacing制造真正间隙露出#F9FCF6），并缩小表头周X与日期间距、统一今天状态间距
design:
  architecture:
    framework: html
  styleKeywords:
    - Minimalism
    - Clean Card UI
    - Transparent Gap
    - Consistent Spacing
  fontSystem:
    fontFamily: PingFang SC
    heading:
      size: 18px
      weight: 700
    subheading:
      size: 13px
      weight: 600
    body:
      size: 11px
      weight: 500
  colorSystem:
    primary:
      - "#597AB5"
      - "#16A34A"
    background:
      - "#F9FCF6"
      - "#FFFFFF"
    text:
      - "#1A1A2E"
      - rgba(26,26,46,0.7)
    functional:
      - "#FFFFFF"
      - "#E2E8F0"
todos:
  - id: fix-card-gap
    content: 修复分段卡片间隙：用border-top/border-bottom透明边框替代无效的margin，移动端8px/桌面端12px
    status: completed
  - id: adjust-header-spacing
    content: 调整表头间距：日期margin-top从5px改为3px，今天状态添加margin-top:3px
    status: completed
  - id: verify-and-push
    content: 验证Lint 0错误并提交推送到GitHub
    status: completed
    dependencies:
      - fix-card-gap
      - adjust-header-spacing
---

## 产品概述

修复教师作息工作台周视图的白色卡片间隙显示问题，并实现正确的三层视觉效果（数据层-白色卡片层-页面背景层），同时精细调整表头间距。

## 核心功能

1. **修复分段卡片间隙**：利用 `border-collapse: separate` + `border-spacing` + 透明边框方案，使上午/下午卡片之间出现真正可见的间隙，露出页面背景色 #F9FCF6
2. **表头间距精细调整**：将"周X"与"日期"间隔从5px调小至3px；使"今天"状态的间距与其他列保持一致
3. **验证并同步**：Lint检查通过后提交并推送到GitHub

## 问题根源分析

- `tr` 元素不支持 `margin` 属性，CSS 第1174行 `tr.wk-section-last { margin-bottom:... }` 被浏览器忽略
- 导致上午卡片和下午卡片之间无间隙，整张表呈现为连续白色方块
- 用户看到"白色底色"是因为卡片之间没有空隙露出 #F9FCF6 背景

## 技术栈

- 单文件HTML应用 (schedule_v103.html)
- 内联CSS + 原生JavaScript
- 无框架依赖

## 实现方案

### Task 1: 修复分段卡片间隙（核心修复）

**问题根源**：`tr` 元素不支持 `margin`，需用其他方案制造间隙

**推荐方案**：利用 `border-collapse: separate` + `border-spacing` + 透明边框

具体实现：

1. 保持 `border-collapse: separate`（已有）
2. 设置 `border-spacing: 0 2px` 制造行内微小间隙
3. 用 `border-top` / `border-bottom` 透明边框模拟段间大间隙：

- `tr.wk-section-first td { border-top: 8px solid transparent; }` — 移动端段首间隙
- `tr.wk-section-last td { border-bottom: 8px solid transparent; }` — 移动端段末间隙

4. 桌面端通过媒体查询设置为 `12px`
5. 同时去掉 `!important` 强制白底，避免样式冲突

**修改后的CSS结构**：

```css
/* 表格使用separate模式，配合border-spacing制造间隙 */
.weekly-grid {
  border-collapse: separate;
  border-spacing: 0 2px; /* 行内微小间隙2px */
}

/* 分段卡片td白底（去掉!important） */
tr.wk-section-first td,
tr.wk-section-last td,
tr:not(.wk-section-first):not(.wk-section-last) td {
  background: #FFFFFF;
}

/* 段首行：顶部透明边框制造段间间隙 */
tr.wk-section-first td {
  border-top: 8px solid transparent;
  padding-top: clamp(4px, 0.6vw, 6px); /* 调整内边距补偿 */
}

/* 段末行：底部透明边框制造段间间隙 */
tr.wk-section-last td {
  border-bottom: 8px solid transparent;
  padding-bottom: clamp(4px, 0.6vw, 6px);
}

/* 桌面端增大间隙 */
@media (min-width: 601px) {
  tr.wk-section-first td { border-top: 12px solid transparent; }
  tr.wk-section-last td { border-bottom: 12px solid transparent; }
}
```

### Task 2: 表头间距精细调整

**策略**：纯CSS调整

1. 调小"周X"与"日期"间距：

- `.wdt-date { margin-top: 3px; }` — 从5px改为3px

2. 统一"今天"状态间距：

- `.wdt-today { margin-top: 3px; display: block; }` — 与 `.wdt-date` 保持一致

### Task 3: 验证和同步

1. 运行Lint检查确认0错误
2. Git提交并推送到GitHub

## 架构设计

所有改动集中在单一文件 `schedule_v103.html` 的CSS区域（~1136-1200行）

## 目录结构

```
c:/Users/fan-12700/OneDrive/schedule-workbench/
└── schedule_v103.html    # [MODIFY] 唯一修改文件
    ├── CSS ~1136-1200行   # 分段卡片间隙 + 表头间距
    └── CSS ~1270-1340行   # 移动端/桌面端响应式适配
```

## 关键代码结构

无新增代码结构设计，均为现有CSS规则修改。

## 设计风格定位

移动端优先的教师课表工具，追求简洁清爽的卡片式布局。本次修复确保三层视觉效果正确呈现：

- 最上层：课程/节次/表头数据
- 第二层：圆角白色卡片（表头、上午段、下午段各自为独立卡片）
- 最下层：页面底色 #F9FCF6

## 页面规划（单页面修复）

### Block 1: 周视图表头区域

- "周X"与"日期"间距从5px缩小至3px
- "今天"状态的"今天"文字与"周X"间距调整为3px，与其他列一致

### Block 2: 课表主体 — 正确的分段卡片效果

- 上午课程为一个白色圆角卡片
- 下午课程为另一个白色圆角卡片
- 两个卡片之间有8px（移动端）/12px（桌面端）间隙，间隙处露出 #F9FCF6 背景色

## 响应式设计

- 移动端（≤600px）：卡片间隙8px，表头间距3px
- 桌面端（≥601px）：卡片间隙12px，表头间距3px

## Agent Extensions

### Skill

- **frontend-design**
- Purpose: 提供专业的视觉设计指导，确保卡片间隙、间距调整等细节符合现代前端设计标准
- Expected outcome: 输出精致且一致的UI修复方案

- **ui-ux-pro-max**
- Purpose: 利用UX规范验证间距一致性、触摸目标尺寸等关键指标
- Expected outcome: 确保修复后的交互体验符合专业级质量标准