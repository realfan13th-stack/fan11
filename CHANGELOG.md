# 变更日志

## 2026-06-29 22:11 - 药丸彻底重写 + PWA 404修复 (pill-rewrite-pwa-fix)

### 回滚方法
`git revert HEAD`

### 变更列表
1. **药丸逻辑彻底重写**：
   - 新增 `activePillIdx` 本地状态变量，不再依赖 `window.currentTab || 'home'` 外部读取
   - 核心函数 `moveToTab(idx)` 统一处理：更新本地状态 → 更新按钮高亮 → 动画药丸 → 调用 switchTab
   - 用 **Pointer Events**（`pointerdown/move/up`）替代 Touch Events，兼容性更好，支持 `setPointerCapture`
2. **拖拽滑动修复**：
   - `pointermove` 中直接从手指位置计算药丸位置（`getBoundingClientRect()` 实时获取尺寸）
   - 拖拽距离 >=10px 才标记为拖拽，区分点击和滑动
   - `pointerup` 时恢复 spring 过渡动画并弹性吸附到最近 tab
3. **点击修复**：
   - click 事件在捕获阶段注册（`{capture:true}`），确保在 pointerup 之前触发
   - 点击直接调用 `moveToTab(idx)`，不再有事件竞争问题
4. **syncBottomBar 增强**：从外部 currentTab 同步回本地 activePillIdx，双向同步
5. **PWA 404 修复**：
   - `manifest.json` 的 `start_url` 从 `/schedule-workbench/schedule_v103.html` 改为 `./schedule_v103.html`（相对路径）
   - `scope` 从 `/schedule-workbench/` 改为 `./`
   - **注意**：修改 manifest 后需删除旧快捷方式重新"添加到主屏幕"

---

## 2026-06-29 22:05 - 修复药丸弹回主页Bug (fix-pill-snap-back)

### 回滚方法
`git revert HEAD`

### 变更列表
1. **区分点击与拖拽手势**：新增 `dragMoved` 标志位，`touchmove` 中移动超过 8px 才标记为拖拽
2. **纯点击不触发 touchend 吸附**：`dragMoved=false` 时 `onBarTouchEnd` 直接 return，不干扰 click 事件
3. **拖拽后阻止 click**：按钮 click 事件中检查 `dragMoved`，为 true 则跳过，避免双重触发

---

## 2026-06-29 21:56 - Laifen Tab栏三Bug修复 (fix-laifen-pill-bugs)

### 回滚方法
`git revert HEAD`

### 变更列表

1. **药丸形状改为胶囊形**：`border-radius: 14px` → `26px`（高度52px的一半），形成两端半圆的椭圆形胶囊
2. **修复药丸位置偏移**：
   - CSS `left: 6px` → `8px`（精确对齐 bar 的 padding-left）
   - `updatePillPosition` 中 `pillLeft = 8 + idx * tabWidth` → 直接 `translateX(idx * tabWidth)`
   - 抽取 `getPillMetrics()` 工具函数，药丸宽度和位置计算统一
3. **实现长按拖拽滑动**：
   - `touchstart` → 禁用 pill transition，记录起始位置和当前 tab
   - `touchmove` → 药丸实时跟随手指（无过渡动画），动态高亮最近的 tab 按钮，`e.preventDefault()` 防止页面滚动
   - `touchend` → 恢复 spring 过渡动画（`cubic-bezier(0.34, 1.56, 0.64, 1)`），松手后药丸弹性吸附到最近 tab，自动切换

---

## 2026-06-29 21:30 - UI修复 + Laifen风格Tab栏 (ui-fixes-and-laifen-tab-bar)

### 回滚方法
`git revert HEAD`

### 变更列表

1. **周视图日期选择框移动端修复**：日期输入框从 `.weekly-week-nav` 移出为 `.weekly-header` 独立子元素，CSS 限制 `max-width:140px`，移动端单行不换行且靠右
2. **删除标题区分割线**：`.top-bar` 删除 `border-bottom:0.5px solid rgba(0,0,0,0.08)`
3. **导入导出区域重构**：
   - "导出图片"按钮与"导出 Excel"同一行，均用 `btn-primary`
   - 统一按钮布局为 `display:flex;flex-wrap:wrap;gap:8px;`
   - 导入/备份/恢复/清除/范例数据分组摆放
4. **"主题"tab改为"导出"tab**：
   - `dmSubtabs` 中 `data-dm="theme"` 按钮文字"主题"→"导出"
   - 导入导出卡片从公共区域移入 `#dmTheme` 面板内，其他tab不显示
   - 主题色选择保留在"导出"tab上方
5. **Laifen风格底部Tab栏**：
   - Tab栏背景改为 `#E8E8E8` 浅灰，删除毛玻璃效果
   - 新增白色浮动药丸 `.pwa-tab-pill`，`transform: translateX()` 滑动，spring曲线 `cubic-bezier(0.34, 1.56, 0.64, 1)`
   - 图标弹跳动画 `@keyframes tab-bounce`，点击时触发 `280ms` 弹跳
   - 激活Tab颜色 `#1A1A1A`（深黑），未激活 `#AEAEB2`（中灰）
6. **删除所有右滑切换效果**：
   - 删除 `initBottomBarSwipe()` 函数（底部栏右滑切换）
   - 删除 `initSwipeNav()`、`handleSwipeStart()`、`handleSwipeEnd()` 函数（页面右滑切换Tab）
   - 删除 `initSubtabSwipe()` 函数（次级Tab右滑切换）
   - 删除相关变量 `swipeStartX`、`swipeStartY`

---

## 2026-06-29 20:45 - Tab区修复 + 次级Tab滑动 (fix-tab-and-schedule-bugs)

### 回滚方法
`git revert HEAD` 或 `git reset --hard HEAD~1`

### 变更列表

1. **底部Tab区位置修复**：`var(--safe-area-bottom)` → `env(safe-area-inset-bottom, 0px)` 标准CSS写法
2. **删除底部滑动指示器横线**：移除 `.pwa-tab-slider` CSS、JS中slider创建代码、`updateTabSlider()`函数
3. **底部栏滑动切换**：新增 `initBottomBarSwipe()`，横向滑动超40px切换Tab（iOS风格）
4. **班级课表不显示Bug修复**：`switchClassTab('group')` 时调用 `renderClassGroupSchedule()`，`personal` 时调用 `renderClassSchedule()`
5. **次级Tab滑动切换**：通用 `initSubtabSwipe()` 函数，课表区（个人/班级/周视图）和数据区（作息表/课程表/晚托/主题）均支持横向滑动
6. **删除标题铅笔图标**：移除工作台旁的 `<span class="edit-icon">✎</span>`

---

## 2026-06-29 20:35 - Laifen App 设计风格 UI 优化 (ui-redesign-laifen-style)

### 回滚方法
`git revert HEAD~1` + `git reset --hard HEAD~2` 或直接 `git reset --hard 3199e17~1`

### 变更列表

1. **Tab区高度扩展**：`56px` → `64px`，按钮最小高度 `44px` → `52px`
2. **代换课模块宽松排版**：`.ss-sub-item` 内边距 `3px 6px` → `8px 12px`，圆角 `5px` → `8px`，新增轻阴影
3. **周视图日期选择器单行**：`.weekly-header { flex-wrap: nowrap }`，日期输入区 `margin-left: auto` 靠右
4. **课表三视图统一**：圆角 `--radius: 10px` → `14px`，阴影统一 `0 2px 8px rgba(0,0,0,0.06)`，表头padding统一
5. **标题区重设计**：删除竖线 `|`，`top-bar` 背景改 `var(--bg)`，标题字号 `clamp(18px,2vw,22px)`
6. **全局底色规则**：`.left-panel` 背景改 `var(--bg)`，内容卡片保持白底 `#FFFFFF`

---

## 2026-06-28 22:30 - 移动端底部导航胶囊化重设计 (bottom-nav-capsule)

### 回滚方法
`git revert HEAD` 或 `git reset --hard HEAD~1`

### 变更列表

1. **底部导航胶囊化**：浮动椭圆形胶囊，圆角 32px，悬浮底边 12px，毛玻璃背景
2. **4 按钮布局**：主页(🏠)/课表(📅)/晚托(🌙)/数据(⚙️)，选中项有彩色背景+白色图标+阴影
3. **主题并入数据管理**：主题作为 `dm-panel` 第4个子tab，通过 `switchDM('theme')` 访问
4. **删除顶部 tab-nav**（移动端）：@media (max-width:600px) 下 `.tab-nav { display:none }`
5. **主页逻辑**：选中 home 时显示 left-panel 卡片，隐藏 right-panel；其他 tab 反之
6. **桌面端不受影响**：isMobile 判断确保 left-panel 在桌面端始终可见
7. **滑动/下拉刷新**：适配新的 TAB_ORDER，home 页更新时钟卡片

---

## 2026-06-28 - 移动端 UI 重新设计 (mobile-ui-redesign)

### 版本备份
- `schedule_v103_backup_20260627.html` - 原始版本备份（已有）
- `schedule_v103_backup_20260628_212700.html` - 本轮修改前自动备份

### 计划文件
- `.codebuddy/plans/schedule-workbench-optimization-plan_9253869c(未完成).md`

### 回滚方法
将任意备份文件复制为 `schedule_v103.html` 即可回退。

### 移动端 UI 重新设计 (2026-06-28 21:27)

#### 回滚方法
将 `schedule_v103_backup_20260628_212700.html` 复制为 `schedule_v103.html` 即可回退到修改前版本。

#### 变更列表

1. **图标系统**：底部导航 4 个 emoji → Lucide SVG 内联图标（Calendar/Moon/Settings/Palette）
2. **顶部栏**：深蓝色背景 → 白色极简风格 + 细分隔线
3. **底部导航栏**：毛玻璃效果（backdrop-filter blur(20px)），SVG 图标，更柔和配色
4. **内容卡片**：16px 圆角、柔和阴影、更大留白
5. **Tab 导航**：圆角胶囊按钮样式
6. **背景色**：使用 `var(--bg)` 继承主题变量
7. **通知系统**：移除所有 emoji 前缀（✅🔔⏰🔄📋📱）
8. **交互动效**：页面切换 fade、按钮触摸反馈 scale、Modal 滑入动画
9. **SVG 图标**：替换通知图标中的 emoji 为纯 SVG 路径
10. **Tab 切换过渡**：使用 visibility+opacity 实现平滑切换（right-panel 范围内）
11. **bugfix**：修复 right-panel 缺少 position:relative 导致过渡动画异常

### 关键文件
- `schedule_v103.html` - 主文件（已修改）
- `schedule_v103_backup_20260628_212700.html` - 修改前自动备份
- `CHANGELOG.md` - 本变更日志

### 验证状态
- [x] HTML 结构完整 (</html> 标签正常闭合)
- [x] CSS 语法检查通过
- [x] 所有 emoji 图标已替换为 SVG
- [x] 主题变量继承验证
- [x] safe-area 适配保持
- [ ] 真机浏览器测试（待用户验证）

---



