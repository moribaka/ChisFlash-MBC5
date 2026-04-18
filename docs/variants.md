# 硬件版本与文件对应

## 版本映射表

| 版本 | PCB 工程 | Gerber | POF 固件 | 图片 |
| --- | --- | --- | --- | --- |
| `8M` | `../pcb/ProDoc_ChisFlash-MBC5-v1.21_8M.epro` | `../gerber/Gerber_ChisFlash-MBC5-v1.21_2025-08-17.zip` | `../pof/ChisFlash-MBC5-v1.21_8M_4in1or3in1.pof` | `../picture/ChisFlash_MBC5_8M.png` |
| `8M Plus` | `../pcb/ProDoc_ChisFlash-MBC5-Plus-v1.21_8M.epro` | `../gerber/Gerber_ChisFlash-MBC5-Plus-v1.21_2025-08-17.zip` | `../pof/ChisFlash-MBC5-v1.21_8M_4in1or3in1.pof` | `../picture/ChisFlash_MBC5_8M_PLUS.png` |
| `MAX 32M` | `../pcb/ProDoc_ChisFlash-MBC5-MAX-v1.22_32M.epro` | `../gerber/Gerber_ChisFlash-MBC5-MAX-v1.22_2025-08-17.zip` | `../pof/ChisFlash-MBC5-MAX-v1.22_32M_16in1.pof` | `../picture/ChisFlash_MBC5_MAX_32M.png` |
| `MAX 32M R0603` | `../pcb/ProDoc_ChisFlash-MBC5-MAX-v1.22-R0603_32M..epro` | `../gerber/Gerber_ChisFlash-MBC5-MAX-v1.22-R0603_2025-08-17.zip` | `../pof/ChisFlash-MBC5-MAX-v1.22_32M_16in1.pof` | `../picture/ChisFlash_MBC5_MAX_32M_R0603.png` |

## 菜单与配置文件

- `../menu/ChisFlash_MBC5_MAX_16in1_MENU.gb`
- `../menu/MoriMENU_16in1_EX_v1.02.gb`
- `../GBX_config/fc_DMG_ChisMBC8M_GL064.txt`
- `../GBX_config/fc_DMG_ChisMBCMAX_with_28EW256A(Buffer).txt`
- `../GBX_config/fc_DMG_ChisMBCMAX_with_S29GL256N(Buffer).txt`

## 使用建议

- 先确定要做的是 `8M` 还是 `MAX 32M`
- 再根据是否需要电平转换、是否偏好 `R0603` 封装来选具体板型
- 固件版本要和硬件版本对应，不要混烧
