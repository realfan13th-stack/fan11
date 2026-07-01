---
name: class-tab-restructure
overview: 重构课表tab：删除个人课表、班级课表改用周视图UI设计、交换tab顺序
todos:
  - id: delete-personal-tab
    content: 删除"个人课表"按钮和显示模块（line 1513, 1517-1526）
    status: pending
  - id: update-class-tab-logic
    content: 修改 switchClassTab() 和 currentClassTab 初始值（line 2132, 2137）
    status: pending
    dependencies:
      - delete-personal-tab
  - id: create-group-weekview
    content: 创建 renderClassGroupWeekView() 函数，重做班级课表显示为周视图UI风格
    status: pending
    dependencies:
      - update-class-tab-logic
  - id: swap-tab-order
    content: 交换tab顺序：周视图 → 班级课表（line 1512-1515）
    status: pending
    dependencies:
      - create-group-weekview
  - id: test-and-sync
    content: 测试所有修改，确认Linter错误为0，同步到GitHub
    status: pending
    dependencies:
      - swap-tab-order
---

## 用户需求

1. **删除"个人课表"tab及显示模块**

- 删除"个人课表"按钮和显示区域
- 保留数据编辑区和导出图片功能（"个人课表"功能可由"周视图"替代）

2. **重做"班级课表"显示区域**

- 采用周视图的UI设计（卡片化风格）
- 表头只显示"周一"至"周五"，不显示日期
- 不显示周次信息
- 下方没有换周的选项
- "上午"、"下午"分节标签不显示
- 保留标题区域

3. **交换tab顺序**

- 将"周视图"tab移到"班级课表"tab左侧
- 新的顺序：周视图 → 班级课表

## 功能内容

- 删除个人课表显示模块，简化界面
- 班级课表采用周视图的卡片化UI设计，提升视觉一致性
- 调整课表tab顺序，将周视图放在更显眼的位置

## 技术方案

### 1. 删除"个人课表"模块

**修改位置**：

- HTML line 1513：删除"个人课表"按钮
- HTML line 1517-1526：删除 `#classPersonal` 整个模块
- JS line 2132：修改 `switchClassTab()` 中的ID映射逻辑
- JS line 2137：修改 `currentClassTab` 初始值为 `"weekly"`

**保留内容**：

- 数据编辑区 (`#dmClass`) 保持不变
- 导出功能保持不变

### 2. 重做"班级课表"显示区域

**创建新渲染函数** `renderClassGroupWeekView()`：

- 参考 `renderWeekView()` (line 2476-2625) 的卡片化设计
- 读取 `appData.classGroupSchedule` 数据
- 渲染表头：只显示"周一"至"周五"
- 渲染表格主体：使用 `.week-card` 样式显示课程卡片
- 不显示周次、日期、分节标签
- 不显示底部导航按钮

**修改HTML结构**：

- 为 `#classGroup` 创建新的容器结构，类似 `#classWeekly`
- 保留 `#classGroupScheduleTitle` 标题区域

**CSS样式**：

- 复用 `.week-card` 样式
- 可能需要微调 `.wk-empty-cell` 等样式

### 3. 交换tab顺序

**修改HTML** (line 1512-1515)：

```html
<div class="class-subtabs" id="classSubtabs">
  <button class="class-subtab active" data-csub="weekly" onclick="switchClassTab('weekly')">周视图</button>
  <button class="class-subtab" data-csub="group" onclick="switchClassTab('group')">班级课表</button>
</div>
```

**修改JS** (line 2132)：

- 更新ID映射逻辑：`p.id==="class"+(tab==="weekly"?"Weekly":tab==="group"?"Group":"Personal")`

### 4. 关键代码位置

| 功能 | Line Number |
| --- | --- |
| `#classSubtabs` 按钮 | 1512-1515 |
| `#classPersonal` 模块 | 1517-1526 |
| `#classGroup` 模块 | 1527-1536 |
| `#classWeekly` 模块 | 1538-1552 |
| `switchClassTab()` | 2129-2136 |
| `currentClassTab` 初始值 | 2137 |
| `renderClassGroupSchedule()` | 2360-2405 |
| `renderWeekView()` (参考) | 2476-2625 |
| `.week-card` 样式 | 1171-1183 |


## 实现步骤

1. 删除"个人课表"按钮和显示模块
2. 修改 `currentClassTab` 初始值和 `switchClassTab()` 函数
3. 创建 `renderClassGroupWeekView()` 函数
4. 修改 `#classGroup` 的HTML结构
5. 交换tab顺序
6. 测试所有修改
7. 同步到GitHub