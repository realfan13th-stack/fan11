---
name: bottom-capsule-and-data-ui-fix
overview: 五个明确修复/改进：（1）底部胶囊导航放大尺寸并修复切换按钮不响应BUG；（2）顶部栏所有尺寸固定白色；（3）仰望明月背景改为#F5F5F5；（4）数据管理界面一级TAB重设计为横向长条样式（作息表/课程表/晚托/主题）
design:
  architecture:
    framework: html
  styleKeywords:
    - 悬浮胶囊
    - 药丸选中态
    - 长条TAB
    - 底边高亮
    - 等宽分布
  fontSystem:
    fontFamily: PingFang SC
    heading:
      size: 18px
      weight: 700
    subheading:
      size: 14px
      weight: 600
    body:
      size: 13px
      weight: 500
  colorSystem:
    primary:
      - "#597AB5"
      - "#4E648A"
    background:
      - "#FFFFFF"
      - "#F5F5F5"
      - "#F5F5F7"
    text:
      - "#1D1D1F"
      - "#86868B"
      - "#8E8E93"
    functional:
      - "#FF3B30"
      - "#34C759"
todos:
  - id: bottom-capsule-enlarge
    content: 使用 [skill:frontend-design] 放大底部胶囊导航：高度76px、图标28px、字体13px、药丸选中态
    status: pending
  - id: fix-switch-bug
    content: 修复底部按钮切换BUG，排查switchTab hook逻辑确保正确切换
    status: pending
    dependencies:
      - bottom-capsule-enlarge
  - id: topbar-white
    content: 将.top-bar固定为白色#FFFFFF，文字改为深色#1D1D1F，适配子元素样式
    status: pending
  - id: theme-bg-fix
    content: 修改仰望明月主题背景色为#F5F5F5
    status: pending
  - id: dm-tabs-redesign
    content: 使用 [skill:ui-styling] 重设计数据管理TAB为横向长条样式，等宽分布+底边高亮
    status: pending
    dependencies:
      - topbar-white
---

## 产品概述

对现有教师作息工作台进行移动端UI修复和优化，包括底部胶囊导航栏放大、按钮切换BUG修复、顶部固定白色、主题色调整以及数据管理界面TAB重设计。

## 核心功能

1. **底部胶囊放大**：将底部导航栏从当前56px高度放大到更合适的视觉比例（参考截图约72-80px），图标从22px放大到28-32px，字体从10px放大到13-14px
2. **修复切换BUG**：修复点击底部按钮无法切换tab的问题，确保按钮选中态（彩色药丸背景+白色图标）正确显示
3. **顶部固定白色**：工作台上方的.top-bar固定为白色背景#FFFFFF，不受主题色影响，文字改为深色#1D1D1F
4. **仰望明背景色**：DEFAULT_THEMES中"仰望明月"的bg从#F9FCF6改为#F5F5F5
5. **数据管理TAB重设计**：将数据管理界面的四个子TAB（作息表/课程表/晚托/主题）改为横向长条样式，等宽分布，选中态使用底边条/下划线高亮

## 技术栈

- 纯前端单文件 HTML/CSS/JS（保持现有架构）
- 原生 DOM 操作，无框架依赖
- SVG 内联图标

## 实现策略

### 底部胶囊优化

- 修改 `.pwa-bottom-bar` 高度从56px到76px，增加padding和圆角
- 图标尺寸从22px放大到28px，字体从10px放大到13px
- 选中态 `.pwa-bottom-btn.active` 使用药丸形背景，增大内边距

### 切换BUG修复

- 问题定位：`initMobileUX` IIFE中的`switchTab` hook可能捕获了错误的引用
- 修复方案：确保按钮click handler正确调用`window.switchTab`，hook中正确保存和调用原始函数
- 添加显式的`syncBottomBar()`调用确保UI同步

### 顶部白色固定

- 修改 `.top-bar` background从`var(--header)`改为`#FFFFFF`
- 文字颜色从`#fff`改为`#1D1D1F`
- 同步修改 `.title-input`、`.schedule-switch`等子元素样式适配白色背景

### 数据管理TAB重设计

- 将 `.dm-subtabs` 从`flex`改为`display:grid`或`display:flex`配合`flex:1`实现等宽
- 移除圆角按钮样式，改为长条扁平设计
- 选中态使用底部边框高亮（`border-bottom:2px solid var(--accent)`）或背景色块

## 关键文件

- `schedule_v103.html` - 包含所有CSS和JS的单文件

### 底部胶囊导航设计

参考第一张截图（laifen底部导航），采用悬浮椭圆胶囊设计：

- 高度约76px，宽度占屏幕约90%，悬浮于底部16px处
- 背景使用半透明毛玻璃效果（rgba(255,255,255,0.9) + backdrop-filter: blur(20px)）
- 4个按钮等宽分布，选中项使用药丸形彩色背景（--accent色）+ 白色图标
- 未选中项灰色图标（#8E8E93），无边框无背景

### 数据管理TAB设计

参考第二张截图（我的订单TAB），采用横向长条设计：

- TAB容器为白色卡片背景，底部有分割线
- 4个TAB等宽横向排列（flex:1或grid等分）
- 未选中态：文字灰色（#86868B），无背景
- 选中态：文字深色（#1D1D1F），底部2px高亮色条（--accent色）
- 悬停态：轻微背景色变化

## Agent Extensions

### Skill

- **frontend-design**
- 目的：为底部胶囊导航和数据管理TAB提供视觉设计指导，确保药丸选中态、长条TAB样式、配色比例符合现代移动端设计规范
- 预期成果：产出底部胶囊放大比例参数、选中态视觉样式、长条TAB布局和配色方案

- **ui-styling**
- 目的：实施底部胶囊放大样式和数据管理TAB重设计，包括CSS实现、响应式适配、过渡动画
- 预期成果：完成胶囊导航和TAB组件的完整CSS样式代码，包含移动端断点适配