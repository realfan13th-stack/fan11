---
name: phase2-after-school-card-upgrade
overview: 阶段二：晚托图视觉轻量化升级——将当前整格色块渲染升级为卡片式风格，降低视觉密度，增加空间呼吸感，同步优化导出图渲染。
design:
  architecture:
    framework: html
  styleKeywords:
    - 柔和卡片浮起
    - 极细彩色侧条
    - 14px 统一圆角
    - 双阴影层次
    - 粉彩底 + 白卡片
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
      - "#597AB5"
      - "#3B82F6"
    background:
      - "#FFFFFF"
      - "#FEFCF4"
      - "#F1F5F9"
    text:
      - "#24324B"
      - "#64748B"
      - "#FFFFFF"
    functional:
      - "#639148"
      - "#64748B"
      - "#59,122,181"
todos:
  - id: explore-current-state
    content: 确认当前晚托图 CSS/JS 的最新状态，精确定位所有修改行号
    status: pending
  - id: redesign-cell-css
    content: 使用 [skill:frontend-design] 重写 .as-cell 核心样式：border-radius 14px、box-shadow 双阴影、教师 cell 改为白色底+border-left 色条
    status: pending
    dependencies:
      - explore-current-state
  - id: refine-special-marks
    content: "使用 [skill:ui-ux-pro-max] 验证并调整特殊标记：节假日标记圆角化、不托色柔化 #E2E8F0→#F1F5F9、统一 14px 圆角"
    status: pending
    dependencies:
      - redesign-cell-css
  - id: fix-weekend-logic
    content: 移除全局 .as-cell.weekend opacity:0.45，改为 JS 渲染时仅对无计划周末附加 opacity:0.55
    status: pending
    dependencies:
      - redesign-cell-css
  - id: update-responsive
    content: 同步更新移动端（第797行）和平板端（第859行）响应式样式：gap/padding/字号适配
    status: pending
    dependencies:
      - redesign-cell-css
  - id: sync-export-rendering
    content: 同步更新 exportAfterSchoolImage 函数中的 td 渲染逻辑，采用一致的卡片化样式
    status: pending
    dependencies:
      - redesign-cell-css
      - fix-weekend-logic
  - id: verify-and-commit
    content: 使用 [skill:verification-before-completion] 验证修改无 lint 错误，提交并推送至远程仓库
    status: pending
    dependencies:
      - sync-export-rendering
      - update-responsive
      - refine-special-marks
---

## 改造背景

晚托图已在上次迭代完成"整格色块化"改造（教师单元格纯色填充、无文字、白色日期），当前视觉偏厚重，需向参考例图的"轻盈卡片"风格看齐。

## 核心改造目标

1. **降密度**：教师整格色块从 100% 实心改为"卡片叠层"视觉——浅色半透明底 + 细边框 + 轻微阴影，教师色仅作为左侧色条或淡底色提示，避免色块过于占据视觉权重
2. **增呼吸**：桌面端 grid gap 从 6px 增大到 8px，cell padding 从 3px 增大到 5px，cell border-radius 从 12px 统一到 14px
3. **柔色彩**：节假日 `#FEFCF4` 保持不变（已足够柔和），不托 `#E2E8F0` 降为 `#F1F5F9`，周末空单元格透明度从全局 `opacity:0.45` 改为仅默认无计划时生效
4. **统圆角**：holiday-mark 圆点、as-none-mark、as-week-note 统一 14px 圆角体系
5. **导出同步**：exportAfterSchoolImage 的 td 渲染逻辑同步采用卡片化样式

## 视觉效果预期

- 教师日单元格：白色/浅灰底 + 左侧 3px 宽教师色竖条 + 14px 圆角 + 极细阴影，日期数字保持主色 `#24324b`
- 节假日单元格：`#FEFCF4` 暖底保持一致，绿色标记加大圆角
- 不托单元格：`#F1F5F9` 冷灰底，灰色文字
- 周末空单元格：轻微透明而非完全淡化，保留可读性
- 全体 cell 统一 14px 圆角 + 细微 `box-shadow` 实现卡片浮起感

## 技术方案

### 改造策略

不引入外部库，纯 CSS + JS 内联样式字符串替换。核心思路：将教师单元格从"纯色实心块"改为"白色卡片 + 教师色侧条 + 细阴影"，保留色彩识别能力但大幅降低视觉重量。

### 关键设计决策

1. **教师色侧条方案**：使用 CSS `border-left:3px solid <teacherColor>` 代替 `background:<teacherColor>` 整格填充。这比纯色填充更轻盈，同时保留教师色辨识度。白色底 + 彩色侧条是 shadcn/ui 卡片组件的常见模式。

2. **阴影层次**：`box-shadow: 0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04)` 双阴影实现轻微卡片浮起感——符合 frontend-design 技能强调的"make one memorable choice"原则（卡片浮起即为晚托图的 signature）。

3. **周末盲降处理**：移除全局 `.as-cell.weekend { opacity:0.45 }`，改为在 JS 渲染时：仅当 cell 无计划（非节假日/非不托/非教师）且为周末时，添加 `opacity:0.55` 内联样式。这样节假日/不托/有教师的周末不再被错误淡化。

4. **圆角统一 14px**：所有单元格、标记标签统一 `border-radius:14px`（原 12px 各处不一致），形成贯穿的圆角语言。

5. **不托色柔化**：`#E2E8F0`（Tailwind slate-200）降为 `#F1F5F9`（slate-100），与"轻量"主题一致。

### 响应式适配

- 移动端 `@media(max-width:600px)`：gap 4→6px，padding 3→4px，保持紧凑
- 平板 `@media(min-width:768px)`：gap 保持 8px，padding 继承桌面

### 导出图同步

导出图 `exportAfterSchoolImage` 函数中 td 渲染与主视图保持一致：教师 td 白色底 + border-left 色条 + 细阴影 + 白色/深色日期数字。

### 不修改的部分

- `.as-calendar .as-cell.today` 蓝色内圈（已优化过，视觉足够）
- 教师颜色数据（`appData.afterSchool.teachers`）
- `editAssignment` 点击交互
- `.as-week-note` 周次列样式
- `.as-header` 表头样式

## 设计风格

采用"柔和卡片浮起"语言——整体为极简粉彩底 + 白色卡片 + 极细彩色侧条 + 细微阴影层次。灵感来自 shadcn/ui 的 card 组件语义和例图的圆角留白体系。

## 页面模块（晚托图单屏）

### Block 1：顶部控制栏

现有学期栏（已去卡片化）+ 月份 Tab + 教师图例（已放大），保持不变。

### Block 2：日历网格主体

- 白色/浅灰底 cell，14px 圆角
- 教师 cell：白色底 + 左侧 3px 彩色竖条 + `box-shadow` 浮起
- 节假日 cell：暖米色底 `#FEFCF4` + 绿色标记
- 不托 cell：冷灰色底 `#F1F5F9` + 灰色文字
- 默认空 cell：透明底，无阴影
- 网格 gap 8px，整体呼吸感

### Block 3：底部图例统计

保持现有放大后的样式。

## 使用的技能

### Skill: frontend-design

- **用途**：指导教师色侧条的视觉表达——参考 shadcn/ui card 组件的侧边色条语义，生成精确的 CSS 阴影层次和圆角比例，确保"卡片浮起"成为晚托图的 signature 元素
- **预期结果**：产出教师 cell 的完整 CSS（白色底 + border-left 色条 + 双阴影），以及 hover 微交互（如有）

### Skill: ui-ux-pro-max

- **用途**：验证圆角统一 14px 体系、对比度（白底 + 彩色文字可达标 4.5:1）、间距系统（4/8dp 韵律）是否符合 UX 最佳实践
- **预期结果**：确认夜间模式兼容性、移动端 touch-target 尺寸（cell ≥44px）、焦点可见性

### Skill: using-superpowers

- **用途**：确保技能加载顺序和使用纪律，先加载 frontend-design 再做设计决策，再调 ui-ux-pro-max 做质量验证
- **预期结果**：按正确流程执行，避免跳过关键设计审查