# Linux Dashboard

> 一个基于 Qt 5 + QML 的 Linux 系统资源实时监控桌面小部件

![Platform](https://img.shields.io/badge/platform-Linux-blue)
![Qt](https://img.shields.io/badge/Qt-5.9%2B-green)
![License](https://img.shields.io/badge/license-MIT-orange)

---

## 效果预览

透明无边框，常驻桌面，实时刷新，支持透明度调节与折叠隐藏。

---

## 功能特性

### 监控指标

| 模块 | 数据来源 | 内容 |
|---|---|---|
| 处理器 | `/proc/stat` | 实时占用率、60秒历史折线图、CPU温度 |
| 物理内存 | `/proc/meminfo` | 使用量、总量、使用率百分比 |
| 磁盘读写 | `/proc/diskstats` | 实时读写速率，自动换算单位（KB/s → MB/s → GB/s） |
| 网络流量 | `/proc/net/dev` | 实时上行 / 下行速率 |
| 进程统计 | `/proc/loadavg` | 当前系统进程总数 |
| CPU温度 | `/sys/class/hwmon` | 支持 coretemp / k10temp / zenpower，回退 thermal_zone |

### 窗口交互

- **无边框透明**：融入桌面背景，不遮挡其他窗口
- **常驻置顶**：始终显示在最上层
- **拖拽移动**：鼠标拖动标题栏任意移动位置
- **折叠隐藏**：点击橙色按钮将面板收起为标题条，再次点击展开
- **位置锁定**：点击锁定按钮后禁止拖拽，防止误操作
- **透明度调节**：标题栏滑条实时调整整体透明度（20% ~ 100%）
- **负载预警**：颜色随资源占用动态变化（青色 → 黄色 → 橙色 → 红色）

---

## 环境要求

| 依赖 | 版本要求 |
|---|---|
| 操作系统 | Linux（Ubuntu 18.04+ 或同等发行版） |
| Qt | 5.9 或以上 |
| Qt 模块 | `qml` `quick` `widgets` |
| 编译器 | GCC 7+ 或 Clang，需支持 C++11 |
| 构建工具 | qmake |

---

## 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/your-username/LinuxDashboard.git
cd LinuxDashboard
```

### 2. 安装依赖（Ubuntu / Debian）

```bash
sudo apt install qt5-default qtdeclarative5-dev
```

### 3. 编译

```bash
cd LinuxDashboard
qmake LinuxDashboard.pro
make
```

### 4. 运行

```bash
./LinuxDashboard
```

### 使用 Qt Creator 编译

1. 用 Qt Creator 打开 `LinuxDashboard.pro`
2. 选择 Desktop 套件
3. 点击构建并运行

---

## 项目结构

```
LinuxDashboard/
├── main.cpp              # 程序入口，初始化窗口与 QML 引擎
├── systeminfo.h          # 数据采集模块头文件
├── systeminfo.cpp        # 数据采集模块实现（读取 /proc 文件）
├── widgetmanager.h       # 小部件管理器头文件
├── widgetmanager.cpp     # 小部件管理器实现
├── main.qml              # 主界面（四卡片布局、标题栏交互）
├── qml.qrc               # QML 资源文件索引
└── LinuxDashboard.pro    # Qt 工程配置文件
```

---

## 架构说明

项目采用**前后端分离**架构：

```
┌─────────────────────────────────────────┐
│             LinuxDashboard              │
├────────────────────┬────────────────────┤
│   数据采集模块      │    界面展示模块     │
│   SystemInfo       │    main.qml        │
│                    │                    │
│  每秒读取 /proc     │   四个监控卡片     │
│  差值法计算速率     │   标题栏交互       │
│  维护60秒历史队列   │   动画与颜色预警   │
├────────────────────┴────────────────────┤
│              通信机制                    │
│   Qt 信号槽 / Q_PROPERTY 属性绑定        │
└─────────────────────────────────────────┘
```

**数据流**：`定时器触发` → `读取 /proc` → `计算指标` → `emit dataChanged()` → `QML 自动刷新`

**CPU 占用率计算原理（差值法）**：

```
CPU 占用率 = (本次活跃时间 - 上次活跃时间) / (本次总时间 - 上次总时间)
```

其中活跃时间 = 总时间 - 空闲时间 - iowait 时间，每秒采样一次取差值，避免直接读取累计值的误差。

---

## 支持的磁盘设备类型

| 前缀 | 设备类型 |
|---|---|
| `sd*` | SATA / SAS 硬盘（sda、sdb...） |
| `nvme*` | NVMe 固态硬盘 |
| `vd*` | KVM 虚拟磁盘 |

> 注：程序自动识别物理盘，忽略 loop 设备和光驱。

---

## CPU 温度支持

程序按以下顺序尝试读取温度：

1. `/sys/class/hwmon/hwmonX/` 中名称为 `coretemp`（Intel）、`k10temp` / `zenpower`（AMD）的传感器
2. 回退到 `/sys/class/thermal/thermal_zone0/temp`

虚拟机环境下温度通常显示为 `N/A`，属正常现象。

---

## 常见问题

**Q：内存显示 0/0 MB？**

确认程序有权限读取 `/proc/meminfo`，通常直接运行无需额外权限。如果在沙盒环境中运行可能受限。

**Q：磁盘 / 网络速率一直为 0？**

第一秒采样无历史数据，速率显示为 0 属正常现象，第二秒开始正常显示。如持续为 0，请确认磁盘设备名是否在支持列表内（`cat /proc/diskstats` 查看）。

**Q：程序启动后立即退出？**

部分 Linux 桌面环境对 `Qt::Tool` 窗口处理方式不同。可将 `main.cpp` 中的窗口标志改为：

```cpp
window->setFlags(Qt::FramelessWindowHint | Qt::WindowStaysOnTopHint);
```

**Q：透明效果不生效？**

需要桌面环境支持混合渲染（Compositor）。GNOME、KDE、XFCE（开启混合渲染后）均支持。纯 X11 无混合渲染环境下背景会显示为纯色。

---

## 开发计划

- [ ] 支持 CPU 多核独立监控
- [ ] 支持自定义刷新频率
- [ ] 支持主题色切换
- [ ] 添加系统托盘图标
- [ ] 支持开机自启配置

---

## 许可证

本项目基于 [MIT License](LICENSE) 开源。

---

## 致谢

- 数据来源：Linux 内核虚拟文件系统 `/proc` 与 `/sys`
- UI 框架：[Qt 5](https://www.qt.io/) / QML
