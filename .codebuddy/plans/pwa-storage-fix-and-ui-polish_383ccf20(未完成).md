---
name: pwa-storage-fix-and-ui-polish
overview: 删除通知功能、修复header刘海区遮挡、拉宽胶囊药丸、优化DM作息表切换UI并联动主页、修复PWA独立模式下数据清零问题（使用localForage/IndexedDB）。
design:
  architecture:
    framework: html
  styleKeywords:
    - 安全区适配
    - 胶囊选中态
    - 分段切换控件
  fontSystem:
    fontFamily: PingFang SC
    heading:
      size: 20px
      weight: 700
    subheading:
      size: 14px
      weight: 600
    body:
      size: 13px
      weight: 400
  colorSystem:
    primary:
      - "#597AB5"
    background:
      - "#F5F5F7"
      - "#FFFFFF"
    text:
      - "#1D1D1F"
      - "#86868B"
    functional:
      - "#34C759"
      - "#FF3B30"
todos:
  - id: remove-notify
    content: 删除 P3 通知功能区块（CSS + JS，行 5493-5725），同步删除 setScheduleType 中的通知 hook
    status: pending
  - id: fix-safe-area
    content: "移动端 .top-bar 添加 padding-top: calc(env(safe-area-inset-top) + 12px)，修复刘海区遮挡"
    status: pending
  - id: widen-pill
    content: 胶囊药丸拉宽：.pwa-bottom-btn.active 水平 padding 28px → 38px
    status: pending
  - id: optimize-season-toggle
    content: 优化 .season-toggle UI，switchEditSchedule 联动 setScheduleType，显示"当前主页显示为X令时"
    status: pending
    dependencies:
      - remove-notify
  - id: create-manifest
    content: 创建 manifest.json 文件，在 HTML head 中添加 <link rel="manifest">
    status: pending
  - id: migrate-indexeddb
    content: 内联 IndexedDB 轻量封装，修改 loadData/saveData 优先使用 IndexedDB 并回退 localStorage
    status: pending
    dependencies:
      - create-manifest
  - id: verify-and-sync
    content: 验证所有功能正常，git add + commit + push 同步仓库
    status: pending
    dependencies:
      - remove-notify
      - fix-safe-area
      - widen-pill
      - optimize-season-toggle
      - migrate-indexeddb
---

## 产品概述

对教师作息工作台 schedule_v103.html 进行 5 项修复与优化，解决通知功能冗余、移动端刘海区遮挡、胶囊选中态宽度、DM作息表切换联动、PWA数据持久化问题。

## 核心功能

1. **删除"开启通上课知"功能**：完全移除 P3: Push Notifications 整个区块（CSS + JS + 对外接口），精简代码。
2. **修复移动端刘海区遮挡**：在移动端 `.top-bar` 中添加 `padding-top: calc(env(safe-area-inset-top) + 12px)`，确保内容不进入刘海/状态栏区域。
3. **胶囊药丸拉宽**：`.pwa-bottom-btn.active` 水平 padding 从 `28px` 增至 `38px`。
4. **DM作息表切换优化**：`.season-toggle` UI 美化；`switchEditSchedule` 调用 `setScheduleType()` 联动主页；旁边显示"当前主页显示为X令时"。
5. **修复PWA数据清零**：创建 `manifest.json` 文件；将数据存储迁移至 IndexedDB（内联轻量封装，无CDN依赖），彻底解决 PWA standalone 模式下 localStorage 不持久问题。

## Tech Stack

- 纯前端单文件 HTML/CSS/JS（保持现有架构）
- IndexedDB 原生 API（内联轻量封装，不引入外部库）
- PWA manifest.json 标准配置

## 实现策略

### 1. 删除通知功能

- 删除行 5493-5725 整个 `<!-- ===== P3: Push Notifications ===== -->` 区块
- 包括 `.pwa-notify-styles` CSS 和 `initNotifications()` IIFE
- 删除 `window.getNotifySettings` / `window.setNotifySettings` 接口
- 删除 P3.3 中对 `setScheduleType` 的 hook（行 5684-5698）

### 2. 移动端刘海区安全 padding

- 在 `@media (max-width: 768px)` 区块的 `.top-bar` 规则中添加：
`padding-top: calc(env(safe-area-inset-top, 0px) + 12px);`
- 桌面端 `.top-bar` 无需修改（无刘海问题）

### 3. 胶囊药丸拉宽

- 修改 `.pwa-bottom-btn.active` 的 `padding: 4px 28px` → `padding: 4px 38px`

### 4. DM 作息表切换优化

- **UI 优化**：`.season-toggle` 选中态使用 `--accent` 渐变背景，增加 `font-weight: 600`，按钮间距 `gap: 2px`
- **联动主页**：在 `switchEditSchedule()` 中调用 `setScheduleType(m)`（该函数已包含 `renderClassSchedule()` + `renderSchedule()` + `saveData()`，直接复用）
- **状态提示**：`editScheduleLabel` 显示"当前主页显示为X令时"，使用 `currentScheduleType` 变量

### 5. PWA 数据持久化（核心修复）

**根因分析**：iOS PWA standalone 模式下 localStorage 可能被清除或隔离，且当前无 `manifest.json`，iOS 不会将网页识别为完整 PWA。

**解决方案**：

- 创建 `manifest.json` 文件，包含 `name`、`short_name`、`display: standalone`、`start_url`、`background_color`、`theme_color`、`icons` 等必填字段
- 在 HTML `<head>` 中添加 `<link rel="manifest" href="manifest.json">`
- 内联轻量 IndexedDB 封装（约 60 行），提供 `idbGet()` / `idbSet()` 异步接口
- 修改 `loadData()`：优先从 IndexedDB 读取，失败则回退 localStorage
- 修改 `saveData()`：同时写入 IndexedDB 和 localStorage（双写保证兼容）
- 初始化流程改为异步：先尝试 IndexedDB 加载，失败再用 localStorage

**IndexedDB 封装设计**（内联，无外部依赖）：

```javascript
// 轻量 IndexedDB wrapper
const AppDB = {
  _dbPromise: null,
  _open() {
    if (this._dbPromise) return this._dbPromise;
    this._dbPromise = new Promise((resolve, reject) => {
      const req = indexedDB.open('scheduleAppDB', 1);
      req.onupgradeneeded = () => { req.result.createObjectStore('kvStore'); };
      req.onsuccess = () => resolve(req.result);
      req.onerror = () => reject(req.error);
    });
    return this._dbPromise;
  },
  async get(key) {
    const db = await this._open();
    return new Promise((resolve) => {
      const tx = db.transaction('kvStore', 'readonly');
      const req = tx.objectStore('kvStore').get(key);
      req.onsuccess = () => resolve(req.result || null);
      req.onerror = () => resolve(null);
    });
  },
  async set(key, value) {
    const db = await this._open();
    return new Promise((resolve) => {
      const tx = db.transaction('kvStore', 'readwrite');
      const req = tx.objectStore('kvStore').put(value, key);
      req.onsuccess = () => resolve(true);
      req.onerror = () => resolve(false);
    });
  }
};
```

**初始化流程修改**：

- `init()` 函数改为异步，先 `await AppDB.get('scheduleAppData_2')` 加载数据
- 若 IndexedDB 有数据则使用，否则回退 localStorage
- `saveData()` 同时执行 `AppDB.set()` 和 `localStorage.setItem()`

## 关键文件

- `schedule_v103.html` - 主文件，所有修改均在此文件
- `manifest.json` - [NEW] PWA 配置文件，放在项目根目录

## 设计调整说明

### 1. 胶囊药丸拉宽

- `.pwa-bottom-btn.active` 水平 padding 从 `28px` 增至 `38px`
- 药丸选中态更修长，与例图比例一致

### 2. DM 作息表切换按钮优化

- `.season-toggle` 样式优化：
- 背景改为 `#F0F0F5`（更浅的灰色，与 DM 区风格统一）
- 选中态使用 `--accent` 纯色填充 + 白色文字 + 轻微阴影
- 按钮圆角 `9px` → `10px`
- 按钮间 `gap: 2px`（更紧凑）
- 状态提示文字："当前主页显示为X令时"，灰色 `#86868B`，字号 `12px`

### 3. 移动端安全区

- 移动端 `.top-bar` 增加 `padding-top: calc(env(safe-area-inset-top) + 12px)`
- 确保内容从刘海/状态栏下方开始显示

## Agent Extensions

### Skill

- **systematic-debugging**
- 目的：用于诊断 PWA 数据清零问题的根因，确保 IndexedDB 迁移方案不引入新 BUG
- 预期成果：验证存储迁移方案的健壮性，确保数据不丢失

- **verification-before-completion**
- 目的：每项修改完成后进行验证，确保功能正确、无回归
- 预期成果：所有 5 项修改均通过验证，PWA 数据存储正常