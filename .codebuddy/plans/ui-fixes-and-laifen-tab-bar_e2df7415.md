---
name: ui-fixes-and-laifen-tab-bar
overview: 修复5项UI问题：周视图日期选择器移动端布局、标题区分割线删除、导入导出区域重组、主题tab改为导出tab、底部Tab栏改为Laifen风格浮动药丸动效
todos:
  - id: fix-weekly-date-mobile
    content: 修复周视图日期选择框：重构HTML使日期输入框独立于周导航，CSS实现靠右单行不换行
    status: completed
  - id: remove-topbar-border
    content: 删除标题区.top-bar的border-bottom分割线（CSS行134）
    status: completed
  - id: restructure-import-export
    content: 重构导入导出区域按钮布局：导出图片与导出Excel同行，统一按钮大小与样式
    status: completed
  - id: rename-theme-to-export
    content: 将"主题"tab文字改为"导出"，将导入导出卡片移入该tab面板内，其他tab不显示
    status: completed
  - id: implement-laifen-tab-bar
    content: 实现Laifen风格Tab栏：浅灰背景、浮动白色药丸滑动、图标弹跳动效（spring曲线）
    status: completed
    dependencies:
      - remove-topbar-border
  - id: remove-swipe-effects
    content: 删除所有右滑切换效果：initBottomBarSwipe、initSwipeNav、initSubtabSwipe函数及调用
    status: completed
    dependencies:
      - implement-laifen-tab-bar
  - id: verify-and-sync
    content: 验证所有修复效果，更新CHANGELOG.md，git commit + push 同步仓库
    status: completed
    dependencies:
      - fix-weekly-date-mobile
      - remove-topbar-border
      - restructure-import-export
      - rename-theme-to-export
      - implement-laifen-tab-bar
      - remove-swipe-effects
---

## 用户需求（5项）

### 1. 周视图日期选择框移动端修复

- 当前移动端周视图上方的日期选择框位置靠左，且换行成两行
- 根因：`.weekly-header` 的 `justify-content:space-between` 只有一个子元素，日期输入框未独立出来，导致窄屏换行
- 修复目标：日期选择框靠右，与周导航在同一行，移动端不换行

### 2. 删除标题区分割线

- `.top-bar` 存在 `border-bottom:0.5px solid rgba(0,0,0,0.08)`
- 需要删除该分割线

### 3. 导入导出区域按钮整理

- 当前导入导出区域按钮分多个 `.btn-row`，顺序杂乱，大小不一致
- "导出图片"按钮独占一行，需要调到与"导出 Excel"同一行
- 统一按钮样式与大小

### 4. 修改"主题"tab为"导出"，移动导入导出卡片

- 将"主题"tab文字改为"导出"
- 将导入导出卡片从公共区域移入"导出"tab面板内（即 `dmTheme` 面板）
- 其他tab（作息表/课程表/晚托）不显示该卡片

### 5. Tab栏动效改为Laifen风格浮动药丸 + 删除右滑效果

- 参考 `laifen-navbar-animation-prompt.md` 文档实现
- 核心效果：浅灰背景 `#E8E8E8` + 白色浮动药丸滑动 + 图标弹跳动画（spring曲线）
- 删除上一版添加的 `initBottomBarSwipe()`、`initSwipeNav()`、`initSubtabSwipe()` 所有右滑切换效果

## 核心功能

1. 修复周视图移动端日期选择框布局为一行且靠右
2. 删除标题区 `.top-bar` 底部分割线
3. 重构导入导出区域按钮布局，统一大小，导出图片与导出Excel同行
4. "主题"tab改为"导出"tab，导入导出卡片仅在该tab下显示
5. 底部Tab栏改为Laifen浮动药丸风格，含图标弹跳动效，删除所有右滑切换效果

## 技术方案

### 1. 周视图日期选择框修复

**现状分析**：

- `.weekly-header` 结构：只有一个子元素 `.weekly-week-nav`，内含导航按钮和日期输入框
- CSS: `.weekly-header { justify-content:space-between; flex-wrap:nowrap; }` — 但只有一个子元素，`space-between` 无效
- 移动端换行根因：`.weekly-week-nav` 内元素过多，窄屏下溢出换行

**修复方案**：

- 重构 HTML：将日期输入框从 `.weekly-week-nav` 中移出，作为 `.weekly-header` 的第二个子元素
- CSS: `.weekly-header { justify-content:space-between; flex-wrap:nowrap; }` 现在有两个子元素，日期输入框靠右
- 移动端日期输入框宽度优化：`max-width: 140px; font-size: 13px;`

### 2. 删除标题区分割线

- 删除 `.top-bar` CSS 中的 `border-bottom:0.5px solid rgba(0,0,0,0.08)`（约行134）
- 同步删除移动端 `@media` 中若有相关覆盖

### 3. 导入导出区域按钮整理

**当前结构（行1559-1581）**：

```html
<div class="section"> <!-- 公共导入导出 -->
  <div class="section-title">导入 / 导出</div>
  <div class="btn-row">导出Excel 导入Excel</div>
  <div class="btn-row">备份 恢复</div>
  <div class="btn-row">清除 范例数据</div>
  <div class="btn-row">导出图片（独占一行）</div>
</div>
```

**修复方案**：

- 将"导出图片"按钮移至第一个 `.btn-row`，与"导出 Excel"相邻，均用 `btn-primary`
- 统一所有按钮为相同高度（`min-height: 38px`），使用 `flex-wrap:wrap; gap:8px;` 的单一 `.btn-row`
- 重构为：

```html
<div class="btn-row" style="display:flex;flex-wrap:wrap;gap:8px;align-items:center;">
  <button class="btn btn-primary">导出 Excel</button>
  <button class="btn btn-primary">导出图片</button>
  <button class="btn btn-secondary">导入 Excel</button>
</div>
<div class="btn-row" style="display:flex;flex-wrap:wrap;gap:8px;margin-top:6px;">
  <button class="btn btn-secondary">备份数据</button>
  <button class="btn btn-secondary">恢复数据</button>
</div>
<div class="btn-row" style="display:flex;flex-wrap:wrap;gap:8px;margin-top:6px;">
  <button class="btn btn-danger">清除数据</button>
  <button class="btn btn-success">范例数据</button>
</div>
```

### 4. "主题"tab改为"导出" + 移动导入导出卡片

**修复方案**：

- HTML: 将 `dmSubtabs` 中 `data-dm="theme"` 按钮文字改为"导出"
- 将导入导出 `.section` 块（行1559-1581）从 `dmTheme` 面板外部移入 `#dmTheme` 面板内部
- 删除原位置的导入导出块（在 `</div><!-- 公共导入导出 -->` 处）

### 5. Tab栏Laifen风格改造 + 删除右滑

**Laifen风格核心实现**（参考 `laifen-navbar-animation-prompt.md`）：

- **CSS 修改**（`.pwa-bottom-bar` 区域，约行5217）：
- `background: #E8E8E8`（浅灰，非白色）
- 删除 `backdrop-filter` 和 `-webkit-backdrop-filter`
- 保留 `border-radius: 32px`
- 添加 `padding: 6px 8px;`

- **新增浮动药丸CSS**：

```css
.pwa-tab-pill {
  position: absolute;
  top: 6px;
  left: 0;
  width: calc(100% / 4);  /* 4个tab均分 */
  height: 52px;
  background: #FFFFFF;
  border-radius: 14px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  will-change: transform;
  transition: transform 300ms cubic-bezier(0.34, 1.56, 0.64, 1);
  pointer-events: none;
  z-index: 0;
}
```

- **修改 `.pwa-bottom-btn` CSS**：
- 非激活：`color: #AEAEB2`（替代 `#8E8E93`）
- 激活：`color: #1A1A1A`（替代白色+背景色），删除 `background` 和 `box-shadow`
- 图标和标签添加 `transition: color 200ms ease-out`
- 按钮 `z-index: 1; position: relative;`

- **新增图标弹跳动画CSS**：

```css
@keyframes tab-bounce {
  0%   { transform: translateY(0px) scale(1.0); }
  30%  { transform: translateY(-5px) scale(1.2); }
  60%  { transform: translateY(1px) scale(0.95); }
  100% { transform: translateY(0px) scale(1.0); }
}
.pwa-bottom-btn.bouncing .pwa-bb-icon {
  animation: tab-bounce 280ms cubic-bezier(0.68,-0.55,0.27,1.55) forwards;
}
```

- **JS 修改**：
- `createBottomBar()`：创建 `.pwa-tab-pill` 元素并追加到 `barEl`；按钮点击时添加 `.bouncing` 类，300ms后移除
- 新增 `updatePillPosition()` 函数：根据 `currentTab` 计算药丸位置，`pillEl.style.transform = 'translateX(' + (idx * 25) + '%)'`
- `syncBottomBar()` 中调用 `updatePillPosition()`
- 删除 `initBottomBarSwipe()` 函数及其调用
- 删除 `initSwipeNav()` 函数、`handleSwipeStart()`、`handleSwipeEnd()` 函数及其调用
- 删除 `initSubtabSwipe()` 函数及其调用

## 关键文件

- `schedule_v103.html` — 所有修改均在此单文件内完成
- CSS修改：`.top-bar`（行134）、`.weekly-header`、`.pwa-bottom-bar`（行5217起）、新增 `.pwa-tab-pill` 和 `@keyframes tab-bounce`
- HTML修改：周视图 `.weekly-header` 结构（行1397）、`dmSubtabs` 文字（行1432）、导入导出块位置（行1559-1581）
- JS修改：`createBottomBar()`（行5378起）、删除 `initBottomBarSwipe`/`initSwipeNav`/`initSubtabSwipe` 三个函数、新增 `updatePillPosition()`
- `CHANGELOG.md` — 记录本次变更

## Agent Extensions

### Skill

- **systematic-debugging**
- 用途：诊断周视图日期选择框移动端换行的具体根因，确认HTML结构问题
- 预期成果：确认修复方案正确，移动端日期选择框靠右且不换行

- **frontend-design**
- 用途：指导Laifen风格Tab栏的视觉实现，确保浮动药丸和图标弹跳效果流畅
- 预期成果：Tab栏动效还原Laifen设计，spring曲线自然，图标弹跳有物理感

- **ui-ux-pro-max**
- 用途：优化导入导出按钮布局，确保移动端按钮排列美观、大小一致
- 预期成果：导入导出区域按钮布局合理，视觉统一，移动端适配良好