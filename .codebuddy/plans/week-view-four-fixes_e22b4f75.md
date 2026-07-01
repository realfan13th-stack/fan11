---
name: week-view-four-fixes
overview: 修复周视图4个问题：学科色彩区分度、格子缩小留白、周次联动晚托、圆点布局修复
todos:
  - id: fix-subject-colors
    content: 替换 getSubjectColor()：16色调预定义色盘替代窄范围哈希HSL（饱和度40-55%，明度75-84%），17种常见学科确定性映射+未知课程hash取模兜底
    status: completed
  - id: fix-cell-spacing
    content: 缩小格子留白：.weekly-grid 改为 border-collapse:separate + border-spacing:2px 3px，.week-card 移除 height:calc(100%+4px) 和 margin:-2px 改为 height:auto+min-height，td背景设为#F5F7Fa透过间隙，同步更新移动端/平板端响应式
    status: completed
  - id: fix-week-number-sync
    content: 周次联动晚托：删除冲突的ISO getWeekNumber(d)，renderWeekView中解析Monday字符串为数字传入学期版getWeekNumber，新增getWeekKeyFromMonday构造"YYYY-MM-wR"格式wkKey，从appData.afterSchool.weekNotes读取备注显示，.week-title-area添加cursor:pointer+onclick调用editWeekNote弹窗，修改editWeekNote提交后同步刷新周视图
    status: completed
  - id: fix-dot-layout
    content: 圆点布局修复：dotStr从td内.week-card之前移入.week-card div内部开头，.week-card添加position:relative作为定位容器，.wcell-dot的top/right微调适配卡片内部坐标
    status: completed
  - id: verify-all-fixes
    content: 验证4项修复：学科色视觉检查、格间距和留白效果、周次编号和备注联动、圆点布局不挤行，lint零错误，提交推送
    status: completed
    dependencies:
      - fix-subject-colors
      - fix-cell-spacing
      - fix-week-number-sync
      - fix-dot-layout
---

## 修复概述

对周视图卡片化升级后的4个遗留问题进行精确修复：学科颜色区分度、格子尺寸和间距、左上角周次联动晚托、代课/换课圆点布局错行。

## 修复内容

### 修复1：学科色彩区分度增强

将 `getSubjectColor()` 从窄范围哈希HSL（饱和度20-30%，明度84-92%）替换为16色调预定义色盘。色相按 360°/16=22.5° 均匀分布，饱和度40-55%，明度75-84%，确保相邻学科颜色视觉区分明显。

### 修复2：格子缩小+留白间距

表格从 `border-collapse:collapse` 改为 `separate`，`border-spacing:2px 3px` 在单元格间产生间隙。`.week-card` 移除 `height:calc(100%+4px)` 和 `margin:-2px`，改为 `height:auto` + `min-height` 正常填充，卡片自然缩小，td透过border-spacing露出bg底色形成留白。

### 修复3：左上角周次联动晚托表

删除重复的ISO `getWeekNumber(d)`（行2374-2378），保留学期版 `getWeekNumber(year,mn,d)`（行3131）。renderWeekView 中将Monday字符串解析为三个数字传入学期版函数。基于Monday日期反算晚托wkKey格式（"YYYY-MM-wR"）以读取 `appData.afterSchool.weekNotes[wkKey]` 备注。`.week-title-area` 添加 `cursor:pointer` 和 `onclick` 调用与晚托相同的 `editWeekNote()` 弹窗。`editWeekNote` 提交时同步刷新周视图。

### 修复4：圆点移入卡片内部

将 `dotStr` 从 `<td>` 内 `.week-card` 之前移入 `.week-card` div内部开头。`.week-card` 添加 `position:relative` 作为dot定位容器，`.wcell-dot` 的 z-index 和 top/right 基于卡片内部重新适配，确保圆点始终在卡片右上角且不影响flex纵向布局。

## 技术方案

### 修复1：学科色盘替换

**当前问题**：`getSubjectColor()` 使用字符串哈希映射HSL(h, 20-30%, 84-92%)，所有颜色都在"白化粉彩"区间，美术/信息/音乐相邻色相几乎无区分。

**方案**：预定义16色调色盘，色相步进22.5°，饱和度40-55%，明度75-84%。对已知课程名使用确定性映射（首字符或完整名hash → 色盘索引），对未知课程名退化为hash取模确保稳定性。

```js
function getSubjectColor(courseName){
  if(!courseName)return'hsl(210,45%,82%)';
  var palette=[
    'hsl(0,48%,80%)',    // 红
    'hsl(22,50%,78%)',   // 橙
    'hsl(45,52%,76%)',   // 黄-暖
    'hsl(68,44%,78%)',   // 黄绿
    'hsl(90,46%,77%)',   // 绿
    'hsl(112,48%,78%)',  // 青绿
    'hsl(135,45%,79%)',  // 青
    'hsl(158,42%,77%)',  // 蓝青
    'hsl(180,46%,78%)',  // 天蓝
    'hsl(202,48%,77%)',  // 蓝
    'hsl(225,50%,78%)',  // 靛蓝
    'hsl(248,44%,79%)',  // 紫
    'hsl(270,42%,78%)',  // 紫红
    'hsl(292,45%,79%)',  // 品红
    'hsl(315,48%,77%)',  // 粉
    'hsl(337,50%,78%)'   // 玫红
  ];
  var hash=0;
  for(var i=0;i<courseName.length;i++){hash=courseName.charCodeAt(i)+((hash<<5)-hash);hash|=0;}
  return palette[Math.abs(hash%16)];
}
```

**性能**：O(n)字符串遍历+n=0~10字符，16次取模，每次渲染20个课程共~200次简单运算，无性能压力。

### 修复2：表格留白间距

**当前CSS问题**：

```css
.weekly-grid { border-collapse:collapse; }         /* 无间隙 */
.week-card { height:calc(100%+4px); margin:-2px; } /* 溢出填满 */
```

**修复后**：

```css
.weekly-grid { border-collapse:separate; border-spacing:2px 3px; } /* 2px横向×3px纵向间距 */
.weekly-grid td { background:#F5F7Fa; }                             /* td底色透过间隙 */
.week-card { height:auto; min-height:clamp(38px,4vw,52px); }        /* 自然高度 */
```

同时需调整受 `border-collapse:separate` 影响的 `border-radius`（td直接上圆角而非table overflow）。

### 修复3：周次联动晚托

**步骤**：

1. **删除ISO getWeekNumber**：行2374-2378的 `function getWeekNumber(d){...}` 删除，保留行3131的学期版本作为唯一 `getWeekNumber`。
2. **修复renderWeekView调用**：Monday字符串"2026-06-23" → 拆分为 year/mn/d → `getWeekNumber(2026,5,23)`（注意月份减1）。
3. **构造wkKey**：实现 `getWeekKeyFromDate(dateStr)` 辅助函数，还原after-school的offset和rowIndex计算：

```js
function getWeekKeyFromMonday(mondayStr){
var p=mondayStr.split('-'), y=+p[0], m=+p[1]-1, d=+p[2];
var firstDay=new Date(y,m,1).getDay(), offset=firstDay===0?6:firstDay-1;
var r=Math.floor((d+offset-1)/7);
return y+'-'+String(m+1).padStart(2,'0')+'-w'+r;
}
```

4. **读取备注并渲染**：从 `appData.afterSchool.weekNotes[wkKey]` 取备注文字，有则显示备注，无则显示默认数字。
5. **点击弹窗**：在renderWeekView生成的headerHtml中，`.week-title-area` 添加 `style="cursor:pointer"` 和 `onclick="openWeekNotePopup(wkKey,defaultNote)"`。
6. **新增openWeekNotePopup函数**：调用 `editWeekNote(wkKey,defaultNote)` 并在其commit回调中追加 `renderWeekView()` 刷新。
7. **修改editWeekNote兼容**：添加可选参数 `onCommit` 回调，当从周视图调用时提交后额外调用 `renderWeekView()`。具体做法：对 `editWeekNote` 做最小侵入改动——在 `commit()` 函数末尾检查是否存在全局标记 `_weekViewCaller`，若存在则调 `renderWeekView()`。

### 修复4：圆点移入卡片

**当前HTML结构（问题）**：

```html
<td>
  <span class="wcell-dot sub-dot"></span>   <!-- 在flex卡片外，可能被流式布局影响 -->
  <div class="week-card" style="background:...">
    <span class="wc-name">课程</span>
    <span class="wc-class">班级</span>
  </div>
</td>
```

**修复后**：

```html
<td>
  <div class="week-card" style="background:...;position:relative;">
    <span class="wcell-dot sub-dot"></span> <!-- 在卡片内，卡片为定位容器 -->
    <span class="wc-name">课程</span>
    <span class="wc-class">班级</span>
  </div>
</td>
```

**CSS适配**：`.week-card` 添加 `position:relative`，`.wcell-dot` 的 `top:2px;right:2px` 和 `z-index:2` 基于卡片内部生效。

**代码改动（renderWeekView行2471附近）**：

- 原：`bodyHtml+=dotStr+'<div class="week-card" style="background:'+bgColor+';">'`
- 新：`bodyHtml+='<div class="week-card" style="background:'+bgColor+';position:relative;">'+dotStr`

### 影响面分析

| 改动 | 影响范围 | 风险 |
| --- | --- | --- |
| getSubjectColor 色盘替换 | 仅周视图卡片背景色 | 低——纯CSS颜色变更 |
| border-collapse:separate | .weekly-grid 相关所有样式 | 中——需验证thead/tbody圆角和today-col等不因separate模式破环 |
| 删除ISO getWeekNumber | 仅renderWeekView调用者 | 低——renderWeekView是唯一调用者 |
| editWeekNote 增加回调 | 晚托区域也调用此函数 | 需确保晚托调用时不受影响 |
| dotStr移入.week-card | 代课/换课圆点显示 | 低——仅DOM结构变更 |


### 目录结构

```
schedule-workbench/
└── schedule_v103.html          # [MODIFY] 唯一修改文件
    ├── CSS 行872-881           # [KEEP] week-note-overlay 样式不变
    ├── CSS 行1109              # [MODIFY] .weekly-grid: border-collapse→separate + border-spacing
    ├── CSS 行1121-1128         # [MODIFY] .weekly-grid td: 添加 background:#F5F7Fa
    ├── CSS 行1136-1143         # [MODIFY] .week-card: height→auto, 移除margin负值, 添加position:relative
    ├── CSS 行1077-1081         # [MODIFY] .week-title-area: 添加cursor:pointer
    ├── CSS 行1178-1180         # [MODIFY] .wcell-dot: top/right基于卡片微调
    ├── CSS 行1222-1246         # [MODIFY] 响应式中同步适配border-spacing和卡片尺寸
    ├── JS 行2361-2372          # [REPLACE] getSubjectColor: 色盘替代哈希HSL
    ├── JS 行2373-2378          # [DELETE] ISO getWeekNumber 函数
    ├── JS 行2380-2394          # [MODIFY] renderWeekView头部: 学期周数+wkKey+备注+onclick
    ├── JS 行2468-2474          # [MODIFY] renderWeekView卡片: dotStr移入.week-card内
    ├── JS 行1914-1936          # [MODIFY] editWeekNote: 提交后追加刷新周视图
    └── JS 新增                  # [NEW] getWeekKeyFromMonday / openWeekNotePopup 辅助函数
```