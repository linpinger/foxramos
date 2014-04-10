/*
问题自动化(A,PageFile等)
*/
VerDate := "2012-9-21"
Drive_SysNow := "C:" ; 系统盘符
Drive_MountImg := "A:" ; 挂载Img的盘符
Drive_SysInRam := "B:" ; 系统盘符在RamOS中的盘符
ImgPath := "D:\RamOS.img"  ; Img路径

	DriveGet, NowDriveList, List ; 获取当前盘符列表，有B盘说明进入了RamOS
	if instr(NowDriveList, "B")
		Ca1 := 0 , Ca2 := 1
	else
		Ca1 := 1 , Ca2 := 0

FoxRamOSGUIInit:
Gui, Add, Tab2, x0 y0 w480 h330 vFoxTab AltSubmit , 0.介绍及选项|1.安装驱动|2.制作镜像|解决问题|工具箱

Gui, Tab, 1
Gui, Font, s12
Gui, Add, Text, x6 y30 w460 h140 +border cGreen, %A_space%`t`t欢迎使用 FoxRamOS 制作向导`n`n　本工具的目的是为了帮助您快速制作一个可用的RamOS`n　请确保以下几点:`n`t1. 已经装完系统(推荐220M左右的精简XP)`,并已备份`n`t2. 您的系统中的这些命令都可以使用:sc`,reg`,format`n`t3. 已经关闭了所有不必要的程序
Gui, Font
Gui, Add, Radio, x6 y180 w460 h20 cBlue vCKa1 Checked%Ca1%, &1. 制作一个RamOS
Gui, Add, Radio, x6 y230 w460 h20 cBlue vCKa2 Checked%Ca2%, &2. 已经进入RamOS系统中，但想解决发现新硬件问题
Gui, Add, Radio, x6 y280 w350 h20 cBlue vCKa3, &3. 使用工具箱完成一些操作
Gui, Add, Text, x36 y200 w430 h20 , 我是新手，我要制作一个RamOS，但它是个神马东西呢(点下一步吧)
Gui, Add, Text, x36 y250 w430 h20 , 已经成功进入RamOS中了，但是出现发现新硬件问题
Gui, Add, Text, x36 y300 w320 h20 , 我想手工完成一些操作，例如热备份等
Gui, Add, Button, x366 y280 w100 h40 gChooseStep vStep1, 下一步(&N)

Gui, Tab, 2
Gui, Font, s12
Gui, Add, Text, x6 y30 w460 h140 +border cGreen, `n　　本次操作可能会导致蓝屏(FiraDisk)`n`n　　请确保点击下一步之前已经备份好系统
Gui, Font
Gui, Add, CheckBox, x6 y180 w320 h20 cBlue vCKb1 +Checked, &1. 安装/卸载FiraDisk驱动
Gui, Add, Text, x36 y200 w320 h20 , 该驱动是制作RamOS的关键(类似可使用微软驱动)
Gui, Add, Button, x366 y180 w100 h40 gChooseStep vUninstallDrivers, 卸载驱动(慎用)

Gui, Add, CheckBox, x6 y230 w460 h20 cBlue vCKb2 +Checked, &2. 安装/卸载 ImDisk
Gui, Add, Text, x36 y250 w430 h20 , 该工具可用来挂载img镜像文件，功能很多，请自行搜索了解
Gui, Add, CheckBox, x6 y280 w350 h20 cBlue vCKb3 +Checked, &3. 布置grldr并修改boot.ini
Gui, Add, Text, x36 y300 w320 h20 , 添加grub4dos引导像，使Grub4Dos载入Img镜像文件
Gui, Add, Button, x366 y280 w100 h40 gChooseStep vStep2, 下一步(&N)

Gui, Tab, 3
Gui, Font, s12
Gui, Add, Text, x6 y30 w460 h140 border cGreen, `n　　重要: 需要你人工确定镜像文件的大小`n`n　　估算方法: C盘已用空间的3/4，镜像文件大小不得大于内存大小`n　　另外需确保系统盘为C，无A及B盘
Gui, Font
Gui, Add, Edit, x196 y180 w50 h20 cRed vImgSizeA, 600
Gui, Add, CheckBox, x6 y180 w190 h20 cBlue vCKc1 +Checked, &1. 创建镜像并挂载  大小(M):
Gui, Add, Text, x36 y200 w430 h20 , 创建镜像文件:D:\RamOS.img 并挂载到 A:，格式化为:NTFS，压缩
Gui, Add, CheckBox, x6 y230 w460 h20 cBlue vCKc2 +Checked, 2. 热备份
Gui, Add, Text, x36 y250 w320 h20 , 将C:\下所有文件复制到A:\  (可以手工在PE下复制)
Gui, Add, CheckBox, x6 y280 w350 h20 cBlue vCKc3 +Checked, 3. 将RamOS中的实际C盘盘符修改为B盘
Gui, Add, Text, x36 y300 w430 h20 , 目的: 进入RamOS后，原C盘变为B盘，现C盘为内存系统，A为挂载镜像预留盘符
Gui, Add, Button, x366 y260 w100 h30 gChooseStep vStep3, 最后一步(&N)
	Gui, Add, Progress, +Hidden cGreen x0 y320 w477 h10 vJinDu, 0


Gui, Tab, 4
Gui, Font, s12
Gui, Add, Text, x6 y30 w460 h140 border cGreen, 请确保:`n　　1. 确认已经进入RamOS`n　　2. 出现发现新硬件消息并在出现重启要求时选择否`n　　3. 已经关闭不必要的程序
Gui, Font
Gui, Add, CheckBox, x6 y180 w460 h20 cBlue vCKd1 +Checked , &1. reg命令备份system文件(避免下次重启后依然弹出发现新硬件)
Gui, Add, Text, x36 y200 w430 h20 , 备份当前系统system文件到A(system文件包含发现新硬件后的注册表更改)
Gui, Add, CheckBox, x6 y230 w460 h20 cBlue vCKd2 +Checked , &2. 删除多余的注册表项C:
Gui, Add, Text, x36 y250 w430 h20 , 删除SYSTEMR\MountedDevices下多余的\DosDevices\C:项
;Gui, Add, CheckBox, x6 y280 w460 h20 cBlue vCKd3 +Checked , &3.
;Gui, Add, Text, x36 y300 w430 h20 , Text
Gui, Add, Button, x366 y280 w100 h40 gChooseStep vStep4, 执行(&N)

Gui, Tab, 5
Gui, Font, s10
Gui, Add, Edit, x6 y30 w460 h100 cGreen +readonly, 木什么好说的，好吧我放一些信息:`n`n　　作者: 爱尔兰之狐  QQ:308639546`n　　地址: http://linpinger.github.io`n`n　　OlSoul的导航页: http://go.olsoul.com　　Q群:3754982
Gui, Font
/*
Gui, Add, GroupBox, x6 y140 w330 h80 cBlue, 挂载:
Gui, Add, ComboBox, x16 y160 w120 h20 choose1, D:\RamOS.img
Gui, Add, Edit, x16 y190 w50 h20 , 600
Gui, Add, Button, x66 y190 w70 h20 , 创建(&C)
Gui, Add, Button, x146 y160 w100 h20 , 挂载到(&M)>>
Gui, Add, Button, x146 y190 w100 h20 , 卸载(&U)
Gui, Add, ComboBox, x256 y160 w70 h20 choose1, A:
Gui, Add, Button, x256 y190 w70 h20 , 格式化

Gui, Add, GroupBox, x346 y140 w120 h80 cBlue, 热备份
Gui, Add, Button, x356 y160 w100 h20 , 内置热备份
Gui, Add, Button, x356 y190 w100 h20 , reg热备份

Gui, Add, GroupBox, x6 y240 w220 h80 cBlue, 加载及卸载镜像中的配置单元
Gui, Add, ComboBox, x16 y260 w90 h20 R10 choose1, system|software
Gui, Add, Button, x16 y290 w90 h20 , 打开注册表
Gui, Add, Button, x116 y260 w100 h20 , 加载配置单元
Gui, Add, Button, x116 y290 w100 h20 , 卸载配置单元

Gui, Add, GroupBox, x236 y240 w230 h80 cBlue, 使用reg命令导出注册表文件
Gui, Add, ComboBox, x246 y260 w210 h20 R10 choose1, 所有注册表|system|software
Gui, Add, Button, x246 y290 w210 h20 , 导出到C:\
*/

; Generated using SmartGUI Creator 4.0
Gui, Add, StatusBar, , 爱尔兰之狐 的RamOS制作向导，欢迎使用，理论上只要一直点下一步
Gui, Show, w477 h347, FoxRamOS 制作向导 版本: %VerDate%
Return

ChooseStep:
	Gui, Submit, nohide
	if ( A_GuiControl = "Step1" ) {
		if ( CKa1 = 1 ) {
			WarnString := envcheck()
			if ( WarnString != "" ) {
				msgbox, 8484, 系统环境检测, 检测到以下可能影响制作的因素:`n`n%WarnString%`n是否继续制作？
				ifmsgbox, no
					return
			}

			Guicontrol, Choose, FoxTab, 2
			SB_SetText("1 / 2: 点击下一步开始准备安装FiraDisk, ImDisk, Grub4Dos")
		}
		if ( CKa2 = 1 ) {
			Guicontrol, Choose, FoxTab, 4
		}
		if ( CKa3 = 1 ) {
			Guicontrol, Choose, FoxTab, 5
		}
	}
	if ( A_GuiControl = "Step2" ) {
		if ( CKb1 = 1 ) {
			SB_SetText("开始安装: FiraDisk驱动...")
			SB_SetText(InstallFiraDisk("install"))
		}
		if ( CKb2 = 1 ) {
			SB_SetText("开始安装: Imdisk...")
			SB_SetText(InstallimDisk())
		}
		if ( CKb3 = 1 ) {
			SB_SetText("开始布置: Grub4Dos...")
			SB_SetText(InstallGrub4Dos(Drive_SysNow))
		}
		Guicontrol, Choose, FoxTab, 3
		SB_SetText("2 / 2: 点击下一步开始制作镜像")
	}
	if ( A_GuiControl = "Step3" ) {
		if ( CKc1 = 1 ) {
			SB_SetText("正在生成大小为 " . ImgSizeA . "M 的镜像文件: " . ImgPath)
			CreateBlankFile(ImgPath, ImgSizeA * 1024 * 1024)
			SB_SetText("正在挂载镜像文件: " . ImgPath . " 到: " . Drive_MountImg)
			mountImg(ImgPath, Drive_MountImg) ; 挂载虚拟光驱
			SB_SetText("正在格式化 " . Drive_MountImg . " 大小: " . ImgSizeA . " 类型:NTFS 属性:压缩")
			runwait, cmd /c format %Drive_MountImg% /FS:NTFS /V:FoxRamOS /Q /C /Y, , Hide
		}
		if ( CKc2 = 1 ) {
			SB_SetText("热备份中...")
			CopyVolume(Drive_SysNow, Drive_MountImg) ; 卷内容复制: 使用强制复制
			IniDelete, %Drive_MountImg%\boot.ini, operating systems, %Drive_SysNow%\grldr
;			SB_SetText("热备份完毕")
		}
		if ( CKc3 = 1 ) {
			SB_SetText("修改盘符中...")
			IfNotExist, %Drive_MountImg%\WINDOWS\system32\config\system
			{
				sb_setText("镜像system配置单元不存在，请先挂载")
				return
			}
			sb_setText("挂载中: HKLM\systemR")
			runwait, REG LOAD HKLM\systemR %Drive_MountImg%\WINDOWS\system32\config\system, , Hide
			sb_setText("挂载完毕: HKLM\systemR")

		; 实机卷信息->修改->映像注册表
		RegRead, TrueValue, HKLM, SYSTEM\MountedDevices, \DosDevices\%Drive_SysNow%
		RegDelete, HKLM, systemR\MountedDevices, \DosDevices\%Drive_SysNow%
		RegWrite, REG_BINARY, HKLM, systemR\MountedDevices, \DosDevices\%Drive_SysInRam%, %TrueValue%

		RegWrite, REG_SZ, HKCU,Software\Microsoft\Windows\CurrentVersion\Applets\Regedit, LastKey, 我的电脑\HKEY_LOCAL_MACHINE\SYSTEMR\MountedDevices
;		run, regedit

			sb_setText("卸载中: HKLM\systemR")
			runwait, REG UnLOAD HKLM\systemR, , Hide
			sb_setText("卸载完毕: HKLM\systemR")
		}
		SB_SetText("RamOS制作成功, 现在你可以重启电脑, 选择条目RamOS，然后就可以进入了")
		msgbox,8516, 重启确认, RamOS制作成功`n现在你可以重启电脑`,选择条目RamOS，然后就可以进入了`n`n真的要重启吗？
		; 324
		ifmsgbox, yes
			shutdown, 2

	}
	if ( A_GuiControl = "Step4" ) {
		if ( CKd1 = 1 ) {
			SB_SetText("正在挂载镜像文件: " . ImgPath . " 到: " . Drive_MountImg)
			mountImg(ImgPath, Drive_MountImg) ; 挂载虚拟光驱
			FileDelete, %Drive_MountImg%\WINDOWS\SYSTEM32\config\system
			runwait, Reg SAVE HKLM\SYSTEM %Drive_MountImg%\WINDOWS\SYSTEM32\config\system, , Hide
			SB_SetText("完毕: reg备份system")
		}
		if ( CKd2 = 1 ) {
			sb_setText("挂载中: HKLM\systemR")
			runwait, REG LOAD HKLM\systemR %Drive_MountImg%\WINDOWS\system32\config\system, , Hide
			sb_setText("挂载完毕: HKLM\systemR")

			RegDelete, HKLM, systemR\MountedDevices, \DosDevices\%Drive_SysNow%

			sb_setText("卸载中: HKLM\systemR")
			runwait, REG UnLOAD HKLM\systemR, , Hide
			sb_setText("卸载完毕: HKLM\systemR")
			SB_SetText("完毕: 删除注册表项" . Drive_SysNow)
		}
	}
	if ( A_GuiControl = "UninstallDrivers" ) {
		WarnStringUn := ""
		DriveGet, NowDriveListUn, List ; 获取当前盘符列表，有B盘说明进入了RamOS
		if instr(NowDriveListUn, "B")
			WarnStringUn .= "警告: 当前系统存在B盘，您可能处于RamOS系统中，请进入正常系统`n"
		if instr(NowDriveListUn, "A")
			WarnStringUn .= "警告: 当前系统存在A盘，您可能已挂载镜像文件至A盘，请在A盘上右键卸载Imdisk虚拟盘`n"

		if ( CKb2 = 1 )
			IfNotExist, %A_windir%\INF\imdisk.inf
				WarnStringUn .= "警告: 未检测到 ImDisk 的 inf 文件，可能没有安装ImDisk`n"

		if ( WarnStringUn != "" ) {
			msgbox, 8484, 系统环境检测, 检测到以下可能影响卸载的因素:`n`n%WarnStringUn%`n是否继续卸载？
			ifmsgbox, no
				return
		}
		if ( CKb1 = 1 )
			SB_SetText(InstallFiraDisk("Uninstall"))
		if ( CKb2 = 1 )
			SB_SetText(InstallimDisk("Uninstall"))
		if ( CKb3 = 1 )
			SB_SetText(InstallGrub4Dos(Drive_SysNow,"Uninstall"))
		SB_SetText("提示: 卸载任务完毕")
	}
return

GuiClose:
	ExitApp
return

; -----备注:
^esc::reload
+esc::Edit
!esc::ExitApp

EnvCheck() {  ; 检查系统环境
	; 系统类型,驱动器列表,依赖命令列表,建议img大小，驱动安装状况检测
	WarnString := ""
	; -----
	if ( A_OSVersion != "WIN_XP" )
		WarnString .= "警告: 当前系统 不是XP,不能保证能否成功`n"
	; -----
	DriveGet, NowDriveList, List
	if instr(NowDriveList, "A")
		WarnString .= "错误: 当前系统 包含盘符A，请禁用软驱或卸载A`n"
	StringLeft, SysDLa, A_windir,1
	IfExist, %SysDLa%:\pagefile.sys
		WarnString .= "警告: 当前系统 包含 pagefile.sys，请禁用虚拟内存`n"
	; ----- cmd format reg sc
	IfNotExist, %A_windir%\system32\cmd.exe
		WarnString .= "错误: 当前系统 不存在 cmd.exe`n"
	IfNotExist, %A_windir%\system32\format.com
		WarnString .= "错误: 当前系统 不存在 format.com`n"
	IfNotExist, %A_windir%\system32\reg.exe
		WarnString .= "错误: 当前系统 不存在 reg.exe`n"
	IfNotExist, %A_windir%\system32\sc.exe
		WarnString .= "错误: 当前系统 不存在 sc.exe`n"
	; ----- 建议img大小
	SysMemSize := GetSysMemSize()  ; 物理内存数 M
	StringLeft, SysDL, A_windir,3
	DriveGet, Size_All, Capacity, %SysDL%
	DriveSpaceFree, Size_Free, %SysDL%
	PageFileSize := 0
	IfExist, %SysDL%pagefile.sys
		FileGetSize, PageFileSize, %SysDLa%pagefile.sys, M
	Size_Used := round( ( Size_All - Size_Free - PageFileSize ) * 3 / 4) ; 预估镜像大小=3/4 * 已用大小
	If ( ( SysMemSize - Size_Used ) < 200 ) { ; 载入镜像后系统可用内存大于200M用于系统启动
		WarnString .= "警告: " . SysDL . "盘过大，内存小于预估Img大小.  内存:" . SysMemSize . "  预估Img:" . Size_Used . "，请减小系统盘体积`n"
;		SB_SetText(SysDL . "盘过大  预估压缩镜像: " . Size_Used " M  物理内存: " . SysMemSize . " M" )
		Guicontrol, Text, ImgSizeA, 0
	} else {
;		SB_SetText("预估压缩镜像: " . Size_Used " M  物理内存: " . SysMemSize . " M" )
		Guicontrol, Text, ImgSizeA, %Size_Used%
	}
	; ----- 驱动检测
	return, WarnString
}

TestExePath(PathList="c:\a.exe,d:\b.exe")
{
	loop, parse, PathList, `,, %A_space%
		IfExist, %A_loopfield%
			return, A_loopfield
}

InstallFiraDisk(Action="install") ; 安装FiraDisk驱动
{
	SrcDir := A_scriptdir . "\FoxRamOS"
	DevConP := TestExePath("D:\bin\bin32\devcon.exe," . SrcDir . "\devcon.exe,C:\bin\bin32\devcon.exe")

	If ( Action = "Uninstall" ) {
		RunWait, "%DevConP%" remove root\firadisk, %SrcDir%, Hide
		return, "FiraDisk 卸载完毕"
	}
	If ( Action = "install" ) {
		IfExist, %A_windir%\system32\drivers\firadisk.sys
		{
			msgbox, 8484, 确认, 已检测到FiraDisk.sys，是否强制安装？
			Ifmsgbox, no
				return, "貌似已经安装了FiraDisk"
		}
		RunWait, "%DevConP%" install "%SrcDir%\FiraDisk\firadisk.INF" root\firadisk, %SrcDir%, Hide
;		runwait rundll32.exe setupapi`,InstallHinfSection DefaultInstall 132 %A_ScriptDir%\firadisk.inf
		return, "FiraDisk 安装完毕"
	}
}

InstallimDisk(Action="install") ; 安装imDisk
{
	If ( Action = "Uninstall" ) {
		IfExist, %A_windir%\INF\imdisk.inf
		{
			runwait, rundll32.exe setupapi.dll`,InstallHinfSection DefaultUninstall 132 %A_windir%\INF\imdisk.inf
			return, "卸载完毕: imDisk"
		} else
			return, "错误: 未检测到 imDisk 的 inf 文件"
	}

	SrcDir := A_scriptdir . "\FoxRamOS\imDisk"
	IfExist, %A_windir%\system32\drivers\imdisk.sys
	{
		msgbox, 8484, 确认, 已检测到imdisk.sys，是否强制安装？
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

InstallGrub4Dos(TarDrive="C:", Action="install") ; 安装 Grub4Dos
{
	If ( Action = "Uninstall" ) {
		FileSetAttrib, -R, %TarDrive%\boot.ini
		IniDelete, %TarDrive%\boot.ini, operating systems, %TarDrive%\grldr
		FileDelete, %TarDrive%\grldr
		FileDelete, %TarDrive%\menu.lst
		return, "卸载完毕: Grub4Dos"
	}

	SrcDir := TestExePath("D:\bin\img," . A_scriptdir . "\FoxRamOS\Grub4Dos")
	FileCopy, %SrcDir%\grldr, %TarDrive%\grldr, 1
	FileCopy, %SrcDir%\menu.lst, %TarDrive%\menu.lst, 1

	FileSetAttrib, -R, %TarDrive%\boot.ini
	IniWrite, 5, %TarDrive%\boot.ini, boot loader, timeout
	IniWrite, "FoxRamOS", %TarDrive%\boot.ini, operating systems, %TarDrive%\grldr
	return, "Grub4Dos已布置到: " . TarDrive
}


CreateBlankFile(FilePath="D:\RamOS.img", Size=629145600) ; 创建空文件
{
	IfExist, %FilePath%
		FileMove, %FilePath%, %FilePath%.old, 1
	If ( ( hFile:=DllCall("CreateFile", Str,FilePath, UInt,0x80000000|0x40000000, UInt,0x1|0x2, UInt,0, UInt,1, UInt,0, UInt,0) ) < 0 )
		Return -1
	If DllCall( "SetFilePointerEx", UInt,hFile, Int64,Size, Int64P,nPtr, UInt,0 ) = 0
		Return (DllCall( "CloseHandle", UInt,hFile )+null) "-2"
	If DllCall( "SetEndOfFile", UInt,hFile ) = 0
		Return (DllCall( "CloseHandle", UInt,hFile )+null) "-3"
	Return (DllCall( "CloseHandle", UInt,hFile )+null) "1"
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
	:\grldr
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
		sb_setText("备份: " . NowCount . " / " . FileCount . " : " . A_LoopFileFullPath)
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
	SB_settext("热备份结束!  文件数: " . FileCount)
}

GetSysMemSize()  ; 获取物理内存总数(M)
{
	VarSetCapacity(MEMORYSTATUSEX,64,0) , NumPut(64,MEMORYSTATUSEX) 
	DllCall("GlobalMemoryStatusEx", UInt,&MEMORYSTATUSEX) 
	PhysMemSizeB := NumGet(MEMORYSTATUSEX,8,"Int64")
	return, Round(PhysMemSizeB/1024/1024)
}

