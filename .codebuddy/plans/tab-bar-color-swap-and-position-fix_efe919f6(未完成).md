---
name: tab-bar-color-swap-and-position-fix
overview: 修复Tab栏3个问题：边缘方形灰色色块、颜色对调(bar白底+胶囊灰)、胶囊下移到距横线10px内。确保正常git推送。
todos:
  - id: css-color-swap
    content: 互换bar与pill背景色：bar改#FFFFFF加1px边框，pill改#E8E8E8并加深阴影
    status: pending
  - id: css-pill-lower
    content: 下移胶囊：pill top 6px→10px，bar改align-items:center，btn改justify-content:center，padding和min-height同步收紧
    status: pending
  - id: css-body-padding
    content: 调整body的padding-bottom从70px改为66px适配新bar高度
    status: pending
    dependencies:
      - css-pill-lower
  - id: bump-version
    content: 更新APP_VERSION为v103-pwa-8触发PWA缓存刷新
    status: pending
---

## 问题描述

Tab栏存在三个视觉缺陷需要修复：

### 问题1：边缘方形灰色色块

bar背景为#E8E8E8灰色，配合align-items:flex-end让pill上方留出空白灰色区域。pill白色胶囊只占25%宽度，在两端的bar圆角边界处露出灰色背景，形成不协调的方形色块。

### 问题2：颜色搭配不佳

用户要求颜色互换——bar底色改白色，选中胶囊改灰色，视觉重心从bar移到胶囊上。

### 问题3：胶囊需下移

当前pill top:6px，距home indicator横线过远。需下沉至10px以内，使胶囊底部更贴近物理底部。

## 改动范围

- 纯CSS修改，JS滑动/弹簧逻辑完全不动
- 版本号从v103-pwa-7升至v103-pwa-8
- 在ed55c88基础上正常commit推送

## 实现方案

### 修改策略

纯CSS修改，零JS变更。核心思路是颜色互换 + 布局简化 + 胶囊下沉。

### 具体改动

**1. `.pwa-bottom-bar` — 底色变白 + 加边框 + 布局居中**

- `background: #E8E8E8` → `background: #FFFFFF`：消除灰色背景，方形色块自然消失
- 新增 `border: 1px solid #E5E5E5`：白色bar在浅色页面下保持可见轮廓
- `align-items: flex-end` → `align-items: center`：按钮垂直居中，不再贴着bar底部
- `padding: 4px 6px` → `padding: 2px 6px`：上下padding收紧配合胶囊下移
- `min-height: 60px` → `min-height: 58px`：高度同步收紧

**2. `.pwa-tab-pill` — 变灰色 + 下移 + 阴影加深**

- `background: #FFFFFF` → `background: #E8E8E8`：胶囊变灰，与bar背景互换
- `top: 6px` → `top: 10px`：下移4px，底部更贴近home indicator
- `box-shadow: 0 2px 8px rgba(0,0,0,0.08)` → `box-shadow: 0 2px 10px rgba(0,0,0,0.12)`：灰色胶囊加深阴影保持立体感

**3. `.pwa-bottom-btn` — 按钮内容居中**

- `justify-content: flex-end` → `justify-content: center`：图标文字垂直居中，不再贴底部

**4. `body padding-bottom` — 适配新高度**

- `calc(70px + ...)` → `calc(66px + ...)`：bar高度减少4px，页面底部留白同步缩减

**5. `APP_VERSION` — 版本号更新**

- `v103-pwa-7` → `v103-pwa-8`：触发PWA缓存刷新

### 不改动的部分

- 滑动切换Tab逻辑（约5668行起JS代码）
- 弹簧取消效果
- `.pwa-bottom-btn.active` 颜色保持 `#666666`
- HTML结构不变