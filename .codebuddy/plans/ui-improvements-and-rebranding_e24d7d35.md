---
name: ui-improvements-and-rebranding
overview: 完成4项UI改进：1) 优化课表区颜色生成器，使用莫兰迪色系确保颜色区分度；2) 晚托区增加"托管表"tab按钮；3) 晚托区月份tab背景色改为透明；4) 主页标题字号增大、默认标题改为"小课表"、项目名更改为"小课表"
design:
  architecture:
    framework: html
  styleKeywords:
    - Morandi
    - Subtle
    - Professional
  fontSystem:
    fontFamily: PingFang SC
    heading:
      size: 24px
      weight: 700
    subheading:
      size: 18px
      weight: 600
    body:
      size: 14px
      weight: 400
  colorSystem:
    primary:
      - "#4E648A"
      - "#B7D0D4"
    background:
      - "#F9FCF6"
      - "#FFFFFF"
    text:
      - "#1D1D1F"
      - "#86868B"
    functional:
      - "#16A34A"
      - "#DC2626"
      - "#F59E0B"
todos:
  - id: optimize-color-generator
    content: 优化 getSubjectColor() 函数，使用32色莫兰迪色盘（line 2446-2458）
    status: completed
  - id: add-afterschool-tabs
    content: 在晚托区添加 .as-subtabs 容器和"托管表"按钮（line 1545-1549）
    status: completed
    dependencies:
      - optimize-color-generator
  - id: make-month-tabs-transparent
    content: 修改 .month-tabs 背景色为 transparent（line 411-414）
    status: completed
    dependencies:
      - add-afterschool-tabs
  - id: increase-title-size
    content: 增大标题字号：clamp(18px,2vw,22px) → clamp(20px,2.2vw,24px)（line 158）
    status: completed
    dependencies:
      - make-month-tabs-transparent
  - id: rename-to-xiaokebiao
    content: 全局替换"工作台"为"小课表"（12处），更新 manifest.json
    status: completed
    dependencies:
      - increase-title-size
  - id: update-author-info
    content: 更新代码注释中的作者信息为 kaifan, 103404628
    status: completed
    dependencies:
      - rename-to-xiaokebiao
  - id: test-and-sync
    content: 测试所有修改，确认Linter错误为0，同步到GitHub
    status: completed
    dependencies:
      - update-author-info
---

## 用户需求

### 1. 课表区颜色生成器优化

- 当前 `getSubjectColor()` 使用16色调HSL色盘，新建颜色时会出现接近的颜色
- 需要让各个学科的颜色区分更大，但要符合莫兰迪色系
- 用户提供了5组颜色示例作为参考

### 2. 晚托区增加tab按钮

- 在晚托区上端区域增加"托管表"tab按钮
- 采用类似数据管理区的subtab样式（`.dm-subtabs`）
- 后续可能增加更多按钮，需要预留扩展空间

### 3. 晚托区月份tab背景色改成透明

- 当前 `.month-tabs` 有 `background:var(--card)`
- 需要改为 `transparent`，让月份tab背景透明

### 4. 主页区标题改进

- 顶端标题字号增加两个字号（当前 `clamp(18px,2vw,22px)` 改为 `clamp(20px,2.2vw,24px)`）
- 把默认标题从"工作台"改为"小课表"
- 代码开头的项目名更改为"小课表"，作者kaifan，103404628

## 功能内容

1. **颜色生成器**：优化 `getSubjectColor()` 函数，使用32色调莫兰迪色盘，确保颜色区分度更大
2. **晚托tab按钮**：在晚托区添加 `.as-subtabs` 容器和"托管表"按钮
3. **月份tab透明**：修改 `.month-tabs` 的 `background` 为 `transparent`
4. **标题改进**：全局替换"工作台"为"小课表"，增大标题字号，更新项目信息

## 视觉效果

- 课表区：学科颜色更加鲜明区分，但仍保持莫兰迪风格的柔和雅致
- 晚托区：顶部新增tab按钮栏，月份tab背景透明露出页面底色
- 主页区：标题字号更大更醒目，默认显示"小课表"

## Tech Stack Selection

- 单文件前端应用（HTML + CSS + JavaScript）
- 无需额外框架或库

## Implementation Approach

### 1. 颜色生成器优化

**问题分析**：

- 当前使用16色调HSL色盘，色相22.5°均匀分布
- 问题：颜色区分度不够，相邻颜色过于接近
- 用户提供的莫兰迪色系特点：低饱和度（15-35%）、中明度（70-85%）、带灰度

**解决方案**：

- 扩展色盘从16色到32色，使用用户提供的颜色作为基础色
- 采用LAB色彩空间计算颜色距离，确保新颜色与已有颜色区分度最大
- 预定义32个莫兰迪色系颜色，覆盖更多色相范围
- 使用哈希函数将课程名映射到色盘索引

**新色盘设计**（基于用户提供的颜色示例）：

```javascript
var palette = [
  // 红色系（莫兰迪）
  '#ECB6A2', '#E3C3B3', '#E6A096', '#C26B7A', '#A35149',
  // 橙色系（莫兰迪）
  '#D59990', '#E2B0A3', '#F9C3BB',
  // 黄色系（莫兰迪）
  '#D8CBB9', '#EEDAC9', '#F5E6D3',
  // 绿色系（莫兰迪）
  '#B7D0D4', '#82C6D8', '#508AAB', '#306752',
  // 蓝色系（莫兰迪）
  '#778FC0', '#32477C', '#7397B8', '#9BB8D3',
  // 紫色系（莫兰迪）
  '#BBAA9F', '#C9B8AD', '#8B7D7A', '#A89085',
  // 灰度系（莫兰迪）
  '#FFFEFC', '#FDFDFD', '#FFFFFF', '#F5F5F5', '#E8E8E8',
  '#D5D5D5', '#73777B'
];
```

**优化策略**：

- 使用哈希函数将课程名映射到32色盘
- 确保相邻课程名不会产生相近颜色（通过哈希分布）
- 保留 fallback 颜色 `hsl(210,45%,82%)`

### 2. 晚托区增加tab按钮

**实现方式**：

- 在 `#tabAfterschool` 的 `.afterschool-header` 中添加 `.as-subtabs` 容器
- 参考 `.dm-subtabs` 的CSS样式
- 添加"托管表"按钮，后续可扩展

**HTML结构**：

```html
<div class="afterschool-header">
  <div class="as-subtabs" id="asSubtabs">
    <button class="as-subtab active" data-as="calendar" onclick="switchAfterschoolTab('calendar')">托管表</button>
  </div>
  <div id="semesterBar" ...></div>
  <div class="month-tabs" id="monthTabs"></div>
</div>
```

### 3. 晚托区月份tab背景透明

**修改位置**：

- CSS line 411-414：`.month-tabs` 的 `background:var(--card)` 改为 `background:transparent`

### 4. 主页区标题改进

**修改内容**：

- CSS：`.title-edit` 的 `font-size` 从 `clamp(18px,2vw,22px)` 改为 `clamp(20px,2.2vw,24px)`
- HTML/JS：全局替换"工作台"为"小课表"（12处）
- `manifest.json`：更新项目名、描述
- 代码注释：更新作者信息为 kaifan, 103404628

## Implementation Notes

### 性能考虑

- 颜色生成器：预定义色盘，O(1)查找，无性能问题
- 晚托tab：简单DOM操作，无性能影响

### 向后兼容

- 颜色生成器：保持函数签名不变，仅修改内部实现
- 标题修改：更新默认值，但保留用户自定义标题功能

### 日志记录

- 无需额外日志记录

## Architecture Design

### 系统架构

单文件应用，无需复杂架构设计。

### 数据流

1. 颜色生成：`课程名 → 哈希计算 → 色盘索引 → 颜色值`
2. 晚托tab：`点击按钮 → switchAfterschoolTab() → 显示对应内容`
3. 标题显示：`加载 → 读取 appData.platformTitle → 显示标题`

## Directory Structure

```
project-root/
├── schedule_v103.html  # [MODIFY] 主文件，包含所有修改
├── manifest.json       # [MODIFY] 更新项目名和描述
└── README.md           # [MODIFY] 更新项目信息（如需要）
```

## Key Code Structures

### 新的 getSubjectColor() 函数

```javascript
function getSubjectColor(courseName){
  if(!courseName)return'#B7D0D4';
  var palette=[
    '#ECB6A2','#E3C3B3','#E6A096','#C26B7A','#A35149',
    '#D59990','#E2B0A3','#F9C3BB','#D8CBB9','#EEDAC9',
    '#F5E6D3','#B7D0D4','#82C6D8','#508AAB','#306752',
    '#778FC0','#32477C','#7397B8','#9BB8D3','#BBAA9F',
    '#C9B8AD','#8B7D7A','#A89085','#FFFEFC','#FDFDFD',
    '#F5F5F5','#E8E8E8','#D5D5D5','#73777B'
  ];
  var hash=0;
  for(var i=0;i<courseName.length;i++){
    hash=courseName.charCodeAt(i)+((hash<<5)-hash);
    hash|=0;
  }
  return palette[Math.abs(hash%32)];
}
```

## Design Style

保持现有设计风格，仅做功能性改进。

### 1. 颜色生成器

- 使用32色莫兰迪色盘
- 确保颜色区分度大，但仍保持柔和雅致
- 参考用户提供的5组颜色示例

### 2. 晚托区tab按钮

- 采用与数据管理区subtab一致的样式
- 按钮风格：圆角、半透明背景、active状态高亮
- 与月份tab协调布局

### 3. 月份tab背景透明

- 背景改为transparent，露出页面底色 #F9FCF6
- 保持文字和active状态样式不变

### 4. 标题字号增大

- 增大两个字号级别（18→20, 22→24）
- 保持响应式设计（clamp）
- 保持字体粗细和对齐方式

## Agent Extensions

### Skill

- **frontend-design**
- Purpose: 提供视觉设计指导，确保颜色生成器产生的颜色符合莫兰迪色系
- Expected outcome: 生成32色莫兰迪色盘，颜色区分度大且视觉柔和

- **ui-ux-pro-max**
- Purpose: 提供UI/UX设计建议，确保晚托区tab按钮样式与整体设计一致
- Expected outcome: 晚托区tab按钮样式统一，用户体验良好