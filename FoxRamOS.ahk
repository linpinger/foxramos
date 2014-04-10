/*
; 修改 firadisk.inf 为 LoadOrderGroup = Boot Bus Extender
; hklm\SYSTEM\ControlSet001\Control\ServiceGroupOrder

把Hotswap！放到system32目录下。
扫描硬盘：HotSwap! -s
停止硬盘：HotSwap! c: -Q

Devcon.exe的应用：
扫描设备：devcon.exe rescan
卸载硬盘：devcon.exe remove @ide\*

WMI里的CIM_LogicalDevice类的SetPowerState函数可以设置硬盘电源
*/

VersionDate := "2012-9-18"
stringleft, SysDL, A_WinDir, 1 ; 系统所在盘的字母
SysDL2 := SysDL . ":"

GuiInit:
	GUi +LastFound
	NowWinID := Winexist()  ; 格式化窗口需要

	Menu, FAMenu, Add, 安装微软RamDisk驱动(&D), OtherMethod
	Menu, FAMenu, Add, 解决微软RamDisk发现新硬件问题(&F), OtherMethod

	Menu, CZMenu, Add, 安装imDisk(&I), OtherActionS
	Menu, CZMenu, Add, 挂载镜像(&M), OtherActionS
	Menu, CZMenu, Add, 卸载镜像(&U), OtherActionS
	Menu, CZMenu, Add ;---------------------
;	Menu, CZMenu, Add, 安装FileDisk(&F), OtherActionS
	Menu, CZMenu, Add, VDM一键挂载(&V), OtherActionS
	Menu, CZMenu, Add ;---------------------
	Menu, CZMenu, Add, 使用StrArc热备份(&A), OtherActionS
	Menu, CZMenu, Add, 使用Reg导出所有注册表(&S), OtherActionS
	Menu, CZMenu, Add ;---------------------
	Menu, CZMenu, Add, 重启计算机(&R) Win+F11, OtherActionS

	Menu, HelpMenu, Add, 更新日志(&R), FoxHelp
	Menu, HelpMenu, Add
	Menu, HelpMenu, Add, 用法(&D), FoxHelp
	Menu, HelpMenu, Add
	Menu, HelpMenu, Add, 问题(&P), FoxHelp
	Menu, HelpMenu, Add
	Menu, HelpMenu, Add, 关于(&A), FoxHelp

	Menu, SiteMenu, Add, www.olsoul.com(&W), FoxHelp
	Menu, SiteMenu, Add, bbs.olsoul.com(&B), FoxHelp
	Menu, SiteMenu, Add
	Menu, SiteMenu, Add, 本工具首发地址(&R), FoxHelp
	Menu, SiteMenu, Add, 本工具源代码地址(&S), FoxHelp
	Menu, SiteMenu, Add, 本工具下载地址(www.autohotkey.net), FoxHelp
	; 下面是菜单栏

	Menu, MyMenuBar, Add, 驱动方案(&F), :FAMenu
	Menu, MyMenuBar, Add, 操作(&O), :CZMenu
	Menu, MyMenuBar, Add, 友情链接(&L), :SiteMenu
	Menu, MyMenuBar, Add, 帮助(&H), :HelpMenu
	Gui, Menu, MyMenuBar
	; 下面是主图形界面
	Gui, Add, GroupBox, x6 y10 w160 h100 cBlue, 1. 驱动及引导文件布置
	Gui, Add, Button, x16 y30 w140 h30 gStepA vGrub4dos, 添加Grub4Dos引导项
	Gui, Add, Button, x16 y70 w140 h30 gStepA vFiraDisk, 安装FiraDisk驱动

	Gui, Add, GroupBox, x176 y10 w370 h110 cBlue, 2. 镜像文件操作:
	Gui, Add, GroupBox, x186 y30 w160 h80 cGreen, 创建镜像(路径，大小):
	Gui, Add, ComboBox, x196 y50 w140 h20 R26 Choose2 vImgPath, 内存盘|D:\RamOS.img|D:\Ram2K3.img|E:\RamOS.img
	Gui, Add, Edit, x196 y80 w40 h20 vImgSize, 444
	Gui, Add, Text, x246 y83 w8 h20 cGreen, M
	Gui, Add, Button, x266 y80 w70 h20 gStepB vCreateImg, 创建(&C)
Gui, Add, Button, x356 y40 w80 h40 gStepB vMountImg, 挂载到(&M)>>
Gui, Add, Button, x356 y90 w80 h20 gStepB vUnMountImg, 卸载(&U)
	Gui, Add, GroupBox, x446 y30 w90 h80 cGreen, Img挂载盘符
	Gui, Add, ComboBox, x456 y50 w70 h20 R26 Choose1 vMountDrive, A:|R:|S:
	Gui, Add, Button, x456 y80 w70 h20 gStepB vFormat, 格式化

	Gui, Add, GroupBox, x6 y120 w160 h100 cBlue, 3. 文件备份:
	Gui, Add, Button, x16 y140 w140 h30 gStepC vCopyVolume, 热备份
	Gui, Add, Button, x16 y180 w140 h30 gStepC vRegBakSystem, reg命令备份system文件

	Gui, Add, GroupBox, x176 y130 w370 h90 cBlue, 4. 盘符问题:
	Gui, Add, Button, x186 y150 w50 h50 gStepD vMountReg, 加载配置单元
	Gui, Add, GroupBox, x246 y150 w60 h50 cGreen, 实机盘符
	Gui, Add, ComboBox, x256 y170 w40 h20 R26 Choose1 vTrueDrive gChangeVolume, % GetVolList4DD() ; 获取驱动器列表
	Gui, Add, Button, x316 y150 w80 h20 gStepD vWriteReg, 修改为>>
	Gui, Add, Button, x316 y180 w80 h20 gStepD vOpenReg, 注册表确认
	Gui, Add, GroupBox, x406 y150 w70 h50 cGreen, RamOS盘符
	Gui, Add, ComboBox, x416 y170 w50 h20 R26 Choose1 vImgDrive, B:
	Gui, Add, Button, x486 y150 w50 h50 gStepD vUnMountReg, 卸载配置单元
	; Generated using SmartGUI Creator 4.0

	Gui, Add, Progress, +Hidden cGreen x6 y224 w540 h10 vJinDu, 0
	Gui, Add, StatusBar, , 我是状态栏
	SB_SetParts(355, 200)
	Gui, show, y30 h258 w555, 爱尔兰之狐 的 RamOS 制作工具 %VersionDate%

	Gosub, ChangeVolume    ; 显示 盘符对应的 注册表值
	Gosub, FoxsSizeAdvice  ; 预估镜像大小并给出建议值
	Guicontrol, focus, MountImg
return


ChangeVolume: ; 显示 盘符对应的 注册表值
	Gui, submit, Nohide
	TrueValue := VolumeReg(0, TrueDrive)  ; TrueValue 有引用的噢
	SB_SetText(TrueDrive . " " . TrueValue, 2)
return

FoxsSizeAdvice:  ; 预估镜像大小并给出建议值
	SysMemSize := GetSysMemSize()  ; 物理内存数 M
	DriveGet, Size_All, Capacity, %SysDL%:\
	DriveSpaceFree, Size_Free, %SysDL%:\
	Size_Used := round(3 * ( Size_All - Size_Free ) / 4) ; 预估镜像大小=3/4 * 已用大小

	If ( ( SysMemSize - Size_Used ) < 100 ) {
		SB_SetText(SysDL . "盘过大  预估压缩镜像: " . Size_Used " M  物理内存: " . SysMemSize . " M" )
		Guicontrol, Text, ImgSize, 0
	} else {
		SB_SetText("预估压缩镜像: " . Size_Used " M  物理内存: " . SysMemSize . " M" )
		Guicontrol, Text, ImgSize, %Size_Used%
	}
Return


OtherMethod:  ; 菜单: 驱动方案
	If ( A_thismenuitem = "安装微软RamDisk驱动(&D)" ) {
		msgbox, 260, 确认, 确认安装 微软的 RamDisk ?
		Ifmsgbox, yes
			SB_SetText(InstallRamDisk(SysDL))
		else
			SB_SetText("不安装 Ramdisk")
	}
	If ( A_thismenuitem = "解决微软RamDisk发现新硬件问题(&F)" )
		SB_SetText(RamDiskNoNewDevice())
return

OtherActionS: ; 菜单: 操作
	Gui, submit, nohide
	If ( A_thismenuitem = "安装imDisk(&I)" )
		SB_SetText(InstallimDisk())
;	If ( A_thismenuitem = "安装FileDisk(&F)" )
;		SB_SetText(InstallFileDisk())
	If ( A_thismenuitem = "挂载镜像(&M)" ) {
		IfNotExist, %A_windir%\system32\drivers\imdisk.sys
			SB_SetText(InstallimDisk()) ; 安装虚拟光驱驱动
		SB_SetText(mountImg(ImgPath, MountDrive))
	}
	If ( A_thismenuitem = "卸载镜像(&U)" )
		SB_SetText(UnmountImg(MountDrive))
	If ( A_thismenuitem = "VDM一键挂载(&V)" ) {
		SetVDM(1, ImgPath, MountDrive)
		Run, % TestExePath("D:\bin\isotool\VDM1.exe," . A_scriptdir . "\FoxRamOS\VDM\VDM1.exe,C:\bin\isotool\VDM1.exe,X:\WXPE\SYSTEM32\VDM1.exe"), , Min
		
	}
	If ( A_thismenuitem = "使用StrArc热备份(&A)" ) {
		IfExist, %MountDrive%\
			runwait, cmd /c strarc -r -cd:%SysDL%: | strarc -xld:%MountDrive% , %A_scriptdir%\FoxRamOS
		SB_SetText("恭喜: 用StrArc备份完毕")
	}
	If ( A_thismenuitem = "使用Reg导出所有注册表(&S)" ) {
		SaveAllHives(MountDrive . "\")
		SB_SetText("恭喜: 注册表全部导出完毕")
	}
	If ( A_thismenuitem = "重启计算机(&R) Win+F11" )
		gosub, Reboot
return

StepA:
	If ( A_guiControl = "Grub4dos" ) {
		SB_SetText(InstallGrub4Dos(SysDL))
		msgbox, 260, 检查, 要确认一下吗
		IfMsgbox, Yes
			run, explorer %SysDL%:\
	}
	If ( A_guiControl = "FiraDisk" )
		SB_SetText("FiraDisk 安装中...") , SB_SetText(InstallFiraDisk())
return

StepB:
	Gui, Submit, Nohide
	If ( ( A_guiControl = "CreateImg" or A_guiControl = "MountImg" ) and ImgPath = "内存盘" ) {
		IfNotExist, %A_windir%\system32\drivers\imdisk.sys
			SB_SetText(InstallimDisk())
		runwait, imdisk -a -s %imgSize%m -m %MountDrive% -p "/FS:fat /q /y", , Hide
		SB_SetText("创建内存盘 " . MountDrive . "完毕, 大小: " . imgSize . " M")
		return
	}
	If ( A_guiControl = "CreateImg" ) {
		stringleft, ImgPathDrive, ImgPath, 3
		DriveSpaceFree, ImgPathDriveSize, %ImgPathDrive%
		If ( ImgPathDriveSize < imgSize ) {
			SB_SetText("要创建img所在空间不足，请调整大小")
			return
		}
		IfExist, %ImgPath%
		{
			SB_SetText("img文件存在，请重命名原文件")
			return
		}
		SB_SetText(ImgPath . "  创建中...")
		CreateBlankFile(ImgPath, ImgSize*1024*1024)
		SB_SetText("IMG创建完毕: " . ImgPath . "  大小: " . ImgSize . " M")
	}
	If ( A_guiControl = "MountImg" ) {
		IfNotExist, %A_windir%\system32\drivers\imdisk.sys
			SB_SetText(InstallimDisk()) ; 安装虚拟光驱驱动
		SB_SetText(mountImg(ImgPath, MountDrive))
	}
	If ( A_guiControl = "UnMountImg" )
		SB_SetText(UnmountImg(MountDrive))
	If ( A_guiControl = "Format" ) {
		stringleft, SelDriver, MountDrive, 1
		Dllcall("Shell32.dll\SHFormatDrive", "Uint", NowWinID, "Uint"
		, ASC(SelDriver)-65, "Uint", 0xFFFF, "Uint", 1)
	}
return

StepC:
	Gui, Submit, Nohide
	If ( A_guiControl = "CopyVolume" ) {
		driveGet, MMDslsdStatus, FS, %MountDrive%
		If ( MMDslsdStatus = "" or ErrorLevel = 1 ) {
			SB_SetText(MountDrive . " 不存在或未格式化")
			return
		}
		sTime := A_tickcount
		CopyVolume(SysDL2, MountDrive)
		IniWrite, 0, %MountDrive%\boot.ini, boot loader, timeout
		IniDelete, %MountDrive%\boot.ini, operating systems, %SysDL2%\grldr

		IfExist, %A_scriptdir%\CopyError.lst 
		{
			SB_SetText("复制完毕: 有文件未复制成功，可稍后再复制")
			run, notepad %A_scriptdir%\CopyError.lst
		} else
			SB_SetText("成功复制: " . SysDL2 . " -> " . MountDrive . " 耗时: " . ( A_tickcount - sTime ) . " 毫秒")
	}
	If ( A_guiControl = "RegBakSystem" ) {
		sb_setText("导出中: HKLM\system -> " . MountDrive . "\WINDOWS\SYSTEM32\config\system")
		RetAkssk := BakXPHiveSystem(MountDrive)
		If ( RetAkssk = 0 )
			sb_setText("成功: HKLM\system -> " . MountDrive . "\WINDOWS\SYSTEM32\config\system")
		else
			sb_setText("导出失败: " . RetAkssk)

	}
return

StepD:
	Gui, Submit, Nohide
	If ( A_guiControl = "MountReg" ) {
		IfNotExist, %MountDrive%\WINDOWS\system32\config\system
		{
			sb_setText("镜像system配置单元不存在，请先挂载")
			return
		}
		sb_setText("挂载中: HKLM\systemR")
		GuiControl, Disable, WriteReg
		runwait, REG LOAD HKLM\systemR %MountDrive%\WINDOWS\system32\config\system, , Hide
		GuiControl, Enable, WriteReg
		sb_setText("挂载完毕: HKLM\systemR")
	}
	If ( A_guiControl = "WriteReg" )
		VolumeReg(1, TrueDrive, ImgDrive, TrueValue) , sb_setText("注册表写入完毕完毕: HKLM\systemR")
	If ( A_guiControl = "OpenReg" ) {
		RegOpenPath := "Software\Microsoft\Windows\CurrentVersion\Applets\Regedit"
		RegWrite, REG_SZ, HKCU, %RegOpenPath%, LastKey, 我的电脑\HKEY_LOCAL_MACHINE\SYSTEMR\MountedDevices
		run, regedit
	}
	If ( A_guiControl = "UnMountReg" ) {
		sb_setText("卸载中: HKLM\systemR")
		runwait, REG UnLOAD HKLM\systemR, , Hide
		sb_setText("卸载完毕: HKLM\systemR")
	}
return


GuiClose:
GuiEscape:
	ExitApp
return

FoxHelp:
Problem=
(Join`n
碰到相同问题的可以参照下面的方法解决:

第一次进系统 提示重启
1. 第一次进RamOS，会出现找到新硬件,然后弹出提示重启对话框, 选择 不重启
2. 运行本工具，点击 挂载到 按钮, 挂载镜像到 A:[默认] 盘
3. 点击 reg命令备份system文件 按钮
4. 点击 卸载 按钮
5. 重启，应该就没有提示了

如果使用HotSwap程序，貌似会在下次进ramos后发现新硬件
微软ramdisk制作的镜像 444M时可用, 470M时不可用(会重启), 原因不明
   解决办法，制作空白镜像的大小要多试几次

)
Thanks=
(Join`n
作者: 爱尔兰之狐
QQ: 308639546
群号: 120902759
论坛ID: linpinger

感谢: 
OlSoul系统QQ一群: 3719654
Olsoul(QQ:额，进他的群看)
Olsoul论坛: http://bbs.olsoul.com
米果(QQ:873397921)
)
GrubFiraHelp=
(Join`n
用法说明:
   系统需存在: reg.exe sc.exe [ regini.exe ]

1. 先点击按钮安装Grub4dos, FiraDisk [可选用其他驱动[微软ramdisk(制作Ram2K3)]]
2. 创建一个空白img[文件名若要修改，需修改grldr内置菜单]，然后挂载
   挂载完毕后，点击格式化(选择 NTFS 启用压缩, 其他的貌似会蓝屏)，格式化刚才挂载的镜像
3. 点击 热备份 按钮 (初次复制耗时较长)


下面的操作是为了解决进RamOS后盘符错乱问题

1. 按 加载配置单元，选择实机盘符和ramos盘符(初次默认即可)，点击修改为按钮
2. 点击 注册表确认，确认修改成功，可以增删注册表项
3. 关闭注册表编辑器，然后点击卸载配置单元按钮

OK, 目前为止，RamOS就做好了，重启，选择条目 Grub4Dos, 进入后选 ramos

)

UpdateLog =
(Join`n
2011-05-18: 添加: 使用 imDisk 替代 FileDisk, 它功能强大，且可能避免FileDisk讨厌的卸载不了问题
            添加: 创建内存盘功能(在镜像路径中选择 内存盘,然后输入大小,选择挂载盘符,按创建或挂载按钮)
2011-03-14: 添加: Reg命令导出所有注册表(多谢qiqiqicool提点)至菜单
2011-03-09: 添加: 发现新的热备份工具strarc(http://www.ltr-data.se/opencode.html/), 添加至操作菜单
2011-03-09: 更新: 升级firadisk版本至 0.0.1.30, 据说该版本解决了2k3的蓝屏问题
2011-02-12: 添加: 把源代码放出来了，地址: http://bbs.olsoul.com/read-htm-tid-526.html
2011-01-11: 添加: 友情链接，并在主界面增加卸载按钮
2010-11-10: 添加: 菜单栏(将较少使用的功能放在工具栏中),更新GUI整体布局 
            添加: Grub4dos目录下添加grldr内置菜单编辑程序
2010-10-08: 添加: 添加reg导出system的右键菜单
2010-08-27: 更新: 热备份添加进度条, grldr内置菜单(可在grub4dos目录下放入自己的menu.lst)
2010-08-24: 更新: 将rawread编译为 rawread.dll, 便于调用

)

	If ( A_thismenuitem = "更新日志(&R)" )
		msgbox, %UpdateLog%
	If ( A_thismenuitem = "用法(&D)" )
		msgbox, %GrubFiraHelp%
	If ( A_thismenuitem = "问题(&P)" )
		msgbox, %Problem%
	If ( A_thismenuitem = "关于(&A)" )
		msgbox, %Thanks%
	If ( A_thismenuitem = "www.olsoul.com(&W)" )
		run, http://www.olsoul.com
	If ( A_thismenuitem = "bbs.olsoul.com(&B)" )
		run, http://bbs.olsoul.com
	If ( A_thismenuitem = "本工具首发地址(&R)" )
		run, http://bbs.olsoul.com/read-htm-tid-228.html
	If ( A_thismenuitem = "本工具源代码地址(&S)" )
		run, http://bbs.olsoul.com/read-htm-tid-526.html
	If ( A_thismenuitem = "本工具下载地址(www.autohotkey.net)")
		run, http://linpinger.github.io

return

Reboot: ; 重启
	msgbox,260,,真的要重启吗？
	ifmsgbox,yes
		shutdown,2
return

; -----备注:
^esc::reload
+esc::Edit
!esc::ExitApp
#F11::gosub, Reboot

BakXPHiveSystem(TarDriver="A:")
{
	XPPath := TarDriver . "\WINDOWS\SYSTEM32\config\system"
	IfNotExist, %XPPath%
		runwait, Reg SAVE HKLM\SYSTEM %XPPath%, , Hide
	else {
		msgbox,260,,system文件存在，是否覆盖？
		ifmsgbox,yes
		{
			FileDelete, %XPPath%
			runwait, Reg SAVE HKLM\SYSTEM %XPPath%, , Hide
		}
	}
	IfExist, %XPPath%
		return 0
	else
		return "导出失败，可能是目标目录不存在"
}

GetSysMemSize()  ; 获取物理内存总数(M)
{
	VarSetCapacity(MEMORYSTATUSEX,64,0) , NumPut(64,MEMORYSTATUSEX) 
	DllCall("GlobalMemoryStatusEx", UInt,&MEMORYSTATUSEX) 
	PhysMemSizeB := NumGet(MEMORYSTATUSEX,8,"Int64")
	return, Round(PhysMemSizeB/1024/1024)
}


VolumeReg(Action=0, SrcDrive="C:" , DesDrive="B:", DesValue="") ; 实机卷信息->修改->映像注册表
{
	If ( Action = 0 ) {
		RegRead, SrcValue, HKLM, SYSTEM\MountedDevices, \DosDevices\%SrcDrive%
		return, SrcValue
	} Else {
		RegDelete, HKLM, systemR\MountedDevices, \DosDevices\%SrcDrive%
		RegWrite, REG_BINARY, HKLM, systemR\MountedDevices, \DosDevices\%DesDrive%, %DesValue%
	}
}


GetVolList4DD()  ; 获取驱动器列表
{
	DriveGet, tmp_fksd, List, FIXED
	loop, parse, tmp_fksd
		VolumeDList .= A_loopField . ":|"
	stringtrimright, VolumeDList, VolumeDList, 1
	tmp_fksd := "" ; 释放内存
	return, VolumeDList
}

InstallGrub4Dos(TarDrive="C") ; 安装 Grub4Dos
{
	SrcDir := TestExePath("D:\bin\img," . A_scriptdir . "\FoxRamOS\Grub4Dos")
	FileCopy, %SrcDir%\grldr, %TarDrive%:\grldr, 1
	FileCopy, %SrcDir%\menu.lst, %TarDrive%:\menu.lst, 1

	FileSetAttrib, -R, %TarDrive%:\boot.ini
	IniWrite, 5, %TarDrive%:\boot.ini, boot loader, timeout
	IniWrite, "Grub4Dos", %TarDrive%:\boot.ini, operating systems, %TarDrive%:\grldr
	return, "Grub4Dos已布置到: " . TarDrive
}

CopyVolume(SrcDir="C:", DesDir="A:") ; 卷内容复制: 使用强制复制
{
;	RawReadPath := A_scriptdir . "\FoxRamOS\RawRead.exe"
	RawReadPath := A_scriptdir . "\FoxRamOS\RawRead.dll"
	hModule := DllCall("LoadLibrary", "str", RawReadPath)
	
	IfNotExist, %SrcDir%
	{
		msgbox, 不存在目录: %SrcDir%
		return
	}
	IfNotExist, %DesDir%
		FileCreateDir, %DesDir%
	JumpList=
	(Ltrim Join`,
	:\pagefile.sys
	:\System Volume Information
	\Temporary Internet Files\
	\Temp\
	)
	; -----进度条
	sTime := A_tickcount
	FileCount := 0 , NowCount := 0
	SB_settext("正在: 扫描文件数...")
	loop, %SrcDir%\*, 1, 1
		 ++FileCount
	SB_settext( "扫描结束! 耗时: " . (A_tickcount - sTime) . " 毫秒  文件数: " . FileCount)
	Guicontrol, Show, JinDu
	; -----进度条

	FileDelete, %A_scriptdir%\CopyError.lst
	loop, %SrcDir%\*, 1, 1
	{       ; 循环整个子目录
		; -----进度条
		++NowCount
		Guicontrol, , JinDu, % NowCount / FileCount * 100
		sb_setText(NowCount . " : " . A_LoopFileName, 2)
		; -----进度条

		stringreplace, TarFullPath, A_LoopFileFullPath, %SrcDir%, %DesDir%, A
		If A_LoopFileFullPath contains %JumpList%
			continue
		If instr(A_LoopFileAttrib, "D")
		{
			IfNotExist, %TarFullPath%
			{
				FileCreateDir, %TarFullPath%
				FileSetAttrib, +%A_LoopFileAttrib%, %TarFullPath%, 2, 0
			}
			continue
		}
		FileGetTime, TarTime, %TarFullPath%, M
		If ( A_LoopFileTimeModified = TarTime )
			continue
		Filecopy, %A_LoopFileFullPath%, %TarFullPath%, 1
		If Errorlevel
		{
			If instr(A_LoopFileName, ".log") ;or instr(A_LoopFileFullPath, "\Temp\")
				continue
			FileDelete, %TarFullPath%
;			runwait, %RawReadPath% "%A_LoopFileFullPath%" "%TarFullPath%", , Hide
;			FH := dllcall(RawReadPath . "\FileCopy", int, 55555, str, A_LoopFileFullPath, str, TarFullPath)
			FH := dllcall("RawRead\FileCopy", int, 55555, str, A_LoopFileFullPath, str, TarFullPath)
;			IfNotExist, %TarFullPath%
			If ( FH != 0 )
				FileAppend, %A_LoopFileFullPath%|%FH%`r`n, %A_scriptdir%\CopyError.lst
		}
	}
	DllCall("FreeLibrary", "UInt", hModule)
}


InstallFiraDisk() ; 安装FiraDisk驱动
{
	DevConP := TestExePath("D:\bin\bin32\devcon.exe," . A_scriptdir . "\FoxRamOS\devcon.exe,C:\bin\bin32\devcon.exe")
	IfExist, %A_windir%\system32\drivers\firadisk.sys
	{
		msgbox, 260, 确认, 已检测到FiraDisk.sys，是否强制安装？
		Ifmsgbox, no
			return, "貌似已经安装了FiraDisk"
	}
	SrcDir := A_scriptdir . "\FoxRamOS"
	RunWait, "%DevConP%" install "%SrcDir%\FiraDisk\firadisk.INF" root\firadisk, %SrcDir%, Hide
	return, "FiraDisk 安装完毕"
}

CreateBlankFile(FilePath="D:\RamOS.img", Size=55) ; 创建空文件
{
	If ( ( hFile:=DllCall("CreateFile", Str,FilePath, UInt,0x80000000|0x40000000, UInt,0x1|0x2, UInt,0, UInt,1, UInt,0, UInt,0) ) < 0 )
		Return -1
	If DllCall( "SetFilePointerEx", UInt,hFile, Int64,Size, Int64P,nPtr, UInt,0 ) = 0
		Return (DllCall( "CloseHandle", UInt,hFile )+null) "-2"
	If DllCall( "SetEndOfFile", UInt,hFile ) = 0
		Return (DllCall( "CloseHandle", UInt,hFile )+null) "-3"
	Return (DllCall( "CloseHandle", UInt,hFile )+null) "1"
}

; ---------------------------------------
InstallimDisk2() ; 安装imDisk
{
	SrcDir := A_scriptdir . "\FoxRamOS\imDisk"
	IfExist, %A_windir%\system32\drivers\imdisk.sys
	{
		msgbox, 260, 确认, 已检测到imdisk.sys，是否强制安装？
		Ifmsgbox, no
			return, "貌似已经安装了imDisk"
	}
	runwait, rundll32.exe setupapi.dll`,InstallHinfSection Defaultinstall 132 %SrcDir%\imdisk.inf ; 安装
	return, "安装完毕: imDisk"
}

InstallimDisk() ; 安装imDisk
{
	SrcDir := A_scriptdir . "\FoxRamOS\imDisk"
	IfExist, %A_windir%\system32\drivers\imdisk.sys
	{
		msgbox, 260, 确认, 已检测到imdisk.sys，是否强制安装？
		Ifmsgbox, no
			return, "貌似已经安装了imDisk"
	}

	Filecopy, %SrcDir%\awealloc\i386\awealloc.sys, %A_windir%\system32\drivers\awealloc.sys, 1
	Filecopy, %SrcDir%\cli\i386\imdisk.exe, %A_windir%\system32\imdisk.exe, 1
	Filecopy, %SrcDir%\cpl\i386\imdisk.cpl, %A_windir%\system32\imdisk.cpl, 1
	Filecopy, %SrcDir%\svc\i386\imdsksvc.exe, %A_windir%\system32\imdsksvc.exe, 1
	Filecopy, %SrcDir%\sys\i386\imdisk.sys, %A_windir%\system32\drivers\imdisk.sys, 1
	Filecopy, %SrcDir%\imdisk.inf, %A_windir%\inf\imdisk.inf, 1

	runwait, sc create imdisk binpath= system32\DRIVERS\imDisk.sys type= kernel error= ignore displayname= "ImDisk Virtual Disk Driver", , Hide
	runwait, sc create awealloc binpath= system32\DRIVERS\awealloc.sys type= kernel error= ignore displayname= "AWE Memory Allocation Driver", , Hide
	runwait, sc create imdsksvc binpath= system32\imdsksvc.exe type= own error= ignore displayname= "ImDisk Virtual Disk Driver Helper", , Hide

	; 卸载项
	UninsPath := "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ImDisk"
	regwrite, reg_sz, HKLM, %UninsPath%, DisplayIcon, %A_windir%\system32\imdisk.cpl
	regwrite, reg_sz, HKLM, %UninsPath%, DisplayName, ImDisk Virtual Disk Driver
	regwrite, reg_dword, HKLM, %UninsPath%, EstimatedSize, 3635
	regwrite, reg_sz, HKLM, %UninsPath%, Size
	regwrite, reg_sz, HKLM, %UninsPath%, UninstallString, rundll32.exe setupapi.dll`,InstallHinfSection DefaultUninstall 132 %A_windir%\INF\imdisk.inf

	; 右键菜单
;	regwrite, reg_sz, hkcr, *\shell\ImDiskMountFile, , Mount as ImDisk Virtual Disk
	regwrite, reg_sz, hkcr, *\shell\ImDiskMountFile, , 挂载为ImDisk虚拟盘(&M)
	regwrite, reg_sz, hkcr, *\shell\ImDiskMountFile\command, , rundll32.exe imdisk.cpl`,RunDLL_MountFile `%L

;	regwrite, reg_sz, hkcr, Drive\shell\ImDiskUnmount, , Unmount ImDisk Virtual Disk
	regwrite, reg_sz, hkcr, Drive\shell\ImDiskUnmount, , 卸载ImDisk虚拟盘(&U)
	regwrite, reg_sz, hkcr, Drive\shell\ImDiskUnmount\command, , rundll32.exe imdisk.cpl`,RunDLL_RemoveDevice `%L

;	regwrite, reg_sz, hkcr, Drive\shell\ImDiskSaveImage, , Save disk contents as image file
	regwrite, reg_sz, hkcr, Drive\shell\ImDiskSaveImage, , 保存磁盘内容到映像文件(&S)
	regwrite, reg_sz, hkcr, Drive\shell\ImDiskSaveImage\command, , rundll32.exe imdisk.cpl`,RunDLL_SaveImageFile `%L

	return, "安装完毕: imDisk"
}


mountImg(ImgPath="D:\RamOS.img", DL="A:") ; 挂载虚拟光驱
{
	runwait, imdisk -a -f "%ImgPath%" -m %DL%, , Hide
	return, "成功挂载镜像 " . ImgPath . " 到: " . DL
}

UnmountImg(DL="A:") ; 卸载虚拟光驱
{
	runwait, imdisk -d -m %DL%, , Hide
	return, "成功卸载分区: " . DL
}

/*
InstallFileDisk() ; 安装虚拟光驱驱动
{
	SrcDir := A_scriptdir . "\FoxRamOS\FileDisk"
	IfExist, %A_windir%\system32\drivers\filedisk.sys
	{
		msgbox, 260, 确认, 已检测到filedisk.sys，是否强制安装？
		Ifmsgbox, no
			return, "貌似已经安装了FileDisk"
	}
	Filecopy, %srcDir%\filedisk.sys, %A_windir%\system32\drivers\filedisk.sys, 1
	Filecopy, %srcDir%\filedisk.exe, %A_windir%\system32\filedisk.exe, 1
	runwait, sc create filedisk binpath= system32\DRIVERS\filedisk.sys type= kernel start= system, , Hide
	RegWrite, REG_DWORD, HKLM, SYSTEM\CurrentControlSet\Services\FileDisk\Parameters, NumberOfDevices, 4
	return, "安装完毕: FileDisk"
}

mountImg_filedisk(ImgPath="D:\RamOS.img", DL="A:") ; 挂载虚拟光驱
{
	Random, DN, 0, 3  ; 设备号，貌似最多四个设备
	
	SrcDir := A_scriptdir . "\FoxRamOS\FileDisk"
	runwait, sc start filedisk, , Hide
	SplitPath, ImgPath, , , ImgExt
	If ( ImgExt = "iso" )
		RunWait, %SrcDir%\filedisk.exe /mount %DN% %ImgPath% /cd %DL%, , Hide
	else
		RunWait, %SrcDir%\filedisk.exe /mount %DN% %ImgPath% %DL%, , Hide
	return, "成功挂载镜像到: " . DL . "  编号: " . DN
}

UnmountImg_filedisk(DL="A:") ; 卸载虚拟光驱
{
	SrcDir := A_scriptdir . "\FoxRamOS\FileDisk"
	RunWait, %SrcDir%\filedisk.exe /umount %DL%, , Hide
	runwait, sc stop filedisk, , Hide
	return, "成功卸载分区: " . DL
}
*/
; ---------------------------------------

SetVDM(MountPrevious=1, SrcImg="D:\RamOS.img", TarDrive="A:", ReadOnly=0) ; 设置VDM注册表项
{
	RegPath := "Software\Towodo Software\Virtual Drive Manager\Settings"
	MountStr=
	(Ltrim Join`n
	%TarDrive%
	auto detect
	disabled
	%SrcImg%
	%ReadOnly%
	)
	If ( MountPrevious = 1 ) {
		RegWrite, REG_DWORD, HKCU, %RegPath%, MountPrevious, 1
		RegWrite, REG_MULTI_SZ, HKCU, %RegPath%, LastMounts, %MountStr%
	} else {
		RegWrite, REG_DWORD, HKCU, %RegPath%, MountPrevious, 0
		RegWrite, REG_MULTI_SZ, HKCU, %RegPath%, LastMounts, 
	}
}

InstallRamDisk(TarDrive="C")  ; 安装 MS RamDisk 驱动, 复制破解 ntldr, 修改boot.ini
{
	DevConP := TestExePath("D:\bin\bin32\devcon.exe," . A_scriptdir . "\FoxRamOS\devcon.exe,C:\bin\bin32\devcon.exe")
	SrcPath := A_scriptdir . "\FoxRamOS\RamDisk"
	IfNotExist, %SrcPath%\ramdisk.sys
		return, "源ramdisk.sys不存在"
	runwait, %DevConP% install %SrcPath%\ramdisk.inf "Ramdisk", %SrcPath%\, Hide
	runwait, %DevConP% install %SrcPath%\ramdisk.inf "Ramdisk\RamVolume", %SrcPath%\, Hide
;	regwrite, REG_DWORD, HKLM, SYSTEM\CurrentControlSet\Services\Ramdisk, Start, 0
	
	FileMove, %TarDrive%:\ntldr, %TarDrive%:\ntldr.fox, 1
	FileCopy, %SrcPath%\ntldr, %TarDrive%:\ntldr, 1

	FileSetAttrib, -R, %TarDrive%:\boot.ini
	IniWrite, 5, %TarDrive%:\boot.ini, boot loader, timeout
	IniWrite, "MS RamXP" /pae /fastdetect /rdpath=multi(0)disk(0)rdisk(0)partition(2)\RamOS.img, %TarDrive%:\boot.ini, operating systems, ramdisk(0)\Windows
	return, "微软Ramdisk安装完毕, 可开始制作镜像"
}

RamDiskNoNewDevice()
{	; 解决 Ramdisk 制作的发现新硬件问题
	IfNotExist, %A_windir%\SYSTEM32\regini.exe
		return, "Regini.exe不存在"
	RegRead, tmpw3la, HKLM, SYSTEMR\ControlSet001\Services\RpcSs, Start
	If ErrorLevel
		return, "你还没有挂载映像的System配置单元"
	
	Set_Permissions("HKEY_LOCAL_MACHINE\SYSTEMR\ControlSet001\Enum [7 17]`r`n") ; 修改后权限

	TarRegPath := "SYSTEMR\ControlSet001\Enum\Ramdisk\RamVolume\{d9b257fc-684e-4dcb-ab79-03cfa2f6b750}"
	RegWrite, Reg_Dword, HKLM, %TarRegPath%, Capabilities, 0xF0
	RegWrite, Reg_SZ, HKLM, %TarRegPath%, Class, Ramdisk
	RegWrite, Reg_SZ, HKLM, %TarRegPath%, ClassGUID, {9D6D66A6-0B0C-4563-9077-A0E9A7955AE4}
	RegWrite, Reg_Dword, HKLM, %TarRegPath%, ConfigFlags, 0
	RegWrite, Reg_SZ, HKLM, %TarRegPath%, DeviceDesc, Windows RAM 磁盘设备(卷)
	RegWrite, Reg_SZ, HKLM, %TarRegPath%, Driver, {9D6D66A6-0B0C-4563-9077-A0E9A7955AE4}\0002
	RegWrite, Reg_MULTI_SZ, HKLM, %TarRegPath%, HardwareID, Ramdisk\RamVolume
	RegWrite, Reg_SZ, HKLM, %TarRegPath%, LocationInformation, Ramdisk\0
	RegWrite, Reg_SZ, HKLM, %TarRegPath%, Mfg, Microsoft
	RegWrite, Reg_SZ, HKLM, %TarRegPath%\Control
	RegWrite, Reg_SZ, HKLM, %TarRegPath%\LogConf

	Set_Permissions("HKEY_LOCAL_MACHINE\SYSTEMR\ControlSet001\Enum [8 17]`r`n") ; 恢复原始权限
	return, "Ramdisk发现新硬件的问题已解决"
}

; ------------
SaveAllHives(TarDriver="A:\")
{	; 根据注册表导出系统中所有的配置单元
	IfNotExist, %A_windir%\system32\reg.exe
		return, "Reg.exe不存在"
	IfNotExist, %A_windir%\system32\regini.exe
		return, "Regini.exe不存在"

	HiveList := GetHiveList() ; 列= 行`n
	loop, parse, hivelist, `n, `r
	{
		If ( A_loopfield = "" )
			continue
		stringsplit, ksd_, A_loopfield, =
		TempPath = %TarDriver%%ksd_2%
		SplitPath, TempPath, , OutDir
		IfNotExist, %OutDir%
			FileCreateDir, %OutDir%
		
SB_SetText("导出: " . ksd_1)
		If instr(ksd_1, "SECURITY")
		{
			Set_Permissions("HKEY_LOCAL_MACHINE\SECURITY [1 17]`r`n") ; 修改后权限
			runwait, Reg SAVE "%ksd_1%" "%TempPath%", , Hide
			Set_Permissions("HKEY_LOCAL_MACHINE\SECURITY [17]`r`n") ; 半原始权限
		} else
			runwait, Reg SAVE "%ksd_1%" "%TempPath%", , Hide
	}
}

GetHiveList() ; 列= 行`n
{
	; 获取 使用中的注册表文件 列表
	; HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\hivelist
	loop, HKLM, SYSTEM\CurrentControlSet\Control\hivelist
	{
		RegRead, NowValue
		Lists := A_LoopRegName . "=" . NowValue . "`n" . Lists
	}

	; 处理为 reg命令 需要的格式
	stringreplace, Lists, Lists, \REGISTRY\MACHINE\, HKLM\, A
	stringreplace, Lists, Lists, \REGISTRY\USER\, HKU\, A
	loop, parse, Lists, `n, `r
	{
		regexmatch(A_loopfield, "Ui)(^[^=]+)=\\Device\\[^\\]+\\(.*)$", aaa_)
		If ( aaa_2 = "" )
			continue
		EndList .= aaa_1 . "=" . aaa_2 . "`n"
	}
	return, EndList
}

Set_Permissions(permissions="HKEY_LOCAL_MACHINE\SECURITY [17]`r`n")
{	; 使用 regini 修改注册表权限
	fileappend, %permissions%, %A_windir%\foxquanxian.ini
	runwait, regini %A_windir%\foxquanxian.ini, , hide
	filedelete, %A_windir%\foxquanxian.ini
}

/*
Get_system_cmd()
{	; 获取一个具有 system 权限的 cmd , 研究用函数
	runwait, sc Create systemcmd binPath= "cmd /K start" type= own type= interact, , hide
	runwait, sc start systemcmd, , hide
	runwait,sc delete systemcmd, , hide
}
*/

; ------------

TestExePath(PathList="c:\a.exe,d:\b.exe")
{
	loop, parse, PathList, `,, %A_space%
		IfExist, %A_loopfield%
			return, A_loopfield
}

/*
外发版要做的事:
1. 复制 gru4dos 文件夹到 FoxRamOS下
2. 复制 VDM文件夹到 FoxRamOS下
3. 复制 devcon.exe到 FoxRamOS下
*/

