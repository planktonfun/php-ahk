#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
#include gdip.1.45.ahk
#include imagelib.1.45.ahk
#include tcpudp.ahk
#include lib.ahk
#include commands.ahk
#SingleInstance, force

portIn  = %1%
portOut = %2%
myUdpIn := new udp()
myUdpIn.bind("localhost", portIn)

UdpSend2(message) {
	Global portOut

	UdpSendPort(message, portOut)
}

UdpSend2("Ready")

Loop {
	recv := myUdpIn.recv()

	StringSplit, param, recv, ``

	if(param1 = "exit") {
		ExitApp
	} if(param1 = "click") {
		Click, Left, %param2%, %param3%
	} else if(param1 = "getMousePosition") {
		CoordMode, Mouse, Screen
	    MouseGetPos, MouseX, MouseY
	    #include tcpudp.ahk
	 	#NoEnv
	 	UdpSend2(MouseX  . " " .  MouseY)
	} else if(param1 = "move") {
		MouseMove, param2, param3
	} else if(param1 = "clipboard") {
		Clipboard := param2
	} else if(param1 = "clickApp") {
		hwnd = %param2%
		x    = %param3%
		y    = %param4%
		ControlClick2(x, y, "ahk_id " hwnd)
	} else if(param1 = "closeApp") {
		pid = %param2%
		SafeProcessKill(pid)
	} else if(param1 = "showApp") {
		hwnd = %param2%
		WinSet, Transparent, OFF, ahk_id %hwnd%
	} else if(param1 = "speak") {
		content = %param2%
		Say(content)
	} else if(param1 = "send") {
		Send, %param2%
	} else if(param1 = "sendBackground") {
		controlid = %param2%
		message   = %param3%
		ControlSend,, %message%, ahk_id %controlid%
	} else if(param1 = "searchImageVariation") {
		pToken := Gdip_Startup()

		screen    = %param2%
		image     = %param3%
		variation = %param4%

		raster          := 0x40000000 + 0x00CC0020
		pBitmapHaystack := Gdip_BitmapFromScreen(screen,raster)
		pBitmapNeedle   := Gdip_CreateBitmapFromFile(image)

		Gdip_ImageSearch(pBitmapHaystack, pBitmapNeedle, guestX, guestY, variation)

		if(guestX > 0 and guestY > 0) {

			UdpSend2(guestX . " " . guestY)
		} else {
			UdpSend2(false)
		}

		Gdip_DisposeImage(pBitmapHayStack)
		Gdip_DisposeImage(pBitmapNeedle)

		Gdip_Shutdown(pToken)
	} else if(param1 = "searchImageFromImageVariation") {
		pToken := Gdip_Startup()

		haystack  = %param2%
		needle    = %param3%
		variation = %param4%

		pBitmapHaystack := Gdip_CreateBitmapFromFile(haystack)
		pBitmapNeedle   := Gdip_CreateBitmapFromFile(needle)

		Gdip_ImageSearch(pBitmapHaystack, pBitmapNeedle, guestX, guestY, variation)

		if(guestX > 0 and guestY > 0) {

			UdpSend2(guestX . " " . guestY)
		} else {
			UdpSend2(false)
		}

		Gdip_DisposeImage(pBitmapHayStack)
		Gdip_DisposeImage(pBitmapNeedle)

		Gdip_Shutdown(pToken)
	} else if(param1 = "searchImageFromImage") {
		pToken := Gdip_Startup()

		haystack = %param2%
		needle   = %param3%

		pBitmapHaystack := Gdip_CreateBitmapFromFile(haystack)
		pBitmapNeedle   := Gdip_CreateBitmapFromFile(needle)

		guest3456(pBitmapHaystack, pBitmapNeedle, guestX, guestY)

		if(guestX <> 0 and guestY <> 0) {

			UdpSend2(guestX . " " . guestY)
		} else {
			UdpSend2(false)
		}

		Gdip_DisposeImage(pBitmapHayStack)
		Gdip_DisposeImage(pBitmapNeedle)

		Gdip_Shutdown(pToken)
	} else if(param1 = "getApplicationId") {

	 	title  = %param2%
	 	WinGet, Active_Window, ID, %title%


	 	sleep, 500
	 	UdpSend2(Active_Window)

	 } else if(param1 = "getColor") {
	 	SetWorkingDir %A_ScriptDir%
	 	CoordMode, Pixel, Screen
	 	CoordMode, Mouse, Screen
	 	#include tcpudp.ahk
	 	#NoEnv

	 	X   = %param2%
	 	Y   = %param3%
	 	out = %param4%

	 	PixelGetColor, Color, X, Y

	 	UdpSend2(Color)

	 } else if(param1 = "getColorBulk") {

	 	pToken := Gdip_Startup()

	 	cornerX := 0
	 	cornerY := 0
	 	image    = %param2%
	 	out      = %param3%

	 	pBitmapNeedle := Gdip_CreateBitmapFromFile(image)

	 	str  := " "
	 	offx := 62
	 	offy := 25

	 	Loop, 4 {
	 	    Loop, 4 {
	 	        x := cornerX + offx
	 	        y := cornerY + offy

	 	        SetFormat, Integer, H
	 			Color := Gdip_GetPixel( pBitmapNeedle, x, y )
	 	        SetFormat, Integer, D
	 	        str  := str . " " . x . " " . y . " " . Color . "]"
	 	        offx := offx + 123
	 	    }

	 	    offy := offy + 122
	 	    offx := 62
	 	}


	 	UdpSend2(str)

	 	Gdip_DisposeImage(pBitmapNeedle)
	 	Gdip_Shutdown(pToken)

	 } else if(param1 = "getColorFromImage") {

	 	pToken := Gdip_Startup()

	 	x     = %param2%
	 	y     = %param3%
	 	image = %param4%
	 	out   = %4%

	 	pBitmapNeedle := Gdip_CreateBitmapFromFile(image)
	 	SetFormat, Integer, H
	 	color         := Gdip_GetPixel( pBitmapNeedle, x, y )

	 	if(x <> 0 and y <> 0) {

	 		UdpSend2(color)

	 	} else {
	 		UdpSend2(false)
	 	}

	 	Gdip_DisposeImage(pBitmapNeedle)
	 	Gdip_Shutdown(pToken)

	 } else if(param1 = "getImage") {

	 	pToken := Gdip_Startup()

	 	screen = %param2%
	 	image  = %param3%
	 	out    = %param4%
	 	raster          := 0x40000000 + 0x00CC0020
	 	pBitmap         := Gdip_BitmapFromScreen(screen,raster)

	 	Gdip_SaveBitmapToFile(pBitmap, image)


	 	UdpSend2(image)

	 	Gdip_DisposeImage(pBitmap)
	 	Gdip_Shutdown(pToken)

	 } else if(param1 = "getImageApp") {

	 	pToken := Gdip_Startup()

	 	hwnd = %param2%
	 	out  = %param3%

	 	pBitmap := Gdip_BitmapFromHWND(hwnd)

	 	Gdip_SaveBitmapToFile(pBitmap, out)


	 	sleep, 300
	 	UdpSend2(out)

	 	Gdip_DisposeImage(pBitmap)
	 	Gdip_Shutdown(pToken)

	 } else if(param1 = "getImageFromImage") {

	 	pToken := Gdip_Startup()

	 	screen = %param2%
	 	image  = %param3%
	 	out    = %param4%

	 	pBitmap := Gdip_CreateBitmapFromFile(image)
	 	pBitmap2 := Gdip_CropImage(pBitmap, screen)
	 	Gdip_SaveBitmapToFile(pBitmap2, out)
	 	UdpSend2(out)

	 	Gdip_DisposeImage(pBitmap)
	 	Gdip_Shutdown(pToken)


	 } else if(param1 = "getText") {
	 	WinGetActiveTitle, title

	 	sleep, 300


	 	UdpSend2(title)

	 } else if(param1 = "moveWindow") {

	 	x = %param2%
	 	y = %param3%

	 	WinMove,A,,%x%,%y%

	 } else if(param1 = "openApp") {

	 	Run, %param2% %param3%, ,Error ,OutputVarPID

	 	if(Error <> "") {
	 		UdpSend2(false)
	 	} else {

	 		UdpSend2(OutputVarPID)

	 	}

	 } else if(param1 = "resize") {

	 	ResizeWin(Width = 0,Height = 0)
	 	{
	 	  WinGetPos,X,Y,W,H,A
	 	  If %Width% = 0
	 	    Width := W

	 	  If %Height% = 0
	 	    Height := H

	 	  WinMove,A,,%X%,%Y%,%Width%,%Height%
	 	}

	 	w = %param2%
	 	h = %param3%

	 	ResizeWin(w, h)

	 } else if(param1 = "searchImage") {
	 	pToken := Gdip_Startup()

		screen = %param2%
		image  = %param3%
		out    = %param4%
		raster          := 0x40000000 + 0x00CC0020
		pBitmapHaystack := Gdip_BitmapFromScreen(screen,raster)
		pBitmapNeedle   := Gdip_CreateBitmapFromFile(image)

		guest3456(pBitmapHaystack, pBitmapNeedle, guestX, guestY)

		if(guestX <> 0 and guestY <> 0) {

			UdpSend2(guestX . " " . guestY)
		} else {
			UdpSend2(false)
		}

		Gdip_DisposeImage(pBitmapHayStack)
		Gdip_DisposeImage(pBitmapNeedle)

		Gdip_Shutdown(pToken)
	 } else if(param1 = "createComObject") {
	 	wb := ComObjCreate("InternetExplorer.Application")
		wb.Visible := param2
		UdpSend2("OK.")
	 } else if(param1 = "ComNavigate") {
		URL = %param2%
		wb.Navigate(URL)
		IELoad(wb)
		UdpSend2("OK.")
	 } else if(param1 = "ComSetAttr") {
        if(wb.document.querySelectorAll(param2).length = 0) {
        	UdpSend2(0)
        } else {
			wb.document.querySelectorAll(param2)[0].setAttribute(param3,param4)
			UdpSend2("OK.")
        }
	 } else if(param1 = "ComSetValue") {
		if(wb.document.querySelectorAll(param2).length = 0) {
			UdpSend2(0)
		} else {
			wb.document.querySelectorAll(param2)[0].value := param3
			UdpSend2("OK.")
		}
	 } else if(param1 = "ComSubmit") {
		if(wb.document.querySelectorAll(param2).length = 0) {
			UdpSend2(0)
		} else {
			wb.document.querySelectorAll(param2)[0].submit()
			IELoad(wb)
		}
		UdpSend2("OK.")
	 } else if(param1 = "ComClick") {
		if(wb.document.querySelectorAll(param2).length = 0) {
			UdpSend2(0)
		} else {
			wb.document.querySelectorAll(param2)[0].click()
			UdpSend2("OK.")
		}
	 } else if(param1 = "ComGetURL") {
	 	msg := wb.document.location.href
		UdpSend2(msg)
	 } else if(param1 = "msgBox") {
	 	MsgBox, %param2%
		UdpSend2("OK.")
	 } else if(param1 = "resizeImage") {

	 	pToken := Gdip_Startup()

	 	ratio  = %param2%
	 	image  = %param3%
	 	out    = %param4%

	 	pBitmap  := Gdip_CreateBitmapFromFile(image)
	 	pBitmap2 := Gdip_Resize(pBitmap, ratio)
	 	Gdip_SaveBitmapToFile(pBitmap2, out)
	 	UdpSend2(out)

	 	Gdip_DisposeImage(pBitmap)
	 	Gdip_DisposeImage(pBitmap2)
	 	Gdip_Shutdown(pToken)

	} else if(param1 = "SP_reload") {
		SP_reload()
	} else if(param1 = "SP_command_list") {
		SP_command_list()
	} else if(param1 = "SP_read_active_window") {
		SP_read_active_window()
	} else if(param1 = "SP_what_time_is_it") {
		SP_what_time_is_it()
	} else if(param1 = "SP_get_fb_notifications") {
		SP_get_fb_notifications()
	} else if(param1 = "SP_get_wiki_notifications") {
		SP_get_wiki_notifications()
	} else if(param1 = "SP_read_selections") {
		SP_read_selections()
	} else if(param1 = "SP_ok_stop_now") {
		SP_ok_stop_now()
	} else if(param1 = "SP_are_you_still_there") {
		SP_are_you_still_there()
	} else if(param1 = "SP_good_morning") {
		SP_good_morning()
	} else if(param1 = "SP_good_evening") {
		SP_good_evening()
	} else if(param1 = "SP_time_to_hibernate") {
		SP_time_to_hibernate()
	} else if(param1 = "SP_time_to_shutdown") {
		SP_time_to_shutdown()
	} else if(param1 = "SP_get_cpu_status") {
		SP_get_cpu_status()
	} else if(param1 = "SP_what_is_this") {
		SP_what_is_this()
	} else if(param1 = "SP_command_interface") {
		SP_command_interface()
	} else if(param1 = "SP_test_script") {
		SP_test_script()
	} else if(param1 = "SP_default_script") {
		SP_default_script()
	} else if(param1 = "SP_show_control_panel") {
		SP_show_control_panel()
	} else if(param1 = "SP_change_desktop") {
		SP_change_desktop()
	} else {
		MsgBox, No Command Found %recv%
	}

}

return