# AutoCAD ObjectARX 2019 插件开发模板

基于 CMake + Visual Studio 2022 的 AutoCAD ObjectARX 2019 插件开发模板，开箱即用。

## 环境要求

- **操作系统**: Windows 10/11 x64
- **编译器**: Visual Studio 2022 (MSVC 193x)
- **构建工具**: CMake >= 3.15
- **SDK**: [ObjectARX 2019 SDK](https://www.autodesk.com/developer-network/platform-technologies/autocad/objectarx)

## 快速开始

### 1. 克隆项目

```bash
git clone <your-repo-url>
cd autocad-objectarx-template
```

### 2. 配置 ObjectARX 路径

编辑 `CMakeLists.txt` 顶部第 7 行：

```cmake
set(OBJECTARX_ROOT "C:/Autodesk/Autodesk_ObjectARX_2019_Win_64_and_32_Bit")
```

修改为你的 ObjectARX 2019 SDK 实际安装路径。

### 3. 编译项目

**方式一：使用批处理脚本（推荐）**

```bash
# 一键构建
build.bat

# 清理构建文件
clean.bat

# 重新构建（清理+构建）
rebuild.bat
```

**方式二：手动 CMake 命令**

```bash
mkdir build && cd build
cmake .. -G "Visual Studio 17 2022" -A x64
cmake --build . --config Release
```

### 4. 加载到 AutoCAD

编译成功后，ARX 文件位于 `bin/MyPlugin.arx`。

在 AutoCAD 中执行以下命令加载：

```
NETLOAD
```

或直接拖拽 ARX 文件到 AutoCAD 窗口。

### 5. 测试命令

加载后输入命令：

```
TESTOPENDWG
```

该命令会弹出文件选择对话框，选择任意 DWG 文件后显示打开耗时统计。

## 项目结构

```
autocad-objectarx-template/
├── CMakeLists.txt          # CMake 配置文件（核心配置）
├── src/
│   └── demo.cpp            # 示例命令实现
├── include/                # 头文件目录（可选）
├── bin/                    # 输出目录（自动生成）
├── build/                  # 构建目录（自动生成）
├── build.bat               # 构建脚本
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

A: 检查 `CMakeLists.txt` 中的 `OBJECTARX_ROOT` 路径是否正确，确保路径下存在 `inc/` 和 `lib-x64/` 目录。

### Q: AutoCAD 无法加载 ARX 文件？

A: 确保编译架构为 x64，且 AutoCAD 版本与 ObjectARX SDK 版本匹配（2019）。

### Q: 如何调试 ARX 插件？

A: 在 Visual Studio 中打开 `build/MyPlugin.sln`，设置 AutoCAD 为启动程序（`acad.exe`），附加调试即可。

## 许可证

MIT License - 自由使用和修改

## 参考资源

- [ObjectARX 官方文档](https://help.autodesk.com/view/OARX/2019/ENU/)
- [AutoCAD Developer Center](https://www.autodesk.com/developer-network/platform-technologies/autocad)
