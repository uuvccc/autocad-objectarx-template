# AutoCAD ObjectARX 插件开发模板

基于 CMake + Visual Studio 的 AutoCAD ObjectARX 插件开发模板，不限定 SDK/VS/CMake 版本，开箱即用。

## 环境要求

- **操作系统**: Windows 10/11 x64
- **编译器**: Visual Studio 2017/2019/2022（MSVC，自动检测）
- **构建工具**: CMake >= 3.0
- **SDK**: [ObjectARX SDK](https://www.autodesk.com/developer-network/platform-technologies/autocad/objectarx)（任意版本）

## 快速开始

### 1. 克隆项目

```bash
git clone <your-repo-url>
cd autocad-objectarx-template
```

### 2. 指定 ObjectARX SDK 路径

无需修改任何源文件，通过以下任一方式传入 SDK 路径：

| 方式 | 命令 | 说明 |
|---|---|---|
| 命令行参数 | `build.bat "C:\path\to\ObjectARX_SDK"` | 最直接 |
| 环境变量 | `set OBJECTARX_ROOT=C:\path\to\ObjectARX_SDK` | 推荐加入系统环境变量，一劳永逸 |
| CMake 参数 | `cmake -DOBJECTARX_ROOT=C:/path/to/ObjectARX_SDK` | 手动 CMake 时使用 |

优先级：命令行参数 > 环境变量 > CMake 参数

### 3. 编译项目

**方式一：使用批处理脚本（推荐）**

```bash
REM 直接传入 SDK 路径
build.bat "C:\Autodesk\ObjectARX_2024"

REM 或先设置环境变量
set OBJECTARX_ROOT=C:\Autodesk\ObjectARX_2024
build.bat

REM 其他命令
clean.bat          REM 清理构建文件
rebuild.bat        REM 重新构建（清理+构建）
```

`build.bat` 会自动检测已安装的 Visual Studio 版本（2022 → 2019 → 2017 优先），无需手动指定 Generator。

**方式二：手动 CMake 命令**

```bash
mkdir build && cd build
cmake .. -A x64 -DOBJECTARX_ROOT=C:/Autodesk/ObjectARX_2024
cmake --build . --config Release
```

### 4. 加载到 AutoCAD

编译成功后，ARX 文件位于 `bin/MyPlugin.arx`。

在 AutoCAD 中执行以下命令加载：

```
APPLOAD
```

或直接拖拽 ARX 文件到 AutoCAD 窗口。

> ARX 文件必须与 AutoCAD 版本匹配（如 ObjectARX 2019 编译 → AutoCAD 2019）。

### 5. 测试命令

加载后输入命令：

```
TESTOPENDWG
```

该命令会弹出文件选择对话框，选择任意 DWG 文件后显示打开耗时统计。

## 自动版本适配

CMakeLists.txt 会自动从 SDK 目录检测版本信息，无需手动配置：

- **库版本号**：从 `lib-x64/acdb*.lib` 文件名自动提取（如 `acdb23.lib` → 版本号 `23`）
- **库名拼接**：`acdb${ARX_LIB_VER}.lib`、`acge${ARX_LIB_VER}.lib`、`ac1st${ARX_LIB_VER}.lib` 自动适配

如果自动检测失败，可手动指定：

```bash
cmake .. -DARX_LIB_VER=23
```

| AutoCAD 版本 | acdb 库 | 版本号 |
|---|---|---|
| 2019 | acdb23.lib | 23 |
| 2020-2022 | acdb24.lib | 24 |
| 2023 | acdb26.lib | 26 |
| 2024 | acdb27.lib | 27 |
| 2025 | acdb28.lib | 28 |

## 项目结构

```
autocad-objectarx-template/
├── CMakeLists.txt          # CMake 配置文件（核心配置）
├── src/
│   └── demo.cpp            # 示例命令实现
├── include/                # 头文件目录（可选）
├── bin/                    # 输出目录（自动生成）
├── build/                  # 构建目录（自动生成）
├── build.bat               # 构建脚本（支持命令行传入 SDK 路径）
├── clean.bat               # 清理脚本
├── rebuild.bat             # 重新构建脚本
├── README.md               # 项目说明
└── .gitignore              # Git 忽略配置
```

## 添加新命令

1. 在 `src/` 目录下创建新的 `.cpp` 文件
2. 使用 `acedRegCmds->addCommand()` 注册命令
3. 运行 `rebuild.bat` 重新编译

CMake 会自动扫描 `src/` 下所有源文件，无需手动修改 `CMakeLists.txt`。

## 常见问题

### Q: 编译提示找不到 ObjectARX 头文件？

A: 确认已正确指定 `OBJECTARX_ROOT`，路径下需存在 `inc/` 和 `lib-x64/` 目录。

### Q: 编译提示 Could not auto-detect ObjectARX lib version？

A: 自动检测失败，手动指定版本号：`cmake .. -DARX_LIB_VER=23`（23 对应 AutoCAD 2019）。

### Q: AutoCAD 无法加载 ARX 文件？

A: 确保编译架构为 x64，且 AutoCAD 版本与 ObjectARX SDK 版本匹配。

### Q: 如何调试 ARX 插件？

A: 在 Visual Studio 中打开 `build/` 下的 `.sln` 文件，设置 AutoCAD 为启动程序（`acad.exe`），附加调试即可。

## 许可证

MIT License - 自由使用和修改

## 参考资源

- [ObjectARX 官方文档](https://help.autodesk.com/view/OARX/2019/ENU/)
- [AutoCAD Developer Center](https://www.autodesk.com/developer-network/platform-technologies/autocad)
