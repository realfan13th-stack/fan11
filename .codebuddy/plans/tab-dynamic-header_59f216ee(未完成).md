---
name: tab-dynamic-header
overview: 实现每个tab切换时动态改变顶部区域：主页显示标题，课表/数据tab将子tab按钮提升到顶部，晚托tab隐藏标题区
---

我现在已经充分理解了代码结构，可以生成完整的实现计划了。基于我的分析：

**当前结构：**

- `<header class="top-bar">`（第1392行）显示"工作台"标题
- `.class-subtabs`（第1491行）位于 `#tabClass` 内部
- `.dm-subtabs`（第1547行）位于 `#tabData > .data-mgmt` 内部  
- `switchTab()` 函数（第2059行）控制 tab 切换

**实现策略：** 使用 JavaScript 动态移动 DOM 节点，根据当前 tab 在 `.top-bar` 中显示标题或子 tab 按钮。

```xml
<plan_result>
<req>
## 产品概述
教师作息工作台（schedule_v103.html）的顶部标题区（`<header class="top-bar">`）需要根据当前选中的 tab 动态显示不同内容。

## 核心功能
1. **主页 tab**：保持现状，顶部显示"工作台"标题
2. **课表 tab**：隐藏标题区，将"个人课表/班级课表/周视图"按钮移动到顶部标题区位置（只移动按钮，不改变背景），按钮下方内容区域显示为灰色背景
3. **晚托 tab**：隐藏标题区，不移动按钮（保持 `.afterschool-header` 在内容区内部）
4. **数据 tab**：隐藏标题区，将"作息表/课程表/晚托/导出"按钮移动到顶部标题区位置（只移动按钮，不改变背景），按钮下方内容区域显示为灰色背景
</req>

<tech>
## 技术栈
- 前端单文件 HTML/CSS/JavaScript（无框架）
- 动态 DOM 操作（appendChild 移动节点）
- CSS 变量系统（复用现有 --bg, --card 等）

## 实现方案

### 核心策略
使用 JavaScript 动态移动 DOM 节点（`.class-subtabs` 和 `.dm-subtabs`）到 `.top-bar` 中的动态容器，根据当前 tab 切换显示内容。

**优势：**
- 不需要重复 HTML 结构
- 按钮的 active 状态会保留（同一个 DOM 节点）
- 实现简洁，易于维护

### 实现细节

**1. HTML 修改（line 1391-1403）**
修改 `.top-bar` 结构，添加 `#titleWrapper` 和 `#headerSubtabs` 两个容器：
- `#titleWrapper`：包裹原有标题显示（#titleDisplay），控制显示/隐藏
- `#headerSubtabs`：动态容器，用于存放移动到此的子 tab 按钮，默认隐藏

**2. CSS 修改**
- 调整 `.top-bar` 的 flex 布局，确保能正确显示子 tab 按钮（复用 `.class-subtabs` / `.dm-subtabs` 原有样式）
- 添加 `.header-has-subtabs` 类，当子 tab 在顶部时，为 `.main-content` 或 `.right-panel` 添加灰色背景（使用 `#F5F5F7` 或新增 CSS 变量）

**3. JS 修改（switchTab 函数，line 2059）**
添加 resetHeader() 和 setupHeaderForTab() 逻辑：
- 每次 tab 切换时，先将所有可能被移动的元素移回原位置
- 然后根据当前 tab，将对应的子 tab 移动到 `.top-bar` 中的 `#headerSubtabs` 容器
- 为 `body` 添加/移除 `.header-has-subtabs` 类以控制内容区域背景色

**DOM 移动逻辑：**
```

// 将 .class-subtabs 移回 #tabClass 开头
var tabClass = document.getElementById('tabClass');
var classSubtabs = document.getElementById('classSubtabs');
if (classSubtabs && !tabClass.contains(classSubtabs)) {
tabClass.insertAdjacentElement('afterbegin', classSubtabs);
}

// 将 .dm-subtabs 移回 #tabData .data-mgmt 开头
var dataMgmt = document.querySelector('#tabData .data-mgmt');
var dmSubtabs = document.getElementById('dmSubtabs');
if (dmSubtabs && dataMgmt && !dataMgmt.contains(dmSubtabs)) {
dataMgmt.insertAdjacentElement('afterbegin', dmSubtabs);
}

```

**4. 移动端适配**
- 确保移动端布局下（left-panel 隐藏，right-panel 全宽显示），动态顶部也能正常工作
- 当前移动端逻辑（line 2065-2078）已处理 left-panel / right-panel 的显示切换，不需要修改

### 性能考虑
- DOM 移动操作开销极小（只是改变节点父级，不触发重排）
- 使用 `insertAdjacentElement('afterbegin', node)` 安全地在父元素开头插入节点（即使父元素为空也能工作）

### 边界情况
- 初始化时（page load），确保默认显示主页标题
- 如果将来添加新的 tab，需要同步更新 switchTab 中的逻辑
</tech>

<extensions>
## Agent Extensions
### Skill
- **frontend-design**
  - 用途：为动态顶部区域提供视觉设计指导，确保子 tab 按钮在标题区位置时美观、一致
  - 预期结果：按钮样式与原有风格统一，间距、对齐方式合理
- **ui-ux-pro-max**
  - 用途：优化动态顶部区域的交互体验，包括按钮点击反馈、过渡动画等
  - 预期结果：提供流畅的 tab 切换体验，视觉层次清晰
</extensions>

<todolist>
<item id="modify-top-bar-html" deps="">修改 .top-bar HTML 结构，添加 #titleWrapper 和 #headerSubtabs 容器</item>
<item id="add-dynamic-header-css" deps="modify-top-bar-html">添加 CSS 样式：动态顶部布局、灰色背景类 .header-has-subtabs</item>
<item id="implement-switchTab-logic" deps="modify-top-bar-html,add-dynamic-header-css">修改 switchTab() JS 函数，实现动态移动子 tab 按钮逻辑</item>
<item id="test-all-tabs" deps="implement-switchTab-logic">测试所有 tab 切换效果，验证主页/课表/晚托/数据 tab 显示正确</item>
<item id="mobile-responsive-check" deps="test-all-tabs">移动端适配验证，确保动态顶部在移动端布局下正常工作</item>
</todolist>
</plan_result>
```

这个计划包含了：

1. **需求说明**：明确了四个 tab 的行为
2. **技术方案**：使用 JS 动态移动 DOM 节点，不需要重复 HTML
3. **实现细节**：涵盖了 HTML、CSS、JS 三部分的修改
4. **Skill 使用**：使用了 `frontend-design` 和 `ui-ux-pro-max` 来指导视觉和交互设计
5. **任务列表**：5 个具体任务，从修改 HTML 到最终测试验证

计划的关键点：

- 使用 `insertAdjacentElement('afterbegin', node)` 来安全地移动 DOM 节点
- 通过为 `body` 添加/移除 `.header-has-subtabs` 类来控制内容区域的灰色背景
- 在每次 tab 切换时，先将所有子 tab 移回原位置，再根据当前 tab 移动需要的子 tab 到顶部```xml
<plan_result>
<req>

## 产品概述

教师作息工作台（schedule_v103.html）的顶部标题区（`<header class="top-bar">`）需要根据当前选中的 tab 动态显示不同内容。

## 核心功能

1. **主页 tab**：保持现状，顶部显示"工作台"标题
2. **课表 tab**：隐藏标题区，将"个人课表/班级课表/周视图"按钮移动到顶部标题区位置（只移动按钮，不改变背景），按钮下方内容区域显示为灰色背景
3. **晚托 tab**：隐藏标题区，不移动按钮（保持 `.afterschool-header` 在内容区内部）
4. **数据 tab**：隐藏标题区，将"作息表/课程表/晚托/导出"按钮移动到顶部标题区位置（只移动按钮，不改变背景），按钮下方内容区域显示为灰色背景
</req>

<tech>

## 技术栈

- 前端单文件 HTML/CSS/JavaScript（无框架）
- 动态 DOM 操作（appendChild 移动节点）
- CSS 变量系统（复用现有 --bg, --card 等）

## 实现方案

### 核心策略

使用 JavaScript 动态移动 DOM 节点（`.class-subtabs` 和 `.dm-subtabs`）到 `.top-bar` 中的动态容器，根据当前 tab 切换显示内容。

**优势：**

- 不需要重复 HTML 结构
- 按钮的 active 状态会保留（同一个 DOM 节点）
- 实现简洁，易于维护

### 实现细节

**1. HTML 修改（line 1391-1403）**
修改 `.top-bar` 结构，添加 `#titleWrapper` 和 `#headerSubtabs` 两个容器：

- `#titleWrapper`：包裹原有标题显示（#titleDisplay），控制显示/隐藏
- `#headerSubtabs`：动态容器，用于存放移动到此的子 tab 按钮，默认隐藏

**2. CSS 修改**

- 调整 `.top-bar` 的 flex 布局，确保能正确显示子 tab 按钮（复用 `.class-subtabs` / `.dm-subtabs` 原有样式）
- 添加 `.header-has-subtabs` 类，当子 tab 在顶部时，为 `.main-content` 或 `.right-panel` 添加灰色背景（使用 `#F5F5F7` 或新增 CSS 变量）

**3. JS 修改（switchTab 函数，line 2059）**
添加 resetHeader() 和 setupHeaderForTab() 逻辑：

- 每次 tab 切换时，先将所有可能被移动的元素移回原位置
- 然后根据当前 tab，将对应的子 tab 移动到 `.top-bar` 中的 `#headerSubtabs` 容器
- 为 `body` 添加/移除 `.header-has-subtabs` 类以控制内容区域背景色

**DOM 移动逻辑：**

```javascript
// 将 .class-subtabs 移回 #tabClass 开头
var tabClass = document.getElementById('tabClass');
var classSubtabs = document.getElementById('classSubtabs');
if (classSubtabs && !tabClass.contains(classSubtabs)) {
  tabClass.insertAdjacentElement('afterbegin', classSubtabs);
}

// 将 .dm-subtabs 移回 #tabData .data-mgmt 开头
var dataMgmt = document.querySelector('#tabData .data-mgmt');
var dmSubtabs = document.getElementById('dmSubtabs');
if (dmSubtabs && dataMgmt && !dataMgmt.contains(dmSubtabs)) {
  dataMgmt.insertAdjacentElement('afterbegin', dmSubtabs);
}
```

**4. 移动端适配**

- 确保移动端布局下（left-panel 隐藏，right-panel 全宽显示），动态顶部也能正常工作
- 当前移动端逻辑（line 2065-2078）已处理 left-panel / right-panel 的显示切换，不需要修改

### 性能考虑

- DOM 移动操作开销极小（只是改变节点父级，不触发重排）
- 使用 `insertAdjacentElement('afterbegin', node)` 安全地在父元素开头插入节点（即使父元素为空也能工作）

### 边界情况

- 初始化时（page load），确保默认显示主页标题
- 如果将来添加新的 tab，需要同步更新 switchTab 中的逻辑
</tech>

<extensions>

## Agent Extensions

### Skill

- **frontend-design**
- 用途：为动态顶部区域提供视觉设计指导，确保子 tab 按钮在标题区位置时美观、一致
- 预期结果：按钮样式与原有风格统一，间距、对齐方式合理
- **ui-ux-pro-max**
- 用途：优化动态顶部区域的交互体验，包括按钮点击反馈、过渡动画等
- 预期结果：提供流畅的 tab 切换体验，视觉层次清晰
</extensions>

<todolist>
<item id="modify-top-bar-html" deps="">修改 .top-bar HTML 结构，添加 #titleWrapper 和 #headerSubtabs 容器</item>
<item id="add-dynamic-header-css" deps="modify-top-bar-html">添加 CSS 样式：动态顶部布局、灰色背景类 .header-has-subtabs</item>
<item id="implement-switchTab-logic" deps="modify-top-bar-html,add-dynamic-header-css">修改 switchTab() JS 函数，实现动态移动子 tab 按钮逻辑</item>
<item id="test-all-tabs" deps="implement-switchTab-logic">测试所有 tab 切换效果，验证主页/课表/晚托/数据 tab 显示正确</item>
<item id="mobile-responsive-check" deps="test-all-tabs">移动端适配验证，确保动态顶部在移动端布局下正常工作</item>
</todolist>
</plan_result>
```