---
name: ui-reference-redesign-plan
overview: 参考例图的圆角卡片轻量化风格，优先改造晚托图(as-calendar)渲染样式，使其视觉更通透、现代；同时给出周视图可选改进方案
design:
  architecture:
    framework: html
  styleKeywords:
    - 轻量卡片式
    - 柔和粉彩配色
    - 大圆角(10-14px)
    - 大量留白
    - 无边框/极简描边
    - 移动端优先
  fontSystem:
    fontFamily: PingFang SC
    heading:
      size: 20px
      weight: 700
    subheading:
      size: 15px
      weight: 600
    body:
      size: 13px
      weight: 400
  colorSystem:
    primary:
      - "#5B8C76"
      - "#7BAF94"
      - "#A8D5BA"
    background:
      - "#FAFBFC"
      - "#FFFFFF"
      - "#F5F7F5"
    text:
      - "#2D3436"
      - "#636E72"
      - "#B2BEC3"
    functional:
      - "#55EFCE"
      - "#FAB1A0"
      - "#DFE6E9"
      - "#74B9FF"
todos:
  - id: analyze-and-confirm
    content: 输出完整分析报告：例图UI拆解 + 周/晚托对比判定 + 两阶段改造路线图，等待用户确认方向
    status: completed
  - id: redesign-week-header
    content: 使用 [skill:frontend-design] [skill:ui-ux-pro-max] 重构周视图头部为「第N周 + 星期日期横排」布局，替换当前箭头导航
    status: completed
    dependencies:
      - analyze-and-confirm
  - id: redesign-week-card-css
    content: 使用 [skill:ui-ux-pro-max] 重写周视图 td 样式：有课→圆角卡片(学科配色)，空→完全透明，左侧节次标签圆角化
    status: completed
    dependencies:
      - analyze-and-confirm
  - id: adapt-week-renderer
    content: 修改 renderWeekView() JS 逻辑：td 内部 DOM 从纯文字改为卡片结构（课程名+班级名包裹在 card 容器中）
    status: completed
    dependencies:
      - redesign-week-card-css
  - id: add-bottom-nav
    content: 添加三等分底部导航按钮「上一周/本周/下一周」，替换当前顶部箭头导航
    status: completed
    dependencies:
      - redesign-week-header
  - id: refine-afterschool-style
    content: 阶段二：借鉴例图轻量化原则优化晚托图 as-cell 样式，减轻边框密度和视觉突兀感
    status: completed
    dependencies:
      - redesign-week-card-css
---

## 产品概述

分析参考例图的 UI 设计风格，判断其最佳应用场景（周视图 vs 晚托图），并制定改造计划。

## 例图 UI 特征深度解析

参考例图是一个**课程表周视图**（节次 x 星期），核心视觉元素如下：

| 元素 | 描述 | 视觉特征 |
| --- | --- | --- |
| 顶部头部 | 左「第18周」+ 右「周一~周日」横排带日期 | 「今天」绿色高亮 |
| 课程卡片 | 圆角矩形色块，含课程名(主)+班级名(副) | 灰蓝色/粉色系柔和配色，无描边或极细描边，border-radius 约 10-12px |
| 空白单元格 | 完全透明 | 无背景、无边框、无内容 |
| 左侧标签列 | 纯数字节次 (1-9) | 浅灰背景圆角容器 |
| 区域分隔 | 第4节和第5节之间有明显的空白间隔 | 区分上午/下午/晚上 |
| 底部导航 | 三等分按钮「上一周 / 本周 / 下一周」 | 圆角胶囊按钮 |


## 核心需求

1. 判断例图风格最适合应用在**周视图**还是**晚托图**
2. 给出合理的分析与判断理由
3. 制定详细的 UI 改造计划供用户调整

## 核心功能

- 周视图：将当前纯文字表格升级为卡片式课程块布局
- 晚托图：借鉴例图的视觉语言减轻「突兀」感
- 两处改造的优先级排序与分阶段实施建议

## 技术栈

- 纯 HTML + CSS + JavaScript（单文件 schedule_v103.html）
- 无框架依赖，无构建工具
- CSS 变量系统 (`var(--card)`, `var(--border)` 等)
- 响应式设计（`@media` 断点: 600px / 768px）

## 实施方案

### 方案选择判断：例图最适合用在「周视图」

**核心理由：数据结构完全匹配**

| 对比维度 | 例图 | 当前周视图 | 当前晚托图 |
| --- | --- | --- | --- |
| 布局结构 | 节次行 × 星期列 | 节次行 × 星期列 (`renderWeekView`) | 月历网格 (`renderAfterSchool`) |
| 单元格含义 | 某天某节的课程 | 某天某节的课程 | 某天的晚托教师 |
| 数据维度 | 二维(时间×星期) | 二维(时间×星期) | 一维(日期序列) |
| 卡片语义 | 课程卡片 | 可映射为课程卡片 | 不适用(是教师标签非课程) |


**结论：例图本质就是周视图的理想形态。晚托图可借鉴其视觉语言（去重边框、柔化色彩），但无法直接套用布局模式。**

### 改造策略：两阶段实施

#### 阶段一（推荐优先）：周视图卡片化改造

目标：将当前纯文字 `<table>` 升级为接近例图的卡片式布局。

**改动范围：**

1. **头部重构** — 将当前的 `← 本周 →` + date input 替换为例图风格的「第N周」+ 星期日期横排头部
2. **表格样式重写** — `td` 从文字容器变为卡片容器：

- 有课程的 td → 圆角卡片（背景色按学科/类别区分），内含课程名 + 班级名
- 空 td → 完全透明（去掉 border 和 background）

3. **新增学科配色体系** — 为不同课程类型定义柔和的背景色（类似例图的灰蓝/粉色系）
4. **左侧节次标签** — 浅色背景圆角容器
5. **区域分隔** — section-divider 行增加上下留白
6. **底部导航** — 三等分按钮替代当前箭头导航
7. **JS 渲染适配** — `renderWeekView()` 的 td 内部 HTML 结构需调整为卡片 DOM

#### 阶段二（可选）：晚托图视觉优化

借鉴例图的「轻量化」原则缓解突兀感：

1. `.as-cell` 边框从实心改为更淡或去除
2. 空 cell 背景透明化
3. `.teacher-name` 标签增大圆角、使用柔和配色
4. 整体 gap 和 padding 微调降低密度感

### 架构影响分析

**需要修改的位置（schedule_v103.html）：**

- **CSS**: ~1057-1179 行（周视图全部样式）+ ~352-469 行（晚托图样式）+ ~898-901 行（as-tag 样式）
- **HTML**: ~1398-1414 行（周视图容器结构）
- **JS**: ~2298-2395 行（renderWeekView 渲染函数）
- **不影响**: Tab Bar、PWA 配置、数据模型、其他 tab 页面

### 关键技术决策

1. **保持 `<table>` 布局而非改用 CSS Grid** — 表格在等宽列对齐方面仍有优势，且改动范围最小；通过 CSS 让 td 表现为卡片即可
2. **学科配色方案** — 新增 6-8 种预定义柔和色（复用现有 `.subject-*` 配色的低饱和度版本）
3. **响应式兼容** — 移动端卡片高度自适应，字体缩小但不改变卡片比例
4. **向后兼容** — 点击弹窗逻辑 (`openWeekCellPopup`) 保持不变，仅调整触发元素

### 目录结构

```
schedule-workbench/
├── schedule_v103.html          # [MODIFY] 唯一修改文件
│   ├── CSS ~1057-1179          # [MODIFY] 周视图样式全面重写
│   ├── CSS ~352-469, ~898-901  # [MODIFY] 晚托图样式微调（阶段二）
│   ├── HTML ~1398-1414         # [MODIFY] 周视图头部/底部结构调整
│   └── JS ~2298-2395           # [MODIFY] renderWeekView 卡片渲染逻辑

## 设计方案：卡片式周视图

### 整体风格定位

采用例图的「轻盈卡片」风格——大量留白 + 圆角色块 + 柔和配色。与当前项目的教师作息工具场景高度契合。

### 设计风格

- **关键词**: 轻盈卡片、柔和色系、圆润友好、信息层级清晰
- **氛围**: 干净、现代、不拥挤、一眼看清本周安排
- **参考**: 接近 Apple Calendar / Google Calendar 的周视图卡片风格，但更简洁

### 页面规划（1屏：周视图主页面）

**Block 1: 头部信息栏**

- 左侧：「第N周」大号数字 + 小字「周」
- 右侧：周一~周日横排，每列上方星期名下方日期，「今天」绿色高亮
- 背景：白色/浅色，无明显分割线
- 高度约 56-64px

**Block 2: 课程网格主体**

- 左侧固定列：节次号 (1-9)，浅灰色圆角背景
- 主体区域：7列 × N行，每个单元格：
- 有课 = 圆角卡片（宽约占 cell 的 90%），柔和底色，居中显示课程名 + 班级名
- 无课 = 完全透明
- 区域分隔行（上午/下午/晚上之间）：增加 12-16px 间距

**Block 3: 底部导航条**

- 三等分按钮：「上一周」|「本周」（高亮态）|「下一周」
- 圆角胶囊形，柔和描边
- 高度约 44px

### 晚托图微调（阶段二）

- 去除 .as-cell 的重边框，改用极细分隔线或阴影
- 空白日 cell 透明化
- teacher-name 标签增大圆角至 8px，使用更柔和的色调

## Agent Extensions

### Skill: frontend-design

- **Purpose**: 提供专业的视觉设计指导，确保新的卡片式周视图符合现代 UI 设计规范
- **Expected outcome**: 产出符合例图风格的配色方案、间距规范、圆角参数等具体设计 token

### Skill: ui-ux-pro-max

- **Purpose**: 提供 UI/UX 最佳实践验证，确保改造后的交互体验（点击卡片、滑动导航）流畅自然
- **Expected outcome**: 验证卡片触摸区域大小、响应式断点行为、视觉层级合理性

### Skill: brainstorming

- **Purpose**: 在设计决策前充分发散思路，探索多种可能的实现路径
- **Expected outcome**: 确认方案选择的合理性，避免遗漏更好的替代方案

### SubAgent: code-explorer

- **Purpose**: 在执行阶段深入搜索所有受影响的样式规则和 JS 依赖，确保无遗漏
- **Expected outcome**: 完整的影响范围清单，防止遗漏联动的样式/逻辑修改