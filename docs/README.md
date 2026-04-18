# 文档中心

这里是 `ChisFlash-MBC5` 的文档入口，主要用于把仓库里的源码、生产文件、烧录文件和使用说明串起来，方便 GitHub 访客快速理解项目结构。

## 建议先看

- [variants.md](variants.md)：硬件版本与文件对应关系
- [build-notes.md](build-notes.md)：制作、焊接、烧录和版本匹配要点
- [compatibility.md](compatibility.md)：兼容性、功能现状与待验证项
- [source-layout.md](source-layout.md)：仓库结构说明
- [licensing.md](licensing.md)：许可证与仓库说明

## 当前仓库里已经有的内容

- `verilog/`：CPLD 逻辑源码
- `pof/`：CPLD 编程文件
- `pcb/`：PCB 工程文件
- `gerber/`：Gerber 生产文件
- `menu/`：多合一卡菜单 ROM
- `GBX_config/`：相关工具配置文件
- `picture/`：项目图片

## 这个仓库当前最适合做什么

- 查看不同版本卡带的文件与产物
- 直接获取生产文件与固件
- 基于现有 Verilog 和 PCB 资料继续修改
- 给社区成员提供统一的导航入口
