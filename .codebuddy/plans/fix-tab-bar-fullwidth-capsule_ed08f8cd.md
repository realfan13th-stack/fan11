---
name: fix-tab-bar-fullwidth-capsule
overview: 将 Tab 栏从 v103-pwa-9 的错误"小 tab"效果，修复为全宽大圆角胶囊（同 v103-pwa-7 风格），并修复白色 bar 与灰色 pill 的对齐问题，尽量贴近底部操作线。
design:
  architecture:
    framework: html
  styleKeywords:
    - Laifen Style
    - Full-width Capsule
    - Large Border-radius
    - Floating Pill
    - Bottom Tab Bar
  fontSystem:
    fontFamily: system-ui
    heading:
      size: 14px
      weight: 600
    subheading:
      size: 12px
      weight: 500
    body:
      size: 10px
      weight: 400
  colorSystem:
    primary:
      - "#FFFFFF"
      - "#E8E8E8"
    background:
      - "#FFFFFF"
    text:
      - "#666666"
      - "#AEAEB2"
    functional:
      - "#1A1A1A"
      - "#E5E5E5"
todos:
  - id: fix-bar-fullwidth
    content: 修改 .pwa-bottom-bar：回退全宽胶囊（left:12px, right:12px, width:calc(100vw-24px)），bottom 改为 4px 贴近底部，padding 改为 6px 8px
    status: completed
  - id: fix-pill-alignment
    content: 修改 .pwa-tab-pill：修复对齐（left:8px, top:6px），width 改为 calc(25% - 16px)，height 改为 calc(100% - 12px)，border-radius 改为 24px
    status: completed
    dependencies:
      - fix-bar-fullwidth
  - id: fix-body-padding
    content: 修改 @media (max-width:768px) 中的 body padding-bottom：从 60px 改为 76px 适配新高度
    status: completed
    dependencies:
      - fix-bar-fullwidth
  - id: verify-js-consistency
    content: 验证 JS 中的 innerWidth 计算：确认 updateCachedTabWidth 和 onPointerMove 都使用 -16（8px×2 padding）
    status: completed
    dependencies:
      - fix-pill-alignment
  - id: bump-version-commit
    content: 更新 APP_VERSION 为 v103-pwa-10，git commit 并 push
    status: completed
    dependencies:
      - verify-js-consistency
---

## 问题描述

v103-pwa-9 的 Tab 栏修改错误，使用了 `width: auto` + `left: 50%` + `translateX(-50%)` 导致 bar 收缩成"小 tab"效果，不是预期的全宽大胶囊。

## 用户需求

1. **不要小 tab 效果**，要回退到 v103-pwa-7 的全宽大胶囊风格（`left: 12px, right: 12px, width: calc(100vw - 24px)`）
2. **修复白色 bar 形状异常**：当前白色区域不是胶囊形，后面露出灰色方形
3. **修复灰色胶囊与白色区域对不上**：位置偏移，多层形状不统一
4. **尽量靠近移动端底部操作线**，但不能超出页面
5. **白色部分也要是胶囊形状**，与灰色 pill 统一

## 核心修复目标

- Bar 恢复全宽大胶囊形状（左右各 12px margin）
- 白色 bar 和灰色 pill 都是胶囊形，且精确对齐
- Bar 尽量贴近底部 home indicator（约 4px 间距）
- 无显示 BUG（无灰色方形露出、无位置偏移）

## 技术栈

- 纯 HTML/CSS 修改，无 JS 框架变更
- 仅修改 `schedule_v103.html` 中的 CSS 和版本号
- JS 滑动/弹簧逻辑完全不动

## 实现方案

### 修改策略

回退到 v103-pwa-7 的全宽大胶囊风格，并修复形状和对齐问题。

### 具体改动

**1. `.pwa-bottom-bar` — 回退全宽大胶囊**

- 移除 `left: 50%` 和 `transform: translateX(-50%)`
- 恢复 `left: 12px; right: 12px; width: calc(100vw - 24px)`
- `bottom: calc(8px + ...)` → `bottom: calc(4px + env(safe-area-inset-bottom, 0px))`：尽量贴近底部
- `padding: 4px` → `padding: 6px 8px`：上下 6px 保持胶囊形状，左右 8px 让 pill 贴近边缘
- 移除 `overflow: hidden`：pill 现在在 padding 内部，不需要截断
- `min-height: auto` → `min-height: 60px`：保持足够高度

**2. `.pwa-tab-pill` — 修复对齐**

- `left: 4px` → `left: 8px`：与 bar 的 `padding-left: 8px` 精确对齐
- `top: 4px` → `top: 6px`：与 bar 的 `padding-top: 6px` 精确对齐
- `width: calc((100% - 8px) / 4)` → `width: calc(25% - 16px)`：4 个按钮，每个减去左右 padding 8px×2
- `height: calc(100% - 8px)` → `height: calc(100% - 12px)`：上下各 6px padding
- `border-radius: 28px` → `border-radius: 24px`：略小于 bar 的 30px，形成内嵌胶囊效果

**3. JS 计算一致性**

- `updateCachedTabWidth` (line 5512): `barEl.getBoundingClientRect().width - 16`：16 = 8px left + 8px right padding ✅ 已正确
- `onPointerMove` (line 5593): `barRect.width - 16`：与上面保持一致 ✅ 已正确
- 无需修改 JS

**4. `body padding-bottom` — 适配新高度**

- 当前 `calc(60px + ...)` 需要重新计算
- Bar 高度：60px (min-height) + 12px (padding-top + padding-bottom) = 72px
- Bar bottom：4px
- 总计：72px + 4px = 76px
- 改为 `calc(76px + env(safe-area-inset-bottom, 0px))`

**5. `APP_VERSION` — 版本号更新**

- `v103-pwa-9` → `v103-pwa-10`：触发 PWA 缓存刷新

### 不改动的部分

- 滑动切换 Tab 逻辑（约 5668 行起 JS 代码）
- 弹簧取消效果
- `.pwa-bottom-btn` 样式
- HTML 结构

## 验证清单

- [ ] Bar 是全宽大胶囊（不是小 tab）
- [ ] 白色 bar 是胶囊形状（border-radius: 30px）
- [ ] 灰色 pill 在白色 bar 内正确对齐（left: 8px, top: 6px）
- [ ] Pill 形状也是胶囊（border-radius: 24px）
- [ ] Bar 尽量贴近底部（bottom: 4px + safe-area）
- [ ] 没有灰色方形露出
- [ ] JS 滑动/弹簧逻辑不受影响
- [ ] 手机端显示正常，不超出页面

## 设计风格

采用 **Laifen 风格的全宽大圆角胶囊 Tab Bar**：

- **Bar 形状**：全宽胶囊，`border-radius: 30px`，白色底色 `#FFFFFF`，1px `#E5E5E5` 边框
- **Pill 形状**：内嵌胶囊，`border-radius: 24px`（略小于 bar 的 30px），灰色 `#E8E8E8`
- **形状统一**：bar 和 pill 都是胶囊形，pill 完全贴合 bar 内壁（left: 8px, top: 6px）
- **位置**：距 home indicator 约 4px，尽量贴近但不超出安全区

## 布局设计

### Bottom Tab Bar 布局

```
┌─────────────────────────────────────────────────┐
│  12px          全宽大胶囊 Bar          12px    │ ← 页面边缘
│  ┌─────────────────────────────────────────┐  │
│  │ 6px  ← padding →  60px min-height    │  │ ← bar 内部
│  │ ┌──────────┐                            │  │
│  │ │  Pill    │ ← 灰色胶囊，left:8px     │  │
│  │ │ (24px r)│   top:6px                 │  │
│  │ └──────────┘                            │  │
│  │ [主页] [课表] [课后] [设置]             │  │ ← 4 个按钮
│  └─────────────────────────────────────────┘  │
│                   4px                           │ ← 距 home indicator
└─────────────────────────────────────────────────┘
```

### 关键尺寸

| 属性 | 值 | 说明 |
| --- | --- | --- |
| Bar width | `calc(100vw - 24px)` | 左右各 12px margin |
| Bar bottom | `calc(4px + safe-area)` | 尽量贴近 home indicator |
| Bar padding | `6px 8px` | 上下 6px，左右 8px |
| Bar border-radius | `30px` | 大圆角胶囊 |
| Pill left | `8px` | 与 bar padding-left 对齐 |
| Pill top | `6px` | 与 bar padding-top 对齐 |
| Pill border-radius | `24px` | 略小于 bar 的 30px |
| Body padding-bottom | `calc(76px + safe-area)` | 适配新高度 |


## 颜色系统

- **Bar 背景**：`#FFFFFF`（白色）
- **Bar 边框**：`1px solid #E5E5E5`
- **Pill 背景**：`#E8E8E8`（灰色）
- **按钮文字（非激活）**：`#AEAEB2`
- **按钮文字（激活）**：`#666666`
- **按钮图标（激活）**：`#1A1A1A`

## Agent Extensions

### Skill

- **frontend-design**
- Purpose: 指导 Tab 栏的视觉设计，确保胶囊形状美观且符合 Laifen 风格
- Expected outcome: 生成美观的全宽大胶囊 Tab Bar 设计，无显示 BUG

- **ui-ux-pro-max**
- Purpose: 验证移动端底部导航栏的 UX 规范（安全区、触摸目标、对齐）
- Expected outcome: 确保 Tab Bar 符合移动端 UX 最佳实践，无对齐或溢出问题