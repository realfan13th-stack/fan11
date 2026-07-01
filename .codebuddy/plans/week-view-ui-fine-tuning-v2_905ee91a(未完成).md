---
name: week-view-ui-fine-tuning-v2
overview: 移动端周视图UI精细化调整5项：表头日期间距压缩+第X周斜线摆法+课表背景透出+节次底色去除+导航按钮圆角调整
design:
  architecture:
    framework: html
  styleKeywords:
    - Minimalism
    - Clean Card UI
    - Diagonal Header
    - Transparent Background
    - Consistent Border Radius
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
      - transparent
    text:
      - "#1A1A2E"
      - rgba(26,26,46,0.7)
    functional:
      - "#FFFFFF"
      - "#E2E8F0"
todos:
  - id: fix-header-spacing
    content: 调整周X与日期间距(5px)+今天状态隐藏日期(CSS纯方案)
    status: pending
  - id: diagonal-week-header
    content: 重构第X周为斜线表头(JS包裹容器+CSS伪元素对角线+绝对定位)
    status: pending
  - id: transparent-bg
    content: 课表区背景透明化(td+分段卡片白底删除，保留week-card本身颜色)
    status: pending
  - id: remove-period-bg
    content: 去除节次数字底色(background+border-radius移除)
    status: pending
  - id: nav-button-radius
    content: 导航按钮圆角从99px改为10px(移动端8px)+响应式适配
    status: pending
  - id: verify-lint
    content: 验证0 lint错误并确认移动端渲染效果
    status: pending
    dependencies:
      - fix-header-spacing
      - diagonal-week-header
      - transparent-bg
      - remove-period-bg
      - nav-button-radius
---

## Product Overview

对移动端周视图进行5项UI微调优化，基于当前效果（图1）和参考样图（图2），精细化视觉细节。

## Core Features

1. **周X与日期间距压缩**：日期在周X正下方，间隔固定为5px；当列标记为"今天"时，隐藏日期文字，让"今天"标签占据原日期位置。

2. **第X周斜线表头**：参考图2的斜线摆法——左上角显示小字"第"、中间偏上显示大字粗体数字、右下角或底部显示小字"周"，用一条从左上到右下的细线分割单元格形成经典表格斜线表头效果。

3. **课表区背景透明化**：删除td单元格的白色背景(#FFFFFF)和分段卡片的强制白底规则，使整个课表区域背景透明，露出项目底层色(--bg: #F9FCF6)，以便验证白色分段卡片的视觉效果是否正确。

4. **节次数字底色去除**：删除`.period-label-num`的灰色圆角背景(`#F1F5F9` + `border-radius:8px`)，仅保留纯白卡片底上的黑色数字文字。

5. **导航按钮去胶囊化**：底部"上一周/本周/下一周"按钮的`border-radius:99px`(完全圆形胶囊)改为与上面卡片类似的圆角(约10px)，风格统一。

## Tech Stack

- 单文件HTML应用 (schedule_v103.html)
- 内联CSS + 原生JavaScript
- 无框架依赖

## Implementation Approach

### Task 1: 周X与日期间距 + 今天状态处理

**策略**: 纯CSS方案，无需改JS

- `.wk-date-th .wdt-date { margin-top: 5px; }` (从1px改为5px)
- 新增 `.wk-date-th.today-col .wdt-date { display: none; }` 隐藏今天列的日期

### Task 2: 第X周斜线表头重构

**策略**: CSS伪元素对角线 + 绝对定位文字三件套

- JS改动：将当前 `<span>第</span><span>18</span><br><span>周</span>` 包裹在 `<div class="wk-diagonal">` 容器中
- CSS实现：
- `.wk-diagonal { position:relative; overflow:hidden; }`
- `::before` 伪元素画对角线：`linear-gradient(to bottom right, transparent 48%, rgba(0,0,0,0.1) 48%, rgba(0,0,0,0.1) 52%, transparent 52%)`
- `.wkn-label` → `position:absolute; top:2px; left:4px;` （左上）
- `.wkn-num` → `position:absolute; top:38%; left:50%; transform:translate(-50%,-50%);` （居中）
- `.wkn-suffix` → `position:absolute; bottom:2px; right:4px;` （右下）

### Task 3: 课表背景透明化

- `.weekly-grid td { background: transparent; }` (从#FFFFFF改)
- 删除分段卡片强制白底规则中的 `background:#FFFFFF !important;` 
- 保留thead的白色背景(属于卡片头部)
- `.week-card`课程卡片保持自身彩色/白色不变

### Task 4: 节次数字底色去除

- `.period-label-num { background: transparent; border-radius: 0; padding: 2px 4px; }`
- 移动端同步更新：去掉对应的border-radius值

### Task 5: 导航按钮圆角统一

- `.week-bottom-nav button { border-radius: 10px; }` (从99px改为10px)
- 移动端：`border-radius: 8px`

## Architecture Design

所有改动集中在单一文件 `schedule_v103.html` 的：

- **CSS区域**: ~1069-1320行（周视图样式块）
- **JS区域**: ~2494-2496行（renderWeekView中第X周th生成）

## Directory Structure

```
c:/Users/fan-12700/OneDrive/schedule-workbench/
└── schedule_v103.html    # [MODIFY] 唯一修改文件
    ├── CSS ~1083-1320行   # td背景/表头日期间距/斜线表头/节次数字/导航按钮
    └── JS ~2494-2496行    # 第X周HTML结构调整（添加.wk-diagonal容器）
```

## Key Code Structures

```css
/* 斜线表头核心结构 */
.wk-diagonal {
  position: relative;
  width: 100%;
  min-height: clamp(44px,5vw,60px);
  overflow: hidden;
}
.wk-diagonal::before {
  content: '';
  position: absolute;
  top: 0; left: 0;
  width: 100%; height: 100%;
  background: linear-gradient(to bottom right, 
    transparent 47%, rgba(0,0,0,0.08) 47%,
    rgba(0,0,0,0.08) 53%, transparent 53%);
}
.wkn-label { position: absolute; top: 3px; left: 4px; }
.wkn-num    { position: absolute; top: 36%; left: 50%; transform: translate(-50%,-50%); }
.wkn-suffix { position: absolute; bottom: 3px; right: 4px; }
```

## 设计风格定位

移动端优先的教师课表工具，追求简洁清爽的卡片式布局。本次为5项微调优化，不改变整体设计语言，而是精修视觉细节使其更接近参考样图的精致感。

## 页面规划（单页面微调）

### Block 1: 表头区域 — 斜线周次 + 紧凑日期

- **左列（第X周）**: 从垂直堆叠改为斜线表头效果。"第"(左上小字) / 数字(居中大字粗体) / "周"(右下小字)，对角细线分割
- **右侧各列（周X+日期）**: 周X标题紧凑排列，下方5px间距显示日期(MM-DD格式)。今天列用绿色"今天"替代日期
- **视觉特征**: 白色卡片头部，与下方内容卡片一体衔接

### Block 2: 课表主体 — 透明背景+分段卡片

- **整体背景**: 完全透明，透出项目底色#F9FCF6
- **分段卡片**: 上午一个白色圆角卡片、下午一个白色圆角卡片，块间有间隙
- **节次标签**: 左侧节次数字无底色装饰，纯文字显示于透明背景上
- **课程卡片**: 保持原有彩色圆角卡片(.week-card)不变

### Block 3: 底部导航 — 方形圆角按钮

- **按钮样式**: 从完全圆形胶囊(border-radius:99px)改为方形圆角(10px)
- **布局**: 三等分横向排列，与上方卡片风格统一
- **交互**: hover态边框变色+微微上浮阴影

## 响应式设计

- **移动端 (≤600px)**: 斜线表头压缩高度、字号缩小；按钮圆角8px
- **桌面端 (≥601px)**: 斜线表头舒展、大字突出；按钮圆角10px

## Agent Extensions

### Skill

- **frontend-design**
- Purpose: 提供专业的视觉设计指导，确保斜线表头、间距调整、圆角统一等细节符合现代前端设计标准
- Expected outcome: 输出精致且一致的UI微调方案，避免模板化的默认选择

- **ui-ux-pro-max**
- Purpose: 利用161种配色方案和UX规范验证圆角一致性、触摸目标尺寸、对比度等关键指标
- Expected outcome: 确保5项调整后的交互体验符合专业级质量标准