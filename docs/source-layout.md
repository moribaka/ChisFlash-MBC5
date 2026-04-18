# 仓库结构说明

## 当前目录职责

| 路径 | 作用 |
| --- | --- |
| `GBX_config/` | 配置文件，用于相关卡带工具或烧录工具场景 |
| `gerber/` | 生产用 Gerber 文件 |
| `menu/` | 多合一卡菜单 ROM |
| `pcb/` | PCB 原始工程 |
| `picture/` | 图片与展示素材 |
| `pof/` | CPLD 编程文件 |
| `verilog/` | CPLD 逻辑源码 |
| `docs/` | 文档与导航说明 |

## 这个仓库的特点

和只放发布产物的仓库不同，`ChisFlash-MBC5` 已经同时包含：

- 可生产的硬件文件
- 可烧录的固件产物
- 可继续修改的 Verilog 源码

这让它既适合作为发布仓库，也适合作为开源硬件 / CPLD 项目的协作入口。

## 推荐浏览顺序

1. 先看根目录 `README.md`
2. 再看 [variants.md](variants.md) 确认版本对应关系
3. 如果想直接制作，继续看 [build-notes.md](build-notes.md)
4. 如果想改逻辑，进入 `verilog/`
5. 如果想做板子，进入 `pcb/` 和 `gerber/`
