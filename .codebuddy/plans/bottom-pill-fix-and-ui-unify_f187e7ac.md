---
name: bottom-pill-fix-and-ui-unify
overview: 修复底部胶囊选中态不跟随的BUG、加宽药丸选中块、增加课表TAB间距、移除顶部冬夏令时切换并合并到数据管理区重做按钮UI、同步仓库。
todos:
  - id: fix-pill-following
    content: 修复胶囊切换 BUG：syncBottomBar 直接引用模块级 currentTab 而非 window.currentTab
    status: completed
  - id: widen-pill
    content: 使用 [skill:frontend-design] 拉宽胶囊选中态药丸：.pwa-bottom-btn.active 的水平 padding 18px → 28px
    status: completed
  - id: class-tab-spacing
    content: 增加课表区 .class-subtabs 的 margin-bottom，从 0 改为 clamp(10px,1.2vw,16px)
    status: completed
  - id: remove-schedule-switch
    content: 移除顶部 .schedule-switch：删除 HTML（行1284-1287）、CSS（行147-155,722-737,834）、JS 引用（行1977,4185,4335）
    status: completed
  - id: redesign-dm-toggle
    content: 使用 [skill:ui-ux-pro-max] 在 DM 作息表区重做冬夏令时切换控件，替换原有两个独立按钮为统一切换开关
    status: completed
    dependencies:
      - remove-schedule-switch
  - id: git-sync
    content: 同步仓库：git add + commit + push，方便移动端查看
    status: completed
    dependencies:
      - fix-pill-following
      - widen-pill
      - class-tab-spacing
      - redesign-dm-toggle
---

## 产品概述

对教师作息工作台进行 5 项修复与优化：底部胶囊导航切换跟随 BUG 修复、胶囊选中态拉宽、课表 TAB 间距调整、移除顶部冬夏令时按钮并合并至数据管理区、Git 同步。

## 核心功能

1. **修复胶囊切换 BUG**：`syncBottomBar` 读取 `window.currentTab` 始终为 `undefined`，永远回退到 `'home'`，导致点击其他按钮时药丸色块不跟随。根因是 `currentTab` 声明为模块级 `let` 而非 `window` 属性。修复后点击任一底部按钮，选中态色块立即跟随。
2. **胶囊选中态拉宽**：参考例图，将 `.pwa-bottom-btn.active` 的水平 padding 从 `18px` 增加到 `28px`，使药丸色块更修长。
3. **课表 TAB 间距**：`.class-subtabs` 当前 `margin-bottom:0`，与下方课表内容紧贴。增加 10-16px 间距。
4. **移除顶部冬夏令时按钮，合并至数据管理**：移除顶部 `.schedule-switch` 的 HTML、CSS 及所有 JS 中的 DOM 引用；在数据管理作息表编辑区，将原来的「编辑夏令时」「编辑冬令时」两个独立按钮重做为切换开关控件（类似原顶部开关样式），统一管理冬夏令时切换。
5. **Git 同步**：修改完成后 commit + push。

## 技术栈

- 纯前端单文件 HTML/CSS/JS（保持现有架构）
- 原生 DOM 操作，无框架依赖
- Git 版本控制

## 实现策略

### BUG 修复：currentTab 暴露到 window

- 根因：`let currentTab` 声明在模块顶层（行 1653），但 `syncBottomBar`（行 5385）读取 `window.currentTab`，二者不互通
- 修复方案：在 `syncBottomBar` 中改用模块级变量 `currentTab`（IIFE 内可访问上层闭包），或直接在 `syncBottomBar` 函数中将当前 `currentTab` 作为参数传入。最简方案：在 `syncBottomBar` 所在 IIFE 的闭包链中直接引用 `currentTab`

### 胶囊选中态拉宽

- 仅修改 `.pwa-bottom-btn.active` 的 `padding`，从 `4px 18px` 增加到 `4px 28px`

### 课表 TAB 间距

- 修改 `.class-subtabs` 的 `margin-bottom:0` 为 `margin-bottom:clamp(10px,1.2vw,16px)`

### 冬夏令时按钮迁移

- 删除 HTML：行 1284-1287（`<div class="schedule-switch">...</div>`）
- 删除 CSS：行 147-155（桌面端 `.schedule-switch` 样式）、行 722-737（移动端 `.schedule-switch` 样式）、行 834（`.schedule-switch button { min-height:36px; }`）
- 删除 JS 引用：`setScheduleType` 中行 1977、`refreshAll` 中行 4185、`init` 中行 4335
- 新增：在 DM 作息表编辑区（行 1454-1458）用切换开关替代两个独立按钮，样式与 DM 长条 TAB 风格统一

## 关键文件

- `schedule_v103.html` - 唯一的源代码文件，所有修改均在此文件中

## Agent Extensions

### Skill

- **ui-ux-pro-max**
- 目的：为冬夏令时切换按钮重做提供设计指导，确保新切换开关样式与当前 DM 长条 TAB 风格统一
- 预期成果：产出切换开关的 CSS 设计方案（尺寸、颜色、动画、间距），保持视觉一致性

- **frontend-design**
- 目的：为底部胶囊选中态拉宽和课表 TAB 间距调整提供视觉比例指导
- 预期成果：确保调整后的比例协调，不显得拥挤或空旷