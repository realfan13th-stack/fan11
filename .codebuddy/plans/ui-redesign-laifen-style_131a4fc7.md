---
name: ui-redesign-laifen-style
overview: 参考 Laifen App 设计语言，对 schedule_v103.html 进行 6 项 UI 优化：Tab区高度扩展+滑动指示器、代换课模块宽松排版、周视图日期选择器单行右置、课表三视图尺寸统一、标题区去竖线并改底色、全局底色规则（内容白底/其他主色底）。
design:
  architecture:
    framework: html
  styleKeywords:
    - 极简主义
    - 宽松呼吸感
    - 灰底白卡
    - 滑动指示器
    - Laifen风格
    - 圆角14px
    - 极轻阴影
  fontSystem:
    fontFamily: PingFang SC, -apple-system, SF Pro, system-ui, sans-serif
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
      - "#4E648A"
    background:
      - "#F9FCF6"
      - "#FFFFFF"
    text:
      - "#1D1D1F"
      - "#69697C"
      - "#8E8E93"
    functional:
      - "#e74c3c"
      - "#f39c12"
      - "#34C759"
todos:
  - id: tab-height-slider
    content: 扩展Tab区高度56→64px，新增滑动指示器CSS与JS驱动逻辑
    status: completed
  - id: subswap-spacing
    content: 宽松化代换课模块排版：内边距、行间距、字号、圆角全面增大
    status: completed
  - id: weekly-date-inline
    content: 周视图日期选择器强制单行不折行，日期输入区靠右对齐
    status: completed
  - id: class-grid-unify
    content: 统一三课表视图圆角14px、阴影、表头padding，确保视觉一致
    status: completed
    dependencies:
      - weekly-date-inline
  - id: title-bar-redesign
    content: 删除标题区竖线|，top-bar底色改--bg，标题字号调整为18-22px
    status: completed
  - id: global-bg-adjust
    content: 调整left-panel底色为--bg，确认内容区白底不变
    status: completed
    dependencies:
      - title-bar-redesign
  - id: verify-and-sync
    content: 验证所有视觉效果，git commit + push 同步仓库
    status: completed
    dependencies:
      - tab-height-slider
      - subswap-spacing
      - class-grid-unify
      - global-bg-adjust
---

