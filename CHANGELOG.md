# 变更日志

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



