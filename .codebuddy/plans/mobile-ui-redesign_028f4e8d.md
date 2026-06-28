---
name: mobile-ui-redesign
overview: 将教师工作台的移动端界面改造为极简主义风格，顶部标题栏、中间内容卡片区、底部悬浮导航栏的三段式布局，替换所有 emoji 为纯 SVG 图标
todos:
  - id: design-system-mobile
    content: 使用 [skill:frontend-design] 和 [skill:ui-ux-pro-max] 制定移动端设计系统
    status: completed
  - id: icon-replacement
    content: 使用 Lucide Icons 替换底部导航和所有界面的emoji图标
    status: completed
    dependencies:
      - design-system-mobile
  - id: top-bar-redesign
    content: 重新设计移动端顶部标题栏（简洁白色风格，移除深蓝色背景）
    status: completed
    dependencies:
      - design-system-mobile
  - id: bottom-nav-redesign
    content: 实现底部导航栏（胶囊式或全宽线型，无emoji，SVG图标）
    status: completed
    dependencies:
      - design-system-mobile
      - icon-replacement
  - id: content-cards
    content: 将主内容区改造为卡片式布局（圆角、阴影、留白）
    status: completed
    dependencies:
      - design-system-mobile
  - id: mobile-interactions
    content: 优化移动端交互（触摸反馈、页面切换动效、手势支持）
    status: completed
    dependencies:
      - bottom-nav-redesign
      - content-cards
  - id: theme-adaptation
    content: 确保新UI适配现有5套主题（颜色变量继承）
    status: completed
    dependencies:
      - design-system-mobile
      - bottom-nav-redesign
      - top-bar-redesign
  - id: testing-optimization
    content: 移动端测试与性能优化（真机测试、动画性能、safe-area适配）
    status: completed
    dependencies:
      - mobile-interactions
      - theme-adaptation
---

## 需求分析

用户希望将现有教师作息工作台改造为类似参考截图的移动端APP风格：

**参考截图特征提取：**

- **截图一（白色主题）**：顶部简洁标题栏（浅灰背景）、中间卡片式内容列表、底部5个图标按钮导航（白色背景+细微边框）、整体极简白色风格
- **截图二（深色主题）**：顶部品牌标题区域、中间白色圆角卡片、底部悬浮胶囊式深色导航栏、黑白灰极简配色

**用户明确要求：**

1. 结构：顶部标题区 + 中间内容区 + 底部按钮导航
2. 风格：简洁分明，采用参考图的极简设计语言
3. 图标：使用SVG图标，**不使用emoji**
4. 需要详细推进计划、外部UI套件建议、APP UI设计参考

**当前代码现状：**

- 单文件HTML（5530行），已有移动端适配（@600px断点）
- 已有PWA底部导航栏（`.pwa-bottom-bar`），但使用emoji图标
- 顶部栏为深蓝色（#4E648A），包含标题"工作台"和夏令/冬令切换
- Tab导航：课表、晚托、数据、主题
- 已有safe-area、滑动切换、下拉刷新功能
- 主题系统已有5套配色

## 技术方案

### 是否需要外部UI套件？

**推荐方案：不需要引入重量级UI套件，使用原生实现 + Lucide图标**

| 选项 | 方案 | 说明 |
| --- | --- | --- |
| **推荐** | Lucide Icons (CDN) + 原生CSS/JS | 轻量、符合参考图风格、无依赖、文件保持单文件 |
| 备选 | Heroicons (CDN) | 与Lucide类似，Tailwind官方推荐 |
| 不推荐 | Material UI / Ant Design | 过重，与参考图极简风格不符，增加体积 |
| 不推荐 | FontAwesome | 风格过于传统，不如Lucide简洁 |


**技术选型理由：**

1. **Lucide Icons**：SVG图标库，24x24标准尺寸，线条风格与参考图一致，支持CDN直接引用
2. **保持单文件架构**：用户当前是单HTML文件，不应引入复杂构建工具
3. **CSS变量系统**：复用现有主题系统，扩展移动端专用变量
4. **渐进增强**：保留现有桌面端布局，移动端全新UI层

### 核心实现策略

**1. 图标系统替换**

- 移除现有emoji（📅🌙⚙️🎨）
- 使用Lucide SVG图标：calendar、moon、settings、palette
- 图标内联或CDN引入，确保离线可用

**2. 布局架构改造（仅移动端）**

```
┌─────────────────────────────┐
│  状态栏区域（safe-area-top）    │
├─────────────────────────────┤
│  顶部标题栏（简洁样式）          │
│  [返回/菜单]  标题  [操作按钮]   │
├─────────────────────────────┤
│                             │
│      主内容滚动区域            │
│    （卡片式列表/表格）         │
│                             │
├─────────────────────────────┤
│  底部导航栏（胶囊/线型设计）      │
│  [图标] [图标] [+] [图标] [图标] │
│  （safe-area-bottom适配）      │
└─────────────────────────────┘
```

**3. 响应式断点策略**

- 保持现有 `@media (max-width:600px)` 作为主要移动端断点
- 新增 `@media (max-width:768px)` 适配平板/大手机
- 桌面端保持现有布局不变

**4. 性能优化**

- 使用CSS `transform` 和 `opacity` 实现动画（GPU加速）
- 底部导航固定定位，主内容区 `padding-bottom` 留出空间
- 图片/内容懒加载（如需要）

## 推荐使用的 Agent Extensions

### Skill

- **frontend-design**
- 用途：为移动端UI设计专属视觉语言，确保设计不陷入模板化，符合参考截图的极简iOS风格
- 预期成果：产出针对教师工作台的移动端设计规范，包括色彩、字体、布局、动效

- **ui-ux-pro-max**
- 用途：获取移动端最佳实践、触摸目标尺寸、可访问性规范、底部导航设计模式
- 预期成果：符合WCAG标准的色彩对比度方案、触摸目标44px规范、底部导航交互模式

### SubAgent

- **code-explorer**
- 用途：精确定位需要修改的CSS和JS代码位置，特别是PWA底部栏、Tab切换、主题系统相关代码
- 预期成果：每个修改点的精确行号和上下文，避免误改现有桌面端布局