---
name: fix-tab-and-schedule-bugs
overview: 修复4项问题：1. 底部Tab区位置错误+删除滑动指示器横线+添加长按滑动切换效果；2. 班级课表不显示bug（switchClassTab未调用renderClassGroupSchedule）；3. 次级Tab添加滑动切换效果；4. 删除标题旁铅笔图标。
todos:
  - id: fix-tab-position
    content: 修复Tab栏位置：var(--safe-area-bottom) → env(safe-area-inset-bottom, 0px)，同步修复@media中的padding-bottom
    status: pending
  - id: remove-slider
    content: 删除.pwa-tab-slider CSS块、createBottomBar中的slider创建代码、syncBottomBar中的updateTabSlider调用、整个updateTabSlider函数
    status: pending
    dependencies:
      - fix-tab-position
  - id: add-tab-swipe
    content: 为.pwa-bottom-bar添加触摸滑动切换Tab功能（touchstart/touchend，阈值40px）
    status: pending
    dependencies:
      - remove-slider
  - id: fix-classgroup-bug
    content: 修复switchClassTab()：tab="personal"时调用renderClassSchedule()，tab="group"时调用renderClassGroupSchedule()
    status: pending
  - id: add-classtab-swipe
    content: 为课表区.class-subtabs添加触摸滑动切换次级Tab功能
    status: pending
    dependencies:
      - fix-classgroup-bug
  - id: add-dmtab-swipe
    content: 为数据区.dm-subtabs添加触摸滑动切换次级Tab功能
    status: pending
    dependencies:
      - fix-classgroup-bug
  - id: remove-pencil-icon
    content: 删除标题旁铅笔图标 &#9998;（HTML行1275）
    status: pending
  - id: verify-and-sync
    content: 验证所有修复效果，git commit + push 同步仓库
    status: pending
    dependencies:
      - fix-tab-position
      - remove-slider
      - add-tab-swipe
      - fix-classgroup-bug
      - add-classtab-swipe
      - add-dmtab-swipe
      - remove-pencil-icon
---

## 用户需求（4项）

1. **Tab区修复（3个子问题）**

- 位置错误：底部Tab栏"卡在中间下方"，根因是CSS中误用 `var(--safe-area-bottom)` 而非 `env(safe-area-inset-bottom)`
- 图标下方的横线（上次误加的 `.pwa-tab-slider` 滑动指示器）需要去掉
- 做成**按住可以滑动切换Tab**的效果，参考iOS主界面搜索框滑动切换

2. **班级课表不显示Bug**

- 每次从主界面打开，课表里的"班级课表"内容不显示
- 根因：`switchClassTab()` 函数中，切换到 `"group"` 时没有调用 `renderClassGroupSchedule()`

3. **次级Tab滑动效果**

- 课表区："个人课表"、"班级课表"、"周视图"
- 数据区（DM区）："作息表"、"课程表"、"晚托"、"主题"
- 也要做成可以**触摸滑动切换**的效果

4. **删除标题旁铅笔符号**

- 当前HTML中标题"工作台"旁有铅笔编辑图标 `&#9998;`，需要删除

## 核心功能

1. 修复底部Tab栏位置，移除错误滑动指示器，添加Tab栏触摸滑动切换
2. 修复 `switchClassTab()` 中班级课表不渲染的Bug
3. 为课表区次级Tab和数据区次级Tab添加触摸滑动切换效果
4. 删除标题旁的铅笔编辑图标

## 技术方案

### 1. Tab区修复

**位置错误根因**：

- `bottom: calc(12px + var(--safe-area-bottom))` 中 `var()` 是CSS变量函数，但 `--safe-area-bottom` 并未定义（正确写法是CSS `env(safe-area-inset-bottom, 0px)`）
- 导致 `calc()` 计算失败，`bottom` 值无效，Tab栏脱离底部定位

**修复方案**：

- `.pwa-bottom-bar` 的 `bottom` 改为 `calc(12px + env(safe-area-inset-bottom, 0px))`
- `@media (max-width: 768px)` 中的 `body { padding-bottom: calc(78px + var(--safe-area-bottom)) }` 同样修复
- 删除 `.pwa-tab-slider` CSS块（行5238-5246）
- 删除 `createBottomBar()` 中创建 slider 的代码（行5390-5393）
- 删除 `syncBottomBar()` 中的 `updateTabSlider()` 调用（行5414-5415）
- 删除整个 `updateTabSlider()` 函数（行5418-5426）

**添加Tab栏触摸滑动**：

- 在 `createBottomBar()` 中为 `.pwa-bottom-bar` 添加 `touchstart`、`touchend` 事件监听
- 计算横向滑动距离，超过阈值（40px）时切换至相邻Tab
- 支持循环切换（首尾相连）

### 2. 班级课表Bug修复

**修复方案**：

- `switchClassTab()` 函数中添加：
- `tab === "personal"` 时调用 `renderClassSchedule()`
- `tab === "group"` 时调用 `renderClassGroupSchedule()`
- `tab === "weekly"` 时已有 `renderWeekView()` 调用，保持不变

### 3. 次级Tab滑动效果

**课表区次级Tab**（`.class-subtabs`）：

- 为 `.class-subtabs` 容器添加 `touchstart`、`touchend` 事件
- 计算横向滑动方向，切换相邻子Tab

**数据区次级Tab**（`.dm-subtabs`）：

- 为 `.dm-subtabs` 容器添加同样的触摸滑动逻辑
- Tab顺序：`schedule` → `class` → `afterschool` → `theme`

### 4. 删除铅笔图标

- 删除HTML中 `<span class="edit-icon">&#9998;</span>`（行1275）

## 关键文件

- `schedule_v103.html` - 所有修改均在此单文件内完成
- CSS修改：`.pwa-bottom-bar`（约行5217）、`.pwa-tab-slider`（约行5238，整块删除）、`@media (max-width: 768px)` 中的 `body { padding-bottom }`（约行5298-5301）、`.class-subtab`（约行633）、`.dm-subtab`（约行587）
- JS修改：`createBottomBar()`（约行5385）、`syncBottomBar()`（约行5409）、`updateTabSlider()`（约行5418，整函数删除）、`switchClassTab()`（约行1976）
- HTML修改：标题区铅笔图标（约行1275）

## Agent Extensions

### Skill

- **systematic-debugging**
- 用途：诊断底部Tab栏位置错误的根因（var vs env），确保修复方案准确
- 预期成果：确认 `var(--safe-area-bottom)` 是错误写法，修复后Tab栏正确贴在底部

- **frontend-design**
- 用途：指导次级Tab滑动交互的视觉反馈设计，确保滑动效果流畅、符合iOS交互规范
- 预期成果：滑动切换时有平滑的过渡动画，用户体验接近iOS主界面搜索框滑动效果

- **ui-ux-pro-max**
- 用途：提供UI/UX设计智能，确保Tab滑动交互、次级Tab滑动交互符合现代移动端交互规范
- 预期成果：所有滑动交互均有适当的触摸反馈和过渡动画