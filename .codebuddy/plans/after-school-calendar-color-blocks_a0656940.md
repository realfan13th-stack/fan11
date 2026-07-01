---
name: after-school-calendar-color-blocks
overview: 晚托日历单元格全面色块化改造：去除教师名文字改用整格纯色块、节假日/不托增加整格色块并推荐颜色、上方教师统计名字加大、周次列恢复默认"第N周"格式。
todos:
  - id: refine-css-core
    content: 使用 [skill:frontend-design] 和 [skill:ui-ux-pro-max] 改造 CSS 基础样式区（~452-471行）：修改 .day-num 颜色继承、删除 .teacher-name 样式块、改 .today 为内发光、更新 .holiday-mark/.as-none-mark 颜色
    status: completed
  - id: refine-legend-css
    content: 改造图例样式（~417行）：as-legend-item 字号从 clamp(10px,1.1vw,13px) 提升到 clamp(12px,1.3vw,15px) + font-weight:500
    status: completed
  - id: sync-css-overlay
    content: 同步更新覆盖层 CSS（~894-901行）：删除 teacher-name 二次覆盖、更新 holiday-mark/as-none-mark 样式
    status: completed
    dependencies:
      - refine-css-core
  - id: sync-css-responsive
    content: 同步更新响应式 CSS：移动端 ~808-811行、~817-818行 和 平板端 ~871-873行，删除 teacher-name 引用、更新 legend 响应式
    status: completed
    dependencies:
      - refine-css-core
      - refine-legend-css
  - id: refine-js-render
    content: 改造 JS 单元格渲染（~3004-3014行）：教师改为整格 background+color 内联样式、节假日加 background:#FEF3C7、不托加 background:#E2E8F0+color:#64748B
    status: completed
    dependencies:
      - refine-css-core
  - id: restore-week-note
    content: 恢复周次列默认格式（~2995行）：defaultNote 从 String(wn) 改回 "第"+wn+"周"
    status: completed
---

## 用户需求

1. 晚托模块每个日期下去除教师名文字，只保留纯颜色色块，色块覆盖整个数字格子区域（整格填充+圆角），纯色方便辨认
2. "节假日"、"不托"文字保留，但也增加整个单元格的色块背景，与教师单元格风格统一
3. 上方教师统计区域（as-legend）名字调稍大一些
4. 周次列保持当前纯数字格式（不改回）
5. 完成后同步 GitHub + 更新记忆

## 节假日配色（用户指定）

- 背景：`#FEFCF4`（暖象牙白）
- 文字 + 圆点：`#639148`（植物绿）
- 圆点伪元素保留，颜色与文字一致

## 核心改造

将晚托图从"透明网格+彩色子元素"模式升级为"整格纯色填充"模式——教师单元格整格填充教师颜色+白色日期数字、节假日/不托单元格整格填充统一背景色+保留文字标签、图例名字放大。

## 技术方案

### 改造策略：CSS主导 + JS渲染模板微调

不改数据结构、不改交互逻辑、不改弹窗编辑模块。仅通过 CSS 样式重设和 JS 内联样式注入实现整格填充效果。

### 核心设计决策

**决策1：教师单元格用 as-cell 自身 background 替代 teacher-name 子元素**

- 之前：`.as-cell` 透明 → 内嵌 `.teacher-name` 色条子 div
- 之后：`.as-cell` 直接设 `background: 教师色; color: #fff`，只保留 `.day-num` 子元素
- 理由：消除冗余 DOM 层级，整格填充圆角自动继承 as-cell 的 `border-radius:12px`

**决策2：节假日/不托单元格采用固定背景色**

- 节假日：`#FEFCF4`（暖象牙白）+ 文字 `#639148`（植物绿），圆点保留同色
- 不托：`#E2E8F0`（slate-200 中性灰）+ 文字 `#64748B`（slate-500）
- 理由：暖象牙白柔和自然传达"特殊日"，绿字+绿点保持节假日识别性；中性灰传达"无安排"

**决策3：today 标记从背景色改为内发光**

- 之前：`.as-cell.today { background: rgba(89,122,181,0.06) }`
- 之后：有内容 today 单元格加 `box-shadow: inset 0 0 0 3px rgba(255,255,255,0.4)`
- 理由：整格填充后背景已被教师/节假日/不托色占用，改为内发光不受背景色影响

### 性能考量

- 减少每个教师单元格 1 个 DOM 子节点（移除 teacher-name div）
- 每屏约 35 个有效单元格，节省 ~35 个 DOM 节点
- 无 layout shift 风险（单元格已有固定 min-height）

### 受影响文件区域（共8处）

| 区域 | 行号 | 改动类型 |
| --- | --- | --- |
| CSS 基础 .as-cell 块 | ~452-471 | 修改 .day-num 继承颜色、删除 .teacher-name、改 today、更新 holiday-mark/as-none-mark |
| CSS 基础 .as-legend | ~417 | 加大字号+weight |
| CSS 覆盖层 | ~894-901 | 同步更新 teacher/holiday/none 样式 |
| CSS 移动端响应式 | ~808-811 | 删除 teacher-name 响应式 |
| CSS 移动端 legend | ~817-818 | 更新 legend 响应式 |
| CSS 平板响应式 | ~871-873 | 删除 teacher-name 响应式 |
| JS 单元格渲染 | ~3004-3014 | 改 teacher-name 为整格背景、加 holiday/none 背景 |


## Agent Extensions

### Skill

- **frontend-design**
- Purpose：指导颜色选择（节假日/不托整格背景色推荐），确保视觉风格一致不撞色
- Expected outcome：产生暖黄 #FEF3C7 + 中性灰 #E2E8F0 的配色方案，与教师色无冲突

- **ui-ux-pro-max**
- Purpose：验证 accessibility contrast（白色日期数字在教师色背景上的对比度）、today 内发光方案的视觉层级
- Expected outcome：确保所有文字/背景组合满足 WCAG AA 4.5:1 对比度要求