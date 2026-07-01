---
name: ui-align-buttons-and-remove-theme
overview: 调整按钮对齐方式、优化移动端空白区域、删除主题模块
todos:
  - id: fix-button-alignment
    content: 修改 CSS 让顶部动态栏中的子tab按钮靠左对齐（修改 line 146-147 和 line 153）
    status: completed
  - id: optimize-mobile-whitespace
    content: 优化移动端课表区和晚托区的空白区域（添加 padding-bottom 到 .right-panel）
    status: completed
    dependencies:
      - fix-button-alignment
  - id: remove-theme-module
    content: "删除主题模块（删除 #dmTheme 中的主题色选择部分，删除 renderThemeSelector() 函数和其调用）"
    status: completed
    dependencies:
      - fix-button-alignment
  - id: test-all-changes
    content: 测试所有修改，验证按钮对齐、移动端空白区域和主题模块删除是否正确
    status: completed
    dependencies:
      - fix-button-alignment
      - optimize-mobile-whitespace
      - remove-theme-module
---

## 产品概述

教师作息工作台（schedule_v103.html）需要优化三个问题：

1. 顶部动态栏中的子tab按钮在移动端居中显示，需要改为靠左对齐
2. 移动端课表区和晚托区底部空白区域过多，需要优化
3. 主题模块（主题色选择功能）无用，需要删除

## 核心功能

1. **按钮靠左对齐**：将顶部动态栏中的"个人课表/班级课表/周视图"和"作息表/课程表/晚托/导出"按钮模块改为靠左对齐
2. **移动端空白优化**：减少课表区和晚托区在移动端的底部空白区域，使其刚好显示内容
3. **删除主题模块**：删除主题色选择功能（保留导入/导出功能）

## 技术栈

- 前端单文件 HTML/CSS/JavaScript（无框架）
- CSS 媒体查询（移动端适配）
- DOM 操作（删除主题模块）

## 实现方案

### 1. 按钮靠左对齐

**问题分析**：

- CSS line 146-147：`.top-bar-dynamic .class-subtabs, .top-bar-dynamic .dm-subtabs { justify-content:center; }` 导致按钮居中
- CSS line 153（@media max-width:768px）：`.top-bar--show-dynamic .top-bar-dynamic { justify-content:center; }` 导致移动端按钮居中

**解决方案**：

- 修改 CSS，将 `justify-content:center` 改为 `justify-content:flex-start`
- 在桌面端（min-width:769px），保持按钮居中（因为 `.top-bar--show-dynamic` 使用 `justify-content:center`）
- 在移动端（max-width:768px），让按钮靠左对齐

**修改位置**：

1. CSS line 146-147：删除或注释掉 `justify-content:center`
2. CSS line 153：将 `justify-content:center` 改为 `justify-content:flex-start`

### 2. 移动端空白区域优化

**问题分析**：

- `.right-panel` 在移动端（line 757-761）只有 `padding: 10px 12px`，没有明显的 `min-height` 设置
- `.tab-content` 在移动端（line 5635-5650）使用 `position:absolute` 定位，可能导致高度计算问题
- 可能需要添加 `padding-bottom` 以确保内容不会被底部导航栏遮挡

**解决方案**：

- 在移动端 media query 中，为 `.right-panel` 添加 `padding-bottom: calc(76px + env(safe-area-inset-bottom, 0px))`
- 检查 `.tab-content` 的高度设置，确保其 `min-height` 适合内容

**修改位置**：

1. CSS line 761 之后：添加 `padding-bottom: calc(76px + env(safe-area-inset-bottom, 0px))`
2. 检查是否有其他元素导致空白区域过多

### 3. 删除主题模块

**当前结构**（line 1694-1719）：

```html
<div class="dm-panel" id="dmTheme">
  <div class="section">
    <div class="section-title">选择主题色</div>
    <div class="theme-selector" id="themeSelector"></div>
  </div>
  <div class="section">
    <!-- 导入/导出功能 -->
  </div>
</div>
```

**解决方案**：

- 删除主题色选择部分（line 1695-1698）
- 保留导入/导出功能部分（line 1699-1718），但需要从 `#dmTheme` 中移出
- 删除 `renderThemeSelector()` 函数（line 2066-2077）
- 删除所有对 `renderThemeSelector()` 的调用

**修改位置**：

1. HTML line 1694-1719：删除主题色选择部分，保留导入/导出功能
2. JS line 2066-2077：删除 `renderThemeSelector()` 函数
3. JS line 2146：删除 `if(dm==="theme")renderThemeSelector();`
4. JS line 4451：删除 `renderThemeSelector();`
5. JS line 4609：删除 `try{renderThemeSelector();}catch(e){}`

## 实现细节

### 1. 按钮靠左对齐 - CSS 修改

**修改前**（line 146-147）：

```css
.top-bar-dynamic .class-subtabs,
.top-bar-dynamic .dm-subtabs { justify-content:center; margin-bottom:0; }
```

**修改后**：

```css
.top-bar-dynamic .class-subtabs,
.top-bar-dynamic .dm-subtabs { justify-content:flex-start; margin-bottom:0; }
```

**修改前**（line 151-154）：

```css
@media (max-width:768px){
  .top-bar--show-dynamic { padding-bottom:8px; }
  .top-bar--show-dynamic .top-bar-dynamic { justify-content:center; }
}
```

**修改后**：

```css
@media (max-width:768px){
  .top-bar--show-dynamic { padding-bottom:8px; }
  .top-bar--show-dynamic .top-bar-dynamic { justify-content:flex-start; padding-left:12px; }
}
```

### 2. 移动端空白区域优化 - CSS 修改

**在移动端 media query 中添加**（在 line 761 之后）：

```css
@media (max-width:768px){
  .right-panel {
    padding: 10px 12px;
    padding-bottom: calc(76px + env(safe-area-inset-bottom, 0px));
    position: relative;
    overflow-x: hidden;
  }
}
```

### 3. 删除主题模块 - HTML 修改

**修改前**（line 1694-1719）：

```html
<div class="dm-panel" id="dmTheme">
  <div class="section">
    <div class="section-title">选择主题色</div>
    <div class="theme-selector" id="themeSelector"></div>
  </div>
  <div class="section">
    <div class="section-title">导入 / 导出</div>
    <!-- 导入/导出功能 -->
  </div>
</div>
```

**修改后**：

- 删除整个 `#dmTheme` panel
- 将导入/导出功能移到 `#dmSchedule` 或其他合适位置
- 或者，保留 `#dmTheme` 但只保留导入/导出功能

根据代码分析，`#dmTheme` 是通过 `data-dm="theme"` 按钮访问的，该按钮文字已经是"导出"。所以，应该保留 `#dmTheme` 但删除主题色选择部分。

**修改方案**：

1. 删除 line 1695-1698（主题色选择部分）
2. 保留 line 1699-1718（导入/导出功能）
3. 将 `#dmTheme` 的 id 改为更合适的名称（可选）

### 4. 删除主题模块 - JS 修改

**删除 `renderThemeSelector()` 函数**（line 2066-2077）：

```javascript
function renderThemeSelector(){
  // ... 删除整个函数
}
```

**删除 `switchDM()` 中的调用**（line 2146）：

```javascript
if(dm==="theme")renderThemeSelector(); // 删除这行
```

**删除 `refreshAll()` 中的调用**（line 4451）：

```javascript
renderThemeSelector(); // 删除这行
```

**删除 `init()` 中的调用**（line 4609）：

```javascript
try{renderThemeSelector();}catch(e){} // 删除这行
```

## 性能考虑

- CSS 修改：只涉及样式调整，不会影响性能
- 删除主题模块：减少了 JS 函数的执行，可能提高性能
- 移动端空白区域优化：可能需要测试不同设备上的显示效果

## 边界情况

- 在桌面端，按钮应该保持居中（因为 `.top-bar--show-dynamic` 使用 `justify-content:center`）
- 在移动端，按钮应该靠左对齐
- 删除主题模块后，"导出"tab 应该只显示导入/导出功能

## Agent Extensions

### Skill

- **frontend-design**
- 用途：为按钮靠左对齐提供视觉设计指导，确保按钮在顶部栏位置时美观、一致
- 预期结果：按钮样式与原有风格统一，间距、对齐方式合理

- **ui-ux-pro-max**
- 用途：优化移动端空白区域，提供更好的用户体验
- 预期结果：移动端显示效果更佳，空白区域减少，内容显示更紧凑