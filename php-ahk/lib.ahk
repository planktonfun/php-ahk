SafeProcessKill(p) {
    WinClose,ahk_pid %p%
    WinWaitClose,ahk_pid %p%,,1
    if (ErrorLevel) ; Force kill
    {
	    UdpSend(false)
        MsgBox, 36, , The process refuses to close.`nForce kill?
        ifMsgBox,No
            return 0
        Process,Close,%p%
        return ErrorLevel
    } else {
    	TrayTip, Honcho, %OutputVarPID%, 5000
		UdpSend("Closed Successfuly")
    }
    return 1
}

Say(x)
{
	TrayTip, 2Fuse, %x%, 5000
	RunWait Say.exe -f %x%, ,Hide , NewPID

}

ControlFromPoint(X, Y, WinTitle="", WinText="", ByRef cX="", ByRef cY="", ExcludeTitle="", ExcludeText="")
{
    if !(hwnd := WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText))
        return false

    VarSetCapacity(pt,8)

    ; Convert coords -- relative to top-left of window -> relative to client area.
    VarSetCapacity(wi,60), NumPut(60,wi)
    DllCall("GetWindowInfo","uint",hwnd,"uint",&wi)
    NumPut(X + (w:=NumGet(wi,4,"int")) - (cw:=NumGet(wi,20,"int")), pt,0)
    NumPut(Y + (h:=NumGet(wi,8,"int")) - (ch:=NumGet(wi,24,"int")), pt,4)

    Loop {
        child := DllCall("ChildWindowFromPointEx","uint",hwnd,"int64",NumGet(pt,0,"int64"),"uint",0x5)
        if !child or child=hwnd
            break
        ; Make pt relative to child client area.
        DllCall("MapWindowPoints","uint",hwnd,"uint",child,"uint",&pt,"uint",1)
        hwnd := child
    }
    cX := NumGet(pt,0,"int")
    cY := NumGet(pt,4,"int")
    return hwnd
}

ControlClick2(X, Y, WinTitle="", WinText="", ExcludeTitle="", ExcludeText="")
{
  hwnd:=ControlFromPoint(X, Y, WinTitle, WinText, cX, cY
                             , ExcludeTitle, ExcludeText)
  PostMessage, 0x200, 0, cX&0xFFFF | cY<<16,, ahk_id %hwnd% ; WM_MOUSEMOVE
  PostMessage, 0x201, 0, cX&0xFFFF | cY<<16,, ahk_id %hwnd% ; WM_LBUTTONDOWN
  PostMessage, 0x202, 0, cX&0xFFFF | cY<<16,, ahk_id %hwnd% ; WM_LBUTTONUP
}

IEGetw( ba )        ;Retrieve pointer to existing IE window/tab
{
    Name=""
    IfEqual, Name,, WinGetTitle, Name, ahk_class IEFrame
        Name := ( Name="New Tab - Windows Internet Explorer" ) ? "about:Tabs"
        : RegExReplace( Name, " - (Windows|Microsoft) Internet Explorer" )
    For ba in ComObjCreate( "Shell.Application" ).Windows
        If ( ba.LocationName = Name ) && InStr( ba.FullName, "iexplore.exe" )
            Return ba
} ;written by Jethrow



IELoad(wb)    ;You need to send the IE handle to the function unless you define it as global.
{
    If !wb    ;If wb is not a valid pointer then quit
        Return False
    Loop    ;Otherwise sleep for .1 seconds untill the page starts loading
        Sleep,100
    Until (wb.busy)
    Loop    ;Once it starts loading wait until completes
        Sleep,100
    Until (!wb.busy)
    Loop    ;optional check to wait for the page to completely load
        Sleep,100
    Until (wb.Document.Readystate = "Complete")
Return True
}

ai_Say(x)
{
        Global ; get variables outside this function

        TrayTip, pChaos, %x%, 2

        Process, Close, %currentPID%
        Run Say.exe -f %x%, ,Hide , NewPID
        currentPID := NewPID

        ; UdpSendPort(x, port2)
}

Ntf(x)
{
        TrayTip, pChaos, %x%, 2

}

RunPlugin( Filename )
{
        Run, %Filename%
}

GTime( )
{
        FormatTime, TimeString,,tt
        return %TimeString%
}

_Alt( letter )
{
        Send, {ALT UP}%letter%{ALT DOWN}
}

GFBNotif( FBPid )
{
    if( FBPid != "" )
    {
        process, Exist, %FBPid%

        if( !Errorlevel )
        {
            ; Ntf( "FBPid not running, process" )
            Run php fbnotif.php, ,Hide , NewPID
            return NewPID
        }
        else
        {
            ; Ntf( "FBPid still running, no process" )
            return FBPid
        }

    }
    else
    {
        ; Ntf( "FBPid do not exist, process" )
        Run php fbnotif.php, ,Hide , NewPID
        return NewPID
    }
}

GMailNotif( Mailid )
{
    if( Mailid != "" )
    {
        process, Exist, %Mailid%

        if( !Errorlevel )
        {
            ; Ntf( "Mailid not running, process" )
            Run php gmail.php, ,Hide , NewPID
            return NewPID
        }
        else
        {
            ; Ntf( "Mailid still running, no process" )
            return Mailid
        }

    }
    else
    {
        ; Ntf( "Mailid do not exist, process" )
        Run php gmail.php, ,Hide , NewPID
        return NewPID
    }
}

WikiNotif( Mailid )
{
    if( Mailid != "" )
    {
        process, Exist, %Mailid%

        if( !Errorlevel )
        {
            ; Ntf( "Mailid not running, process" )
            Run php wiki.sphp, ,Hide , NewPID
            return NewPID
        }
        else
        {
            ; Ntf( "Mailid still running, no process" )
            return Mailid
        }

    }
    else
    {
        ; Ntf( "Mailid do not exist, process" )
        Run php wiki.sphp, ,Hide , NewPID
        return NewPID
    }
}

WinGetAll(Which="Title", DetectHidden="Off"){
        O_DHW := A_DetectHiddenWindows, O_BL := A_BatchLines ;Save original states
        DetectHiddenWindows, % (DetectHidden != "off" && DetectHidden) ? "on" : "off"
        SetBatchLines, -1
            WinGet, all, list ;get all hwnd
            If (Which="Title") ;return Window Titles
            {
                Loop, %all%
                {
                    WinGetTitle, WTitle, % "ahk_id " all%A_Index%
                    If WTitle ;Prevent to get blank titles
                        Output .= WTitle "`n"
                }
            }
            Else If (Which="Process") ;return Process Names
            {
                Loop, %all%
                {
                    WinGet, PName, ProcessName, % "ahk_id " all%A_Index%
                    Output .= PName "`n"
                }
            }
            Else If (Which="Class") ;return Window Classes
            {
                Loop, %all%
                {
                    WinGetClass, WClass, % "ahk_id " all%A_Index%
                    Output .= WClass "`n"
                }
            }
            Else If (Which="hwnd") ;return Window Handles (Unique ID)
            {
                Loop, %all%
                    Output .= all%A_Index% "`n"
            }
            Else If (Which="PID") ;return Process Identifiers
            {
                Loop, %all%
                {
                    WinGet, PID, PID, % "ahk_id " all%A_Index%
                    Output .= PID "`n"
                }
                Sort, Output, U N ;numeric order and remove duplicates
            }
        DetectHiddenWindows, %O_DHW% ;back to original state
        SetBatchLines, %O_BL% ;back to original state
            Sort, Output, U ;remove duplicates
            Return Output
}

; ------------------------------------------------------------------------------
_CreateImageButton_(HWND, CB, CT = "", 3D = "", GC = "") {
   ; ---------------------------------------------------------------------------
   ; HWND   : HWND oder Variablenname des Buttons
   ;          Variablennamen müssen als "Strings" übergeben werden!
   ; CB     : Hintergrundfarbe:
   ;          6-steliger RGB Hexwert ("RRGGBB") oder HTML-Farbname ("Red")
   ;          2 Pipe (|) getrennte Werte bestimmen die Start- und Zielfarbe für
   ;          Farbverläufe. Wenn nur ein Wert übergeben wird, gilt er als
   ;          Zielfarbe und die Startfarbe wird auf Schwarz gesetzt.
   ;          3D = 9 : In CB muss ein HBITMAP-Handle oder der Dateipfad eines
   ;          Bildes übergeben werden.
   ; Optional ------------------------------------------------------------------
   ; CT     : Textfarbe:
   ;          6-steliger RGB Hexwert ("RRGGBB") oder HTML Farbname ("Red")
   ;          Voreinstellung: 000000 (Schwarz)
   ; 3D     : 3D-Effekte:
   ;          0 = keiner, 1 = erhaben, 2 = "3D" Verlauf, 3 = "flacher" Verlauf
   ;          9 = Hintergrundbild (CB enthält den Dateipfad oder ein HBITMAP-Handle)
   ;          Voreinstellung: 0
   ; GC     : Gammakorrektur:
   ;          0 = nein, 1 = ja
   ;          Voreinstellung: 0
   ; ---------------------------------------------------------------------------
   ; Die meisten DllCall's stammen aus tic's GDIP.AHK:
   ; --> http://www.autohotkey.com/forum/post-198949.html
   ; Ohne tic's Skript gäbe es dieses nicht!!!
   ; ---------------------------------------------------------------------------
   ; HTML-Farben
   Static HTML_BLACK := "000000"
        , HTML_SILVER := "C0C0C0"
        , HTML_GRAY := "808080"
        , HTML_WHITE := "FFFFFF"
        , HTML_MAROON := "800000"
        , HTML_RED := "FF0000"
        , HTML_PURPLE := "800080"
        , HTML_FUCHSIA := "FF00FF"
        , HTML_GREEN := "008000"
        , HTML_LIME := "00FF00"
        , HTML_OLIVE := "808000"
        , HTML_YELLOW := "FFFF00"
        , HTML_NAVY := "000080"
        , HTML_BLUE := "0000FF"
        , HTML_TEAL := "008080"
        , HTML_AQUA := "00FFFF"
   ; Windows Konstanten
        , BS_CHECKBOX := "0x2"
        , BS_RADIOBUTTON := "0x4"
        , BS_GROUPBOX := "0x7"
        , BS_AUTORADIOBUTTON := "0x9"
        , BS_BITMAP := "0x80"
        , BS_LEFT := "0x100"
        , BS_RIGHT := "0x200"
        , BS_CENTER := "0x300"
        , BS_TOP := "0x400"
        , BS_BOTTOM := "0x800"
        , BS_VCENTER := "0xC00"
        , SA_LEFT := "0x0"
        , SA_CENTER := "0x1"
        , SA_RIGHT := "0x2"
        , BCM_SETIMAGELIST := "0x1602"
        , BCM_GETTEXTMARGIN := "0x1605"
        , BUTTON_IMAGELIST_ALIGN_LEFT := 0
        , BUTTON_IMAGELIST_ALIGN_RIGHT := 1
        , BUTTON_IMAGELIST_ALIGN_CENTER := 4
        , BM_SETIMAGE := "0xF7"
        , IMAGE_BITMAP := "0x0"
        , BITSPIXEL := "0xC"
        , WM_GETFONT := "0x31"
   ; Weitere Konstanten
        , DEFAULT_CT := "000000"
        , DEFAULT_CB1 := "000000"
        , DEFAULT_3D := 0
        , DEFAULT_GC := 0
   RCBUTTONS := BS_CHECKBOX | BS_RADIOBUTTON | BS_AUTORADIOBUTTON
   ; ---------------------------------------------------------------------------
   ; HWND prüfen
   If !(HWND + 0) {
      GuiControlGet, nHWND, HWND, %HWND%
      HWND := nHWND
   }
   ; ---------------------------------------------------------------------------
   ; Klasse und Stile des Controls holen und prüfen
   WinGetClass, Class, ahk_id %HWND%
   If (Class != "Button") {
       MsgBox, 48, _CreateImageButtonP_
            , % "Diese Funktion arbeitet nur mit`n"
            . "Controls der Klasse ""Button""!"
       Return False
   }
   ControlGet, BS, Style, , , ahk_id %HWND%
   If (BS & 0xF ^ BS_GROUPBOX) = 0 {
       MsgBox, 48, _CreateImageButtonP_
            , % "Diese Funktion arbeitet nicht mit`n"
            . "Controls des Typs ""GroupBox""!"
       Return False
   }
   ; ---------------------------------------------------------------------------
   ; Ggf. Voreinstellungen für optionale Parameter setzen
   If (CT = "")
      CT := DEFAULT_CT
   If (3D = "")
      3D := DEFAULT_3D
   If (GC = "")
      GC := DEFAULT_GC
   If (3D < 4) {
      If InStr(CB, "|")
         StringSplit, CB, CB, |
      Else
         CB1 := DEFAULT_CB1, CB2 := CB
      If (HTML_%CB1% != "")
         CB1 := HTML_%CB1%
      If (HTML_%CB2% != "")
         CB2 := HTML_%CB2%
   }
   If (HTML_%CT% != "")
      CT := HTML_%CT%
   ; Verfügbarkeit von GDI+ prüfen
   If !DllCall("GetModuleHandle", "Str", "Gdiplus")
      hGDIP := DllCall("LoadLibrary", Str, "gdiplus")
   VarSetCapacity(SI, 16, 0)
 , Numput(1, SI, 0, "Char")
 , DllCall("gdiplus\GdiplusStartup", UIntP, pToken, UInt, &SI, UInt, 0)
   If (!pToken) {
       MsgBox, 48, _CreateImageButtonP_
            , % "GDIplus konnte nicht gestartet werden!`n"
            . "Prüfen Sie bitte die Verfügbarkeit von GDIPlus auf Ihrem System!"
       Return False
   }
   ; ---------------------------------------------------------------------------
   ; Farbtiefe und Font ermitteln
   hDC := DllCall("GetDC", UInt, HWND)
 , BPP := DllCall("GetDeviceCaps", UInt, hDC, Int, BITSPIXEL)
 , Font := DllCall("SendMessage", UInt, HWND, UInt, WM_GETFONT, UInt, 0, UInt, 0)
 , DllCall("SelectObject", UInt, hDC, UInt, Font)
 , DllCall("gdiplus\GdipCreateFontFromDC", UInt, hDC, UintP, hFont)
 , DllCall("ReleaseDC", UInt, HWND, UInt, hDC)
   ; ---------------------------------------------------------------------------
   ; Rechteck des Clientbereichs ermitteln
 , VarSetCapacity(RECT, 16, 0)
 , DllCall("GetClientRect", UInt, HWND, UInt, &RECT)
 , W := NumGet(RECT, 8), H := NumGet(RECT, 12)
   ; ---------------------------------------------------------------------------
   ; Rechteck für das Bild typabhängig anpassen
   SysGet, SMIW, 49
   If (BS & RCBUTTONS) > 1
      RCBUTTON := 1, W -= SMIW
   Else
      RCBUTTON := 0, W -= 8, H -= 8
   ; ---------------------------------------------------------------------------
   ; Beschriftung holen
   Length := DllCall("GetWindowTextLength", UInt, HWND)
 , VarSetCapacity(TX, Length + 1, 0)
 , DllCall("GetWindowText", UInt, HWND, Str, TX, Int, Length + 1)
 , VarSetCapacity(TX, -1)
   ; ---------------------------------------------------------------------------
   ; GDI+ Bitmap erzeugen
 , DllCall("gdiplus\GdipCreateBitmapFromScan0", Int, W, Int, H, Int, 0
      , Int, 0x26200A, UInt, 0, UIntP, pBitmap)
   ; ---------------------------------------------------------------------------
   ; Zeiger auf das zugehörige Grafikobjekt holen
 , DllCall("gdiplus\GdipGetImageGraphicsContext", UInt, pBitmap, UIntP, pGraphics)
   ; ---------------------------------------------------------------------------
   ; Glättung auf Systemeinstellung setzen
 , DllCall("gdiplus\GdipSetSmoothingMode", UInt, pGraphics, Int, 0)
   If (3D < 4) {
      ; ---------------------------------------------------------------------------
      ; Bitmap erstellen:
      ; POINT-Struktor für den Startpunkt
      VarSetCapacity(Point1, 8, 0)
    , NumPut(0, Point1, 0, "Float")
    , NumPut(0, Point1, 4, "Float")
      ; POINT-Struktor für den Endpunkt
    , VarSetCapacity(Point2, 8, 0)
    , NumPut(0, Point2, 0, "Float")
    , NumPut(H, Point2, 4, "Float")
      ; Startfarbe
    , Color1 := "0xFF" . CB1
      ; Zielfarbe
    , Color2 := "0xFF" . CB2
      ; Pinsel für einen "linearen Verlauf" erstellen
    , DllCall("gdiplus\GdipCreateLineBrush", UInt, &Point1, UInt, &Point2
         , Int, Color1, Int, Color2, Int, 0, UIntP, pBrush)
      ; Gammakorrektur setzen
    , DllCall("gdiplus\GdipSetLineGammaCorrection", UInt, pBrush, Int, GC)
      ; Relative Intensität setzen
    , VarSetCapacity(RELINT, 20, 0)
    , I1 := (3D = 0 ? 1.0 : 3D = 1 ? 0.25 : 3D = 2 ? 0.0 : 0.0)
    , I2 := (3D = 0 ? 1.0 : 3D = 1 ? 1.0 : 3D = 2 ? 0.5 : 0.25)
    , I3 := (3D = 0 ? 1.0 : 3D = 1 ? 1.0 : 3D = 2 ? 1.0 : 0.5)
    , I4 := (3D = 0 ? 1.0 : 3D = 1 ? 1.0 : 3D = 2 ? 0.5 : 0.75)
    , I5 := (3D = 0 ? 1.0 : 3D = 1 ? 0.25 : 3D = 2 ? 0.0 : 1.0)
    , NumPut(I1, RELINT, 0, "Float")
    , NumPut(I2, RELINT, 4, "Float")
    , NumPut(I3, RELINT, 8, "Float")
    , NumPut(I4, RELINT, 12, "Float")
    , NumPut(I5, RELINT, 16, "Float")
       ; Relative Positionen setzen
    , VarSetCapacity(RELPOS, 20, 0)
    , NumPut(0.0, RELPOS, 0, "Float")
    , NumPut(3D > 1 ? 0.25 : 0.15, RELPOS, 4, "Float")
    , NumPut(0.5, RELPOS, 8, "Float")
    , NumPut(3D > 1 ? 0.75 : 0.85, RELPOS, 12, "Float")
    , NumPut(1.0, RELPOS, 16, "Float")
      ; Überblendregeln setzen
    , DllCall("gdiplus\GdipSetLineBlend", UInt, pBrush, UInt, &RELINT
         , UInt, &RELPOS, Int, 5)
      ; Verlauf einfügen
    , DllCall("gdiplus\GdipFillRectangle", UInt, pGraphics, UInt, pBrush
         , Float, 0, Float, 0, Float, W, Float, H)
      ; Pinsel freigeben
    , DllCall("gdiplus\GdipDeleteBrush", UInt, pBrush)
   } Else If (3D = 9) {
      ; Bitmap aus Handle oder Datei erstellen
      If (CB + 0) {
         DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", UInt, CB, UInt, 0
            , UIntP, pBM)
      } Else {
         VarSetCapacity(wPATH, 1023)
       , DllCall("kernel32\MultiByteToWideChar", UInt, 0, UInt, 0
            , UInt, &CB, Int, -1, UInt, &wPATH, Int, 512)
       , DllCall("gdiplus\GdipCreateBitmapFromFile", UInt, &wPATH, UIntP, pBM)
      }
      ; Bitmap einfügen
      DllCall("gdiplus\GdipDrawImageRectI", UInt, pGraphics, UInt, pBM
        , Int, 0, Int, 0, Int, W, Int, H)
      ; Bitmap feigeben
    , DllCall("gdiplus\GdipDisposeImage", UInt, pBM)
   }
   ; ---------------------------------------------------------------------------
   ; Ggf. Beschriftung ausgeben
   If (TX) {
      ; ------------------------------------------------------------------------
      ; Formatobjekt erstellen
       DllCall("gdiplus\GdipCreateStringFormat", Int, 0x5404, Int, 0, UIntP, hFormat)
      ; ------------------------------------------------------------------------
       ; Textfarbe setzen
     , DllCall("gdiplus\GdipCreateSolidFill", Int, "0xFF" . CT, UIntP, pBrush)
      ; ------------------------------------------------------------------------
      ; Horizontale Ausrichtung setzen
    , HALIGN := (BS & BS_CENTER) = BS_CENTER ? SA_CENTER
              : (BS & BS_CENTER) = BS_RIGHT  ? SA_RIGHT
              : (BS & BS_CENTER) = BS_LEFT   ? SA_LEFT
              : (RCBUTTON) ? SA_LEFT : SA_CENTER
    , DllCall("gdiplus\GdipSetStringFormatAlign", UInt, hFormat, Int, HALIGN)
      ; Vertikale Ausrichtung setzen
    , VALIGN := (BS & BS_VCENTER) = BS_TOP ? 0
              : (BS & BS_VCENTER) = BS_BOTTOM ? 2
              : 1
    , DllCall("gdiplus\GdipSetStringFormatLineAlign", UInt, hFormat, Int, VALIGN)
      ; ------------------------------------------------------------------------
      ; Renderqualität auf Systemeinstellung setzen
    , DllCall("gdiplus\GdipSetTextRenderingHint", UInt, pGraphics, Int, 0)
      ; ------------------------------------------------------------------------
      ; Rechteck für den Text bestimmen
      If (RCBUTTON && HALIGN != SA_CENTER)
         XT := HALIGN = SA_RIGHT ? -8.0 : 0.0, WT := HALIGN = SA_RIGHT ? W + 8.0 : W
      Else
         XT := HALIGN = SA_CENTER ? -4.0 : 0.0, WT := HALIGN = SA_CENTER ? W + 8.0 : W
      NumPut(XT, RECT, 0, "Float")
    , NumPut(0.0, RECT, 4, "Float")
    , NumPut(WT, RECT, 8, "Float")
    , NumPut(H, RECT, 12, "Float")
      ; ------------------------------------------------------------------------
      ; Text in Unicode umwandeln
    , nSize := DllCall("MultiByteToWideChar", UInt, 0, UInt, 0, Str, TX, Int, -1
         , UInt, 0, Int, 0)
    , VarSetCapacity(wTX, (nSize * 2) + 1)
    , DllCall("MultiByteToWideChar", UInt, 0, UInt, 0, Str, TX, Int, -1, Str, wTX
         , Int, nSize)
      ; ------------------------------------------------------------------------
      ; Text ausgeben
    , DllCall("gdiplus\GdipDrawString", UInt, pGraphics, Str, wTX, Int, -1
         , UInt, hFont, UInt, &RECT, UInt, hFormat, UInt, pBrush)
   }
   ; ---------------------------------------------------------------------------
   ; HBITMAP Handle für die Bitmap erzeugen
   DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", UInt, pBitmap, UIntP, hBitmap
      , Int, 0XFFFFFFFF)
   ; ---------------------------------------------------------------------------
   ; Ressourcen freigeben
   DllCall("gdiplus\GdipDisposeImage", UInt, pBitmap)
 , DllCall("gdiplus\GdipDeleteBrush", UInt, pBrush)
 , DllCall("gdiplus\GdipDeleteStringFormat", UInt, hFormat)
 , DllCall("gdiplus\GdipDeleteFont", UInt, hFont)
 , DllCall("gdiplus\GdipDeleteGraphics", UInt, pGraphics)
   ; GDI+ beenden
 , DllCall("gdiplus\GdiplusShutdown", UInt, pToken)
   If (hGDIP)
      DllCall("FreeLibrary", UInt, hGDIP)
   ; ---------------------------------------------------------------------------
   ; ImageList erstellen
   hIL := DllCall("ImageList_Create", UInt, W, UInt, H, UInt, BPP, UInt, 8, UInt, 0)
   Loop, 1
      DllCall("ImageList_Add", UInt, hIL, UInt, hBitmap, UInt, 0)
   ; BUTTON_IMAGELIST Struktur erstellen
   VarSetCapacity(BIL, 24, 0)
 , NumPut(hIL, BIL)
 , Numput(BUTTON_IMAGELIST_ALIGN_CENTER, BIL, 20)
   ; ImageList zuweisen
 , DllCall("SendMessage", UInt, HWND, UInt, BCM_SETIMAGELIST, UInt, 0, UInt, 0)
 , DllCall("SendMessage", UInt, HWND, UInt, BCM_SETIMAGELIST, UInt, 0, UInt, &BIL)
   ; Beschriftung löschen
   ControlSetText, , , ahk_ID %HWND%
   ; Bitmap freigeben
   DllCall("DeleteObject", "UInt", hBitmap)
   ; Fertig!
   Return True
}

mgr_AllHKCommands( )
{
        Global

        commands =
        command_list =

        Loop, read, %A_ScriptName%
        {
                StringReplace, NewStr, A_LoopReadLine, %A_Tab%, , All
                FoundPos := RegExMatch( NewStr , "^SP_*:*")
                ;msgbox % FoundPos

                if( FoundPos > 0 )
                {
                        StringSplit, ColorArray, NewStr, `:

                        ;msgbox % ColorArray1

                        if ColorArray1 contains SP_
                        {
                                ;msgbox % ColorArray1

                                FoundPos1 := RegExMatch( ColorArray1 , "^SP_*")

                                if( FoundPos1 > 0 )
                                {
                                        StringReplace, angarray, ColorArray1, SP_, , All

                                        ;msgbox % angarray

                                        StringReplace, angarray2, angarray, _, %A_Space%, All

                                        ;msgbox % angarray2

                                        commands := commands . AIname . " " . angarray2 . ","
                                        command_list := command_list . AIname . " " . angarray2 . "`n"

                                        pstate.AddWordTransition(ComObjParameter(13, 0), AIname . " " . angarray2)

                                }

                        }

                }

        }

}

mgr_GoCommands( )
{
        Global

        Loop, parse, commands, `,
        {
                if( sText = Trim(A_LoopField) )
                {
                    echo := Trim(A_LoopField)

                        StringReplace, result, echo, %A_Space%, _, All
                        StringReplace, result, result, %AIname%_,, All

                        Gosub, SP_%result%

                }

        }

}

reloadThis() {
  reload
}