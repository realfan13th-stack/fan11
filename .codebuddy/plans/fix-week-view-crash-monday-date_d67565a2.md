---
name: fix-week-view-crash-monday-date
overview: 修复周视图崩溃：getWeekDates().monday 返回的是 Date 对象而非字符串，renderWeekView 中对它调用 .split() 导致 TypeError，同时修复周备注显示时的"周"字重复问题。
todos:
  - id: fix-monday-type
    content: 修复 getWeekDates() 行2339：dates.monday 从 Date 对象改为 "YYYY-MM-DD" 字符串
    status: completed
  - id: fix-week-duplicate
    content: 修复 renderWeekView() 行2411-2414："周"字重复显示问题
    status: completed
    dependencies:
      - fix-monday-type
  - id: verify-and-commit
    content: 验证修复：lint 零错误，提交推送
    status: completed
    dependencies:
      - fix-week-duplicate
---

## 问题描述

周视图当前完全空白，原因是 `getWeekDates()` 返回的 `dates.monday` 为原始 `Date` 对象，而 `renderWeekView` 修改后将其当作字符串调用 `.split('-')`，导致 **TypeError: monday.split is not a function**。

## 修复内容

1. **修复核心崩溃**：`getWeekDates()` 行2339 将 `dates.monday` 从 Date 对象改为与其他 dayName 键一致的 `"YYYY-MM-DD"` 字符串
2. **修复"周"字重复**：当 `noteFromAfterSchool` 已含"周"时不再追加 `.week-title-suffix` 里的"周"
3. **保留已有改动**：dot 布局修复（移入 .week-card 内部）不回退，CSS 和 editWeekNote 联动保持不变

## 实施方案

### 修复1：`getWeekDates()` — monday 类型统一（行2339）

**当前代码**：

```javascript
dates.monday=monday;
```

**修复为**（与行2336格式完全一致）：

```javascript
dates.monday=monday.getFullYear()+"-"+String(monday.getMonth()+1).padStart(2,"0")+"-"+String(monday.getDate()).padStart(2,"0");
```

**效果**：`dates.monday` 现为 `"2026-06-29"` 字符串，与 `dates["星期一"]` 等完全一致，`renderWeekView` 中的 `.split('-')` 正常工作。

### 修复2：`renderWeekView()` — "周"字去重（行2411-2414）

**当前代码**：

```javascript
var weekDisplay=noteFromAfterSchool||('第'+weekNum);
var headerHtml='<div class="week-title-area" ...>'
  +'<span class="week-title-num">'+escapeHTML(weekDisplay)+'</span>'
  +'<span class="week-title-suffix">周</span></div>';
```

**修复为**：当 `noteFromAfterSchool` 已含"周"时不追加后缀，否则保留原有"第N周"+"周"拼接逻辑。

```javascript
var weekDisplay=noteFromAfterSchool||('第'+weekNum+'周');
var hasZhounote=noteFromAfterSchool&&noteFromAfterSchool.indexOf('周')!==-1;
var headerHtml='<div class="week-title-area" ...>'
  +'<span class="week-title-num">'+escapeHTML(weekDisplay)+'</span>';
if(!hasZhounote)headerHtml+='<span class="week-title-suffix">周</span>';
headerHtml+='</div>';
```

### 不变更范围

- dot 布局修复（`dotStr` 在 `.week-card` 内部）**不还原**（用户确认数据清填后正常）
- CSS（`border-collapse:separate`、`border-spacing` 等）**不动**
- `editWeekNote` commit 中的 `try{renderWeekView();}catch(e){}` **保留**
- 晚托区域、弹窗交互、导航逻辑 **零改动**