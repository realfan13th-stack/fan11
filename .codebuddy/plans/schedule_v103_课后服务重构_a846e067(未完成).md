---
name: schedule_v103 课后服务重构
overview: 重构 schedule_v103.html，删除放学时间模块和 dismissal 特殊时段逻辑，将课后服务改为普通时段并新增"托管"分类，修改课程表联动节次逻辑。
design:
  architecture:
    framework: html
  styleKeywords:
    - Minimalism
    - Clean
  fontSystem:
    fontFamily: PingFang SC
    heading:
      size: 32px
      weight: 600
    subheading:
      size: 18px
      weight: 500
    body:
      size: 16px
      weight: 400
  colorSystem:
    primary:
      - "#062E9A"
      - "#073AB5"
      - "#084DCD"
    background:
      - "#F9FAFB"
      - "#FFFFFF"
    text:
      - "#FFFFFF"
    functional:
      - "#000000"
      - "#FFFFFF"
todos:
  - id: modify-data-definitions
    content: 修改数据层定义：CATEGORIES 新增"托管"分类，DEFAULT_SECTIONS 改造课后服务时段为普通时段，修改 mapCategory() 新增"托管"映射
    status: pending
  - id: modify-render-schedule
    content: 修改 renderSchedule() 函数：移除 type==="dismissal" 特殊渲染分支，统一使用普通渲染逻辑
    status: pending
    dependencies:
      - modify-data-definitions
  - id: modify-export-schedule-image
    content: 修改 exportScheduleImage() 函数：移除 dismissal 特殊渲染分支，改为普通时段渲染
    status: pending
    dependencies:
      - modify-data-definitions
  - id: delete-dismiss-functions
    content: 删除特殊函数：renderDismissTime()、getLatestDismissTime()、addDismissRow()、importDismissRows()、normalizeDismissalRows()，并清理所有调用点
    status: pending
    dependencies:
      - modify-data-definitions
  - id: modify-schedule-edit
    content: 修改 renderScheduleEdit() 函数：移除 dismissal 特殊编辑表头（年级列），统一使用项目列；修改 saveScheduleEdit() 移除 dismissal 特殊处理
    status: pending
    dependencies:
      - modify-data-definitions
  - id: modify-validation-and-class-items
    content: 修改 validateScheduleData()、validateScheduleEditLive()、getClassItems()、getClassSectionItems()：移除 dismissal 相关逻辑
    status: pending
    dependencies:
      - modify-data-definitions
  - id: modify-main-status-and-import-export
    content: 修改 updateMainStatus()、getSheetData()、importScheduleRows()、importFile()：移除 dismissal 逻辑，处理旧 Excel 兼容
    status: pending
    dependencies:
      - modify-data-definitions
  - id: add-migration-logic
    content: 在 loadData() 中添加旧数据迁移逻辑：将 type:"dismissal" 时段转为普通时段，grade 字段映射为 name 字段
    status: pending
    dependencies:
      - modify-data-definitions
  - id: cleanup-and-verify
    content: 清理剩余调用点：refreshAll()、init()、removeScheduleSection()、removeScheduleItem()、saveSectionName()、renderClassSchedule() 中的 renderDismissTime() 调用；使用 code-explorer 子代理全面检查所有 dismissal 相关代码是否已清除
    status: pending
    dependencies:
      - add-migration-logic
---

## 需求概述

对 schedule_v103.html 进行作息表模块重构，涉及课表区、课后服务时段、分类体系、课程表联动节次四个方面的修改。

## 核心需求

1. **删除课表区放学时间模块**：移除 HTML 中的 `.dismiss-table` 区块、相关 CSS 样式、以及 `renderDismissTime()` 函数的所有调用和定义
2. **删除课后服务特殊时段（type:"dismissal"）**：移除所有 `sec.type==="dismissal"` 特殊分支逻辑，删除 `normalizeDismissalRows()`、`importDismissRows()` 等专用函数
3. **新建普通时段"课后服务"**：将原有的 dismissal 时段改为普通时段（无 `type` 属性），items 的 `grade` 字段改为 `name` 字段，`category` 改为新增的 `"care"`（托管），新增分类 `CATEGORIES.care`
4. **课程表联动节次修改**：`getClassItems()` 严格按 `category==="class"` 过滤，移除对 `type!=="dismissal"` 的额外过滤（不再需要）

## 数据联动影响范围

- Excel 导入：`importDismissRows()` 删除，旧版 Excel 的"放学接送"sheet 需兼容处理
- Excel 导出：`getSheetData()` 不再生成"放学接送"sheet，"课后服务"归入"作息安排"
- 课程表渲染：`renderClassSchedule()` 移除 `renderDismissTime()` 调用
- 主状态栏：`updateMainStatus()` 移除 dismissal 跳过逻辑
- 初始化：`init()` 和 `refreshAll()` 移除 `renderDismissTime()` 调用
- 数据迁移：`loadData()` 中需将旧数据的 `type:"dismissal"` 时段转为普通时段

## 稳定性保障

- 需处理旧数据兼容：已保存的用户数据中可能有 `type:"dismissal"` 时段，需要迁移逻辑
- 需处理旧 Excel 兼容：旧版 Excel 文件可能有"放学接送"sheet

## 技术栈

- 单文件 HTML 应用（HTML + CSS + JavaScript），无框架
- 使用 XLSX 库处理 Excel 导入导出
- 使用 html2canvas 处理图片导出

## 实现方案

### 总体策略

采用"删除特殊逻辑 + 统一为普通时段 + 新增分类"的策略。核心思路是：把"课后服务"从特殊时段（`type:"dismissal"`）降级为普通时段，使其与其他时段（如"上午""下午"）完全一样地参与所有逻辑，只是分类不同（"托管" vs "上课"）。

### 关键设计决策

**决策1：课后服务时段的字段改造**

- 原 dismissal 时段的 items 使用 `grade` 字段（如"一年级"）
- 改为普通时段后，应使用 `name` 字段（与其他时段一致）
- 默认数据改造：`grade:"一年级"` → `name:"一年级课后服务"`，`category:"class"` → `category:"care"`
- 理由：保持数据结构一致性，减少特殊逻辑

**决策2：课程表节次逻辑**

- 当前 `getClassItems()` 已按 `category==="class"` 过滤
- 移除 `sec.type!=="dismissal"` 过滤后，逻辑更简洁
- 节次数 = `getClassItems()` 返回的数组长度，与用户需求"有几个上课就有几节课"一致

**决策3：旧数据兼容**

- 在 `loadData()` 中添加迁移逻辑：遍历所有 sections，若 `sec.type==="dismissal"`，则移除 `type` 属性，将 items 的 `grade` 映射为 `name`，`category` 设为 `"care"`
- 这样旧用户数据能自动迁移，无需手动操作

**决策4：Excel 导入兼容**

- 删除 `importDismissRows()` 函数
- 在 `importFile()` 中，若读到"放学接送"sheet，将其作为普通"作息安排"数据处理（即归入 `importScheduleRows()`）
- 旧版 Excel 的 9 列格式中，若 `type` 列值为"放学接送"，则忽略该特殊类型，按普通数据处理

### 性能考虑

- 本次改动主要是逻辑删除和简化，不会引入性能问题
- `loadData()` 中的迁移逻辑只在数据加载时执行一次，开销可忽略

### 风险规避

- 每一步修改后，用 `try-catch` 包裹关键渲染函数，避免单次报错导致整个应用白屏（已有此模式）
- 修改前已备份文件为 `schedule_v103_backup_before_bento.html`
- 建议修改完成后，在浏览器中全面测试：切换夏令/冬令、编辑作息表、导入旧版 Excel、导出 Excel、查看课程表联动

## 实现注意事项

1. **CSS 修改**：已部分完成（`.dismiss-table` 等样式已替换为 `.cat-care`）
2. **HTML 修改**：需删除第980-983行的 `.dismiss-table` 区块
3. **JavaScript 修改顺序**：

- 先改数据定义（CATEGORIES、DEFAULT_SECTIONS）
- 再改渲染函数（renderSchedule、exportScheduleImage）
- 然后删除特殊函数（renderDismissTime、addDismissRow 等）
- 最后修改调用点（refreshAll、init 等）

4. **旧数据迁移代码**：放在 `loadData()` 中 `normalizeDismissalRows()` 调用的位置（第1299行）

## 架构设计

单文件应用，无复杂架构。修改遵循现有模式：

- 数据层：修改 `DEFAULT_SECTIONS_SUMMER`/`WINTER` 和 `CATEGORIES`
- 渲染层：修改 `renderSchedule()`、`exportScheduleImage()` 等
- 编辑层：修改 `renderScheduleEdit()`、`saveScheduleEdit()` 等
- 导入导出层：修改 `getSheetData()`、`importScheduleRows()` 等

## 目录结构

单文件 `schedule_v103.html`，所有修改在此文件内完成。

## 设计风格

由于本次改动不涉及新 UI 创建或重大 UI 改造，主要是逻辑重构，因此不需要全新的 UI 设计。

但需要注意的 UI 细节：

1. **课后服务时段在作息表编辑面板中的显示**：改为普通时段后，编辑表格中应使用"项目"列（而非"年级"列），显示 `name` 字段
2. **课后服务时段在作息表主视图中的显示**：改为普通渲染逻辑后，会显示 `start—end` 时间格式（与其他时段一致）
3. **分类标签颜色**：新增的 `.cat-care` 样式已在 CSS 中定义（绿色系 `#e8f5e9` 背景 + `#2e7d32` 文字）

## 视觉验证要点

修改完成后，需验证：

1. 课表区不再显示"放学时间"模块
2. 作息表主视图中"课后服务"时段正常显示（与普通时段一样）
3. 作息表编辑面板中"课后服务"时段可正常编辑（使用项目/开始/结束/分类/备注列）
4. 课程表节次与"上课"分类的数量一致
5. Excel 导出文件中只有"作息安排"sheet，无"放学接送"sheet

## Agent Extensions

### SubAgent

- **code-explorer**
- 用途：在修改前，对需要修改的每个函数进行精确的行号定位和内容确认，避免改错位置
- 预期结果：获得所有需要修改的代码段的精确行号和上下文，确保修改准确无误