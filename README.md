嘉立创开源地址：
https://oshwhub.com/morinaka/chisflash-mbc5-gbc-shao-lu-ka

https://oshwhub.com/morinaka/chisflash-mbc5-max-32m-gbc-shao-lu-ka

目前大部分GB烧录卡都是从正版卡上面拆芯片来制作，可以说是拆一张少一张，虽然我也不玩正版卡但看着有点心疼就想着能不能用CPLD替代MBC芯片，于是就有了这个项目。

从github得知项目NekoCart-GB是开源的MBC5烧录卡，也是使用CPLD芯片替代MBC5芯片。

于是我参考NekoCart-GB制作了ChisFlash-MBC5烧录卡，板子和原理图重绘，存档供电的双路供电使用mos管来做切换，固件从原项目移植并做了适配。

 

本卡特点：

1.使用CPLD芯片（EPM240）替代正版MBC5主控，ROM采用8M flash芯片（MAX版本为32M），RAM采用128K SRAM芯片（MAX版本为512K），可以烧录最大8M的单游戏。

2.支持最多4in1合卡（MAX版本为16in1），游戏大小为菜单1M+游戏1M+游戏2M*3（MAX版本为菜单1M+游戏1M+游戏2M*15），存档为32K*4（MAX版本为32K*16）。各存档独立，不会互相覆盖。

3.普通版不使用电平转换芯片；plus版使用电平转换芯片，兼容AP。不清楚AP掌机是否支持普通版，等一个有缘人测试。

4.理论支持MBC5游戏和兼容部分MBC1、MBC2、MBC3游戏，具体兼容性未知，个人精力有限未能完全测试。

5.未来将支持震动和更多合卡组合

6.配合NDS上的烧录软件“gbcburn”可以实现使用NDS烧录此卡，而不用额外购买烧录器。

 

制作要点：

1.焊接完成后请测量电池正极到电阻一侧电压，如果发现电压缓慢下降或者无电压，则是电池底部接触不良，需要在底部焊上一点锡，顶住电池。

2.plus的排阻，最左侧一个为30Ω，右侧七个都是470Ω。

3.v1.1固件适配硬件v1.1 v1.2 v1.21。 而v1.21固件仅适用于硬件v1.21 v1.22

 

更新日志

2024年10月9日 更新普通版v1.1，加强版v1.1

2024年11月28日 更新普通版v1.2，加强版v1.2；从nor flash上断开rst并拉高，从而实现可以用NDS烧录。

2024年12月19日 更新普通版v1.21，扩大电池负极焊盘；加强版v1.21，增加排阻兼容焊盘，扩大电池负极焊盘。

2025年2月26日 更新1.2固件，8M版本支持3合1（1+2+4），支持4合1（1+2+2+2），支持单卡。

 
ChisFlash是一个大型的复古游戏机相关的开源复刻项目，旨在为复古游戏玩家提供便宜好用的硬件方案，享受diy的乐趣。

感谢NekoCart-GB：https://github.com/zephray/NekoCart-GB

感谢提供NDS烧录方案的大佬：@shn

联动：
开源的GBA烧录卡chisflash：https://github.com/ChisBread/ChisFlash

GBA大小的款式mini-ChisMBC5：https://oshwhub.com/cidazl/mini-chis-mbc5gbc-burn-card

专为GBA设计的多功能便携式卡带编程器chislink：https://github.com/ChisBread/ChisLink

为ChisFlash设计的一款烧录器beggar_socket：https://github.com/julpage/beggar_socket

beggar_socket的web应用：https://github.com/tautcony/beggar_socket


PCB图片：
 
![ChisFlash_MBC5_8M](https://github.com/moribaka/ChisFlash-MBC5/blob/main/picture/ChisFlash_MBC5_8M.png)

ChisFlash_MBC5_8M

![ChisFlash_MBC5_8M_PLUS](https://github.com/moribaka/ChisFlash-MBC5/blob/main/picture/ChisFlash_MBC5_8M_PLUS.png)

ChisFlash_MBC5_8M_PLUS

![ChisFlash_MBC5_MAX_32M](https://github.com/moribaka/ChisFlash-MBC5/blob/main/picture/ChisFlash_MBC5_MAX_32M.png)

ChisFlash_MBC5_MAX_32M

![ChisFlash_MBC5_MAX_32M_R0603](https://github.com/moribaka/ChisFlash-MBC5/blob/main/picture/ChisFlash_MBC5_MAX_32M_R0603.png)

ChisFlash_MBC5_MAX_32M_R0603


