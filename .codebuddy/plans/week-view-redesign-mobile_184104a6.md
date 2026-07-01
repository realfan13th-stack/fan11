---
name: week-view-redesign-mobile
overview: 移动端周视图UI重构：复刻样图布局——删除表头行、第X周移入表格头、日期/星期合入表头、空格白底化、分时段白色块卡片化
design:
  architecture:
    framework: html
  styleKeywords:
    - Minimalism
    - Card-based Layout
    - Breathing Space
    - Pastel Subject Colors
    - Clean Typography
    - Mobile-first
    - No-decoration
  fontSystem:
    fontFamily: "'Inter','PingFang SC','Microsoft YaHei',sans-serif"
    heading:
      size: 18px
      weight: 700
    subheading:
      size: 14px
      weight: 600
    body:
      size: 13px
      weight: 400
  colorSystem:
    primary:
      - "#4E648A"
      - "#597AB5"
      - "#16A34A"
    background:
      - "#F9FCF6"
      - "#FFFFFF"
    text:
      - "#69697C"
      - "#24324B"
      - "#1D1D1F"
    functional:
      - "#F8C899"
      - "#E2E8F0"
      - "#16A34A"
todos:
  - id: cleanup-debug-code
    content: 清理 switchClassTab 和 renderWeekView 中的诊断调试代码，恢复函数到干净状态
    status: completed
  - id: css-bg-transparent
    content: "设置 #classWeekly 背景透明露出 --bg，td 底色改白，新增 .wk-empty-cell 占位样式"
    status: completed
  - id: refactor-header-into-thead
    content: 重构 renderWeekView：删除独立 headerHtml，将"第N周"(去后缀)+周X+日期合并写入 thead 单行
    status: completed
    dependencies:
      - cleanup-debug-code
  - id: refactor-body-section-cards
    content: 重构 bodyHtml：每 section 用 wk-section-first/wk-last 标记首末行，空格加占位 div，实现 CSS 伪元素白色卡片效果
    status: completed
    dependencies:
      - css-bg-transparent
      - refactor-header-into-thead
  - id: css-section-card-styling
    content: 编写分段白色卡片 CSS：首末行圆角、section间距、表头样式、移动端响应式适配，复刻样图的块状摆放
    status: completed
    dependencies:
      - refactor-body-section-cards
  - id: verify-and-test
    content: 验证：检查 lint 错误、确认移动端渲染效果、测试点击交互（周备注弹窗/单元格弹窗/导航按钮）完整性
    status: completed
    dependencies:
      - css-section-card-styling
---

## 产品概述

移动端教师作息工作台的「周视图」标签页UI重构，参考用户提供的目标样图，将当前周视图从"表头+表格+底部导航"的传统布局改造为"分时段白色卡片块+合并表头+透出项目背景色"的现代布局。

## 核心功能需求

### 1. 格子底色白化（当前灰色→白色）

- 当前 `.weekly-grid td` 背景色为 `#F5F7FA`（浅灰）
- 目标：所有单元格背景改为白色/透明，没课的格子与有课格子等高

### 2. 空格等高处理

- 当前空 `td` 内部无内容，高度由 padding 撑开但不稳定
- 目标：空格子内部添加占位 div，确保与有课 `.week-card` 高度一致

### 3. "第X周"后缀去除

- 当前代码 2428 行：`weekDisplay = noteFromAfterSchool || ('第'+weekNum+'周')`
- 第 2432 行：当没有自定义备注时额外追加 `<span class="week-title-suffix">周</span>`
- 目标：显示"第18"即可，不显示多余的"周"

### 4. 删除独立表头行 + 日期星期合入列头

- **删除**：当前 `#weeklyGridHeader` 中渲染的 `"一 二 三 四 五"` 单独行
- **删除**：`#weeklyHeader` 独立的头部区域（week-title-area + week-date-row）
- **合并**：将"第X周"放入表格第一列的 th 中；将"周一~周五"+"日期(06-30格式)"+"今天标记"放入各日期列的 th 中
- 样图效果：表头行 = `[第18周] | [周一 今天\n06-30] | [周二\n07-01] | ...`

### 5. 页面白底去除 → 露出项目背景色

- 当前 `.right-panel` (275行) 的 `background:var(--card)` 即 `#FFFFFF`
- `.class-subpanel` 继承此白色背景
- 目标：对 `#classWeekly` 设 `background:transparent`，露出底层 `--bg: #F9FCF6`

### 6. 分时段白色卡片化（核心视觉变化）

- **上午段**：节次1-N的所有行包裹在一个白色圆角卡片内（带轻微阴影）
- **下午段**：节次N+1-M的所有行包裹在另一个白色圆角卡片内
- 卡片之间有明显间隙（8-12px），间隙处透出 `--bg` 背景
- 区域分隔行（上午/下午文字）改为卡片内的标题或直接移除

## 视觉效果总结（参照样图第二张图）

```
┌────────┬───────┬───────┬──────┐ ← 白色圆角卡片 #1（含表头+上午内容）
│第 18   │ 周一  │ 周二  │ 周三  │
│ 周     │ 今天  │07-01 │07-02 │
├────────┼───────┼───────┤      │
│   1    │       │语文卡 │      │
│        │       │[彩色] │      │
│   2    │       │       │      │
│   3    │       │       │      │
│   4    │       │       │      │
└────────┴───────┴───────┴──────┘ ← 卡片结束
              (间隙 ~10px, 透出#F9FCF6)
┌────────┬───────┬───────┬──────┐ ← 白色圆角卡片 #2（下午内容）
│   5    │ 信技  │       │      │
│        │[彩色] │       │      │
│ ...    │       │       │      │
│   7    │ 信技  │ 信按  │      │
│        │[彩色] │[粉色] │      │
│   8    │       │       │      │
│   9    │       │       │      │
└────────┴───────┴───────┴──────┘
   [上一周]  [●本周]  [下一周]
```

## 技术栈

- **前端框架**: 纯 HTML + 原生 JavaScript（单文件应用 schedule_v103.html）
- **样式方案**: 原生 CSS（内联 `<style>` 标签），使用 CSS 变量系统 (`--bg`, `--card`, `--header` 等)
- **响应式**: 已有 `@media (max-width:600px)` 移动端断点体系

## 实现方案

### 架构决策：保留 table 结构 + CSS 视觉伪装为分块卡片

由于当前渲染逻辑基于 `<table>` 结构，完全重写为 grid/flex 布局会改动过大。采用以下策略：

1. **表格结构保持不变**（thead + tbody + tr/td），但通过 CSS 让每个时段的 tr 组看起来像独立的白色卡片
2. **thead 合并**：将原来的独立 header 区域和表头行合并为一个 thead tr，包含"第N周"+各列"周X+日期"
3. **分段卡片化**：用 CSS 选择器给每个 section 的第一个 tr 和最后一个 tr 添加圆角边框效果；或者用 tbody 分组（每个 section 一个 tbody）来自然实现卡片分组

### 推荐方案：tbody 分组 + CSS 卡片化

- 将每个 section（上午/下午）的内容包裹在独立的 `<tbody>` 中
- 每个 `<tbody>` 渲染为一个白色圆角卡片（CSS: border-radius + background:white + box-shadow）
- 表头（含"第N周"+日期）作为第一个特殊 tbody 或保持在 thead 中但样式融入第一个卡片

## 实现细节

### 修改文件清单

```
schedule_v103.html  [MODIFY] — 唯一需要修改的文件
```

### 具体修改点

#### A. 清理调试代码（回归干净状态）

- `switchClassTab()` (2042-2055行): 移除调试 Banner 创建代码和 console.log
- `renderWeekView()` 开头 (2396-2403行): 移除调试 Banner 创建代码

#### B. CSS 样式变更 (~1069-1247行区域)

| 选择器 | 当前值 | 目标值 | 说明 |
| --- | --- | --- | --- |
| `#classWeekly` | 无(继承white) | `background:transparent` | 露出 --bg |
| `.weekly-grid td` | `background:#F5F7FA` | `background:transparent` 或 `#fff` | 白底 |
| `.weekly-grid-wrap` | 无特殊背景 | 保持不变 | 容器透明 |
| `.weekly-grid` | border-collapse:separate | 保持，增大 spacing | 卡片间间距 |
| `.section-divider td` | transparent 文字 | 改为卡片内标题或隐藏 | 重构 |
| 新增 `.wk-section-card` | N/A | 白色卡片容器样式 | 分段卡片 |
| 新增 `.wk-empty-cell` | N/A | min-height 与 week-card 一致 | 空格等高 |
| `.week-title-suffix` | 显示"周" | `display:none` 或删除生成逻辑 | 去除多余"周" |


#### C. renderWeekView() JS 逻辑重构 (2395-2558行)

**C1. 头部区域重构 (2412-2450行)**

- 删除 `headerHtml` 写入 `#weeklyHeader` 的逻辑
- 将"第N周"(不含后缀"周")移入 thead 第一行的第一个 th
- 将"周X"+"日期"+"今天标记"移入 thead 各列 th
- `#weeklyHeader` div 可留空或移除（不再需要）

**C2. thead 重构 (2452-2461行)**

```javascript
// 新 thead 结构：
// <tr>
//   <th class="wk-week-num-th">第<br>18<br>周</th>          ← 左上角竖排周次
//   <th class="wk-date-th today">周一<br><span class="wd-sm">今天</span><br>06-30</th>
//   <th class="wk-date-th">周二<br>07-01</th>
//   ...
// </tr>
```

**C3. body 重构 — 分段 tbody (2465-2525行)**

```javascript
// 新结构：每个 section 生成一个 tbody.wk-section-tbody
sections.forEach(function(sec, si){
    bodyHtml += '<tbody class="wk-section-tbody" data-section="'+si+'">';
    
    // 第一节的 tr 作为该 section 的首行（包含表头信息时）
    // 或者：第一节前不需要单独的 section-divider 行
    
    sec.items.forEach(function(it){
        // ... 课程渲染逻辑不变 ...
        // 但空格子添加占位div：
        // if(!parsed.main) bodyHtml += '<div class="wk-empty-cell"></div>';
    });
    
    bodyHtml += '</tbody>';
});
```

**注意**: 由于浏览器限制，`<table>` 内部的 `<tbody>` 不能有 margin/border-radius 来形成视觉上的分离卡片。实际可行方案有两种：

**方案A（推荐）：CSS伪元素模拟卡片边界**

- 给每个 section 的首行 tr 的 td 加上 `border-top-left-radius`, `border-top-right-radius` 和上边框
- 给每个 section 的末行 tr 的 td 加上 `border-bottom-left-radius`, `border-bottom-right-radius` 和下边框
- 整个 section 的 tr 共享一个白色背景
- section 之间用 `border-spacing` 或额外的 spacer tr 制造间隙

**方案B：放弃 table，改用 CSS Grid**

- 用 div+grid 完全重写周视图布局
- 更灵活但改动量大

**选择方案A**，因为它最小化改动且能达成视觉效果。

#### D. 关键 CSS 实现（方案A - 伪元素卡片化）

```css
/* 周视图面板透明背景 */
#classWeekly { background: transparent; }

/* 表格基础调整 */
.weekly-grid { 
  border-spacing: 0 0; /* 内部无间距 */
  background: transparent;
}

/* 空单元格 */
.weekly-grid td { 
  background: #FFFFFF !important; /* 白底 */
}
/* 空格子占位 */
.wk-empty-cell {
  display: inline-block; width: 100%; height: 38px; /* 与 week-card min-height 一致 */
}

/* Section 分组：首行顶部圆角 */
.wk-section-first td:first-child { border-top-left-radius: 12px; }
.wk-section-first td:last-child { border-top-right-radius: 12px; }
/* Section 分组：末行底部圆角 */
.wk-section-last td:first-child { border-bottom-left-radius: 12px; }
.wk-section-last td:last-child { border-bottom-right-radius: 12px; }
/* 所有 section 内部 tr 的 td 有白底 */
.wk-section-tbody tr td { background: #fff; }

/* Section 之间的间隔行 */
.wk-section-spacer { height: 10px; }
.wk-section-spacer td { background: transparent !important; padding: 0; border: none; }

/* 表头合并后的样式 */
.wk-week-num-th {
  font-size: 16px; font-weight: 700; color: var(--header);
  text-align: center; line-height: 1.3; vertical-align: middle;
  writing-mode: vertical-lr; /* 竖排 */ /* 或者不用竖排，用正常横排两行 */
}
.wk-date-th {
  text-align: center;
}
.wk-date-th .wd-name { font-size: 13px; font-weight: 600; color: var(--text); }
.wk-date-th .wd-date { font-size: 11px; color: var(--text); opacity: 0.7; }
.wk-date-th.today .wd-name { color: #16A34A; }
```

## 性能与可靠性考虑

- 所有修改限于单一 HTML 文件的 CSS 和 JS 函数
- 不引入外部依赖
- 保持现有数据结构（appData.classSchedule.grid）不变
- 保持 openWeekNotePopup、navigateWeek、openWeekCellPopup 等交互功能兼容
- 移动端 @media 断点需同步更新适配新样式

## 目录结构

```
schedule-workbench/
└── schedule_v103.html  [MODIFY] 周视图 UI 重构的唯一修改文件
    ├── CSS 区域 (~1069-1250行): 新增/修改周视图样式规则
    ├── HTML 区域 (~1465-1480行): #classWeekly 结构微调（可选）
    └── JS 区域 (~2395-2558行): renderWeekView() 函数重构
```

## 设计风格分析

### 样图设计语言解读

目标样图呈现一种**极简卡片式日历风格**，核心特征：

1. **分层呼吸感**：整体背景为浅绿灰色(#F9FCF6)，内容区以纯白色圆角卡片悬浮其上，卡片之间留出充足间隙让背景"透气"
2. **信息密度克制**：去掉一切装饰性元素（分隔线、阴影边框等），只保留最必要的信息——周次、星期、日期、课程名、班级名
3. **色彩仅用于区分学科**：卡片底色采用预定义的柔和粉彩色调（信技=灰蓝#B0BEC5系、信按=粉色#F8BBD0系），其余区域全部黑白灰
4. **排版节奏感**：左侧节次号窄而紧凑，右侧课程区宽阔宽松；表头行信息丰富但不拥挤（周名+日期+今日标记垂直堆叠）

### 页面规划（仅周视图页面，共1个页面）

#### Block 1: 周次+日期合并表头（原 weeklyHeader + weeklyGridHeader 合并）

位于页面最上方，是整个周视图的信息锚点。

- **布局**：一行表格表头，第一列为竖排/横排"第18周"，其余列为"周X\n日期\n[今天]"
- **样式**：白色背景（属于下方上午卡片的顶部），无下划线分割
- **交互**："第18周"可点击弹出编辑周备注弹窗（保留现有功能）

#### Block 2: 上午时段白色卡片（原 section-divider"上午" + 上半部分 tr）

包含上午所有节次（如1-4节）的课程内容。

- **布局**：白色圆角矩形卡片，左边缘有节次号列，右侧为5列课程格子
- **样式**：background:#FFFFFF, border-radius:12px, box-shadow:0 1px 3px rgba(0,0,0,0.04)
- **内容**：有课=彩色圆角卡片(.week-card)；无课=空白等高区域
- **特殊**：不再显示"上午"文字标题（样图中未出现时段名称）

#### Block 3: 间隙区（约10px高度）

两个白色卡片之间的呼吸空间，透出项目背景色#F9FCF6。

#### Block 4: 下午时段白色卡片（原 section-divider"下午" + 下半部分 tr）

结构与上午卡片完全对称。

#### Block 5: 底部导航栏（保留现有 week-bottom-nav）

三个胶囊按钮：上一周 / ●本周 / 下一周，居中排列。

### Skill 使用计划

- **frontend-design**
- Purpose: 提供专业的 UI 视觉设计指导，确保新的周视图布局符合现代移动端设计美学标准
- Expected outcome: 输出的设计方案具有清晰的视觉层次、合理的间距系统和精致的细节处理

- **ui-ux-pro-max**
- Purpose: 提供 UX 最佳实践验证，特别是移动端触控目标尺寸(≥44pt)、字体可读性(≥16px)、颜色对比度(≥4.5:1)等关键指标的检查
- Expected outcome: 确保重构后的周视图在可用性和无障碍方面达到专业水准