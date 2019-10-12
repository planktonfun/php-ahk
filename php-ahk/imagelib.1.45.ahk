guest3456(pBitmapHayStack, pBitmapNeedle, ByRef x, ByRef y)
{
   static _ImageSearch1, _ProcessShiftTable, Ptr, PtrA

   if (!_ImageSearch1)
   {
      Ptr := A_PtrSize ? "UPtr" : "UInt"
      , PtrA := A_PtrSize ? "UPtr*" : "UInt*"


      MCode_ImageSearch1 := "83ec085355568b74243c573b7424480f8ddd0000008b4c24442b4c242c8b44243c8b7c24288b6c24242bc88d148500"
      . "0000008bc18b4c2434c1e0028bd9895424140fafde894424443bd07f6d8b44242c8b74244c8d0c85ffffffff894c2410908b"
      . "c185c078328d341303f5eb038d49008a0c383a0c06751885c075118bca81e10300008079054983c9fc4174424879e08b7424"
      . "4c8b4c24108b44242c8d048303c20fb64428ff0314868b4424443bd07eaf8b7424408b4c24344603d9897424403b7424487d"
      . "2c8b542414e979ffffff8b4c241c8bc29983e20303c28b5424405fc1f80289018b4c241c5e5d89115b83c408c35f5e5d83c8"
      . "ff5b83c408c3"

      VarSetCapacity(_ImageSearch1, StrLen(MCode_ImageSearch1)//2)
      Loop % StrLen(MCode_ImageSearch1)//2      ;%
         NumPut("0x" SubStr(MCode_ImageSearch1, (2*A_Index)-1, 2), _ImageSearch1, A_Index-1, "uchar")
      MCode_ImageSearch1 := ""


      MCode_ProcessShiftTable := "8b542408538b5c241056578bc2b9000100008bfbf3ab8d72ff33c085f67e138b7c24108bd60fb60c384089148b4a3b"
      . "c67cf35f5e5bc3"

      VarSetCapacity(_ProcessShiftTable, StrLen(MCode_ProcessShiftTable)//2)
      Loop % StrLen(MCode_ProcessShiftTable)//2      ;%
         NumPut("0x" SubStr(MCode_ProcessShiftTable, (2*A_Index)-1, 2), _ProcessShiftTable, A_Index-1, "uchar")
      MCode_ProcessShiftTable := ""


     , DllCall("VirtualProtect", Ptr, &_ImageSearch1, Ptr, VarSetCapacity(_ImageSearch1), "uint", 0x40, PtrA, 0)
     , DllCall("VirtualProtect", Ptr, &_ProcessShiftTable, Ptr, VarSetCapacity(_ProcessShiftTable), "uint", 0x40, PtrA, 0)
   }

   Gdip_GetImageDimensions(pBitmapHayStack, hWidth, hHeight)
   , Gdip_GetImageDimensions(pBitmapNeedle, nWidth, nHeight)

   if !(hWidth && hHeight && nWidth && nHeight)
      return -3
   if (nWidth > hWidth || nHeight > hHeight)
      return -4

    sx1 := (sx1 = "") ? 0 : sx1
    , sy1 := (sy1 = "") ? 0 : sy1
    , sx2 := (sx2 = "") ? hWidth : (sx2 - nWidth + 1)
    , sy2 := (sy2 = "") ? hHeight : (sy2 - nHeight + 1)

   E1 := Gdip_LockBits(pBitmapHayStack, 0, 0, hWidth, hHeight, Stride1, Scan01, BitmapData1)
   E2 := Gdip_LockBits(pBitmapNeedle, 0, 0, nWidth, nHeight, Stride2, Scan02, BitmapData2)
   if (E1 || E2)
      return -5

   VarSetCapacity(shift_table, 256*4, 0)
   DllCall(&_ProcessShiftTable, Ptr, Scan02, "UInt", nWidth*4, Ptr, &shift_table, "cdecl")

   x := 0, y := 0
   E := DllCall(&_ImageSearch1, "int*", x, "int*", y, Ptr, Scan01, Ptr, Scan02, "int", nWidth, "int", nHeight
                  , "int", Stride1, "int", Stride2, "int", sx1, "int", sy1, "int", sx2, "int", sy2, Ptr, &shift_table, "cdecl int")

   Gdip_UnlockBits(pBitmapHayStack, BitmapData1)
   , Gdip_UnlockBits(pBitmapNeedle, BitmapData2)

   return (E = "") ? -6 : E
}

Gdip_ImageSearch(pBitmapHayStack, pBitmapNeedle, ByRef x, ByRef y, Variation=0, sx="", sy="", w="", h="")
{
   static _ImageSearch1, _ImageSearch2
   if (!_ImageSearch1)
   {
      MCode_ImageSearch1 := "83EC108B44242C9983E20303C28BC88B4424309983E20303C253C1F80255894424148B44244056C1F9023B44244C578944244"
      . "80F8DCA0000008B7C24348D148D000000000FAFC88B442444895424148B54242403C88D1C8A8B4C244C895C24183BC1894424407D7A895C24108D6424"
      . "008B6C2428C744243C000000008D6424008B44243C3B4424380F8D9400000033C985FF7E178BD58BF38B063B02752283C10183C20483C6043BCF7CED8"
      . "B44241C035C24148344243C0103C003C003E8EBC08B4424408B5C24108B4C244C83C00183C3043BC189442440895C24107C928B4424448B5424488B5C"
      . "2418035C241483C2013B54245089542448895C24180F8C5DFFFFFF8B5424548B4424585F5EC702FFFFFFFF5DC700FFFFFFFF83C8FF5B83C410C38B4C2"
      . "4548B5424408B4424585F89118B4C24445E5D890833C05B83C410C3"

      VarSetCapacity(_ImageSearch1, StrLen(MCode_ImageSearch1)//2)
      Loop % StrLen(MCode_ImageSearch1)//2      ;%
         NumPut("0x" SubStr(MCode_ImageSearch1, (2*A_Index)-1, 2), _ImageSearch1, A_Index-1, "char")
   }

   if (!_ImageSearch2)
   {
      MCode_ImageSearch2 :="83EC1C8B4424443B44244C535556578944241C0F8D760100008B4C24488B5424580FAFC88B4424608B742440894C24188B4C24"
      . "503BCA894C24140F8D320100008B54241833FF897C24108B5C24103B5C2444897C2428895424240F8D4E01000085F6C7442420000000000F8ECD00000"
      . "08B7424348D148A8B4C243003F7897424548D1C0AEB0A8DA424000000008D49008B6C2454B9030000000FB60C19BE030000000FB6342E8D2C013BF50F"
      . "8FA20000002BC83BF10F8C980000008B4C24300FB64C0A028B7424340FB67437028D2C013BF57F7F2BC83BF17C798B4C24300FB64C0A018B7424340FB"
      . "67437018D2C013BF57F602BC83BF17C5A0FB60B8B7424540FB6368D2C013BF57F492BC83BF17C438B4C24208B742440834424540483C10183C20483C3"
      . "0483C7043BCE894C24200F8C5BFFFFFF8B4C24148B7C24288B542424035424488344241001037C244CE9F7FEFFFF8B4C24148B5424588B74244083C10"
      . "13BCA894C24140F8CD2FEFFFF8B4C24508B7C241C8B5C2448015C241883C7013B7C245C897C241C0F8CA5FEFFFF8B5424648B4424685F5EC702FFFFFF"
      . "FF5DC700FFFFFFFF83C8FF5B83C41CC38B5424648B4424685F890A8B4C24185E5D890833C05B83C41CC3"

      VarSetCapacity(_ImageSearch2, StrLen(MCode_ImageSearch2)//2)
      Loop % StrLen(MCode_ImageSearch2)//2      ;%
         NumPut("0x" SubStr(MCode_ImageSearch2, (2*A_Index)-1, 2), _ImageSearch2, A_Index-1, "char")
   }

   if (Variation > 255 || Variation < 0)
      return -2

   Gdip_GetImageDimensions(pBitmapHayStack, hWidth, hHeight), Gdip_GetImageDimensions(pBitmapNeedle, nWidth, nHeight)

   if !(hWidth && hHeight && nWidth && nHeight)
      return -3
   if (nWidth > hWidth || nHeight > hHeight)
      return -4

   sx := (sx = "") ? 0 : sx
   sy := (sy = "") ? 0 : sy
   w := (w = "") ? hWidth-sx : w
   h := (h = "") ? hHeight-sy : h

   if (sx+w > hWidth-nWidth)
      w := hWidth-sx-nWidth+1

   if (sy+h > hHeight-nHeight)
      h := hHeight-sy-nHeight+1

   E1 := Gdip_LockBits(pBitmapHayStack, 0, 0, hWidth, hHeight, Stride1, Scan01, BitmapData1)
   E2 := Gdip_LockBits(pBitmapNeedle, 0, 0, nWidth, nHeight, Stride2, Scan02, BitmapData2)
   if (E1 || E2)
      return -5

   x := y := 0
   if (Variation = 0)
   {
      E := DllCall(&_ImageSearch1, "uint", Scan01, "uint", Scan02, "int", hWidth, "int", hHeight, "int", nWidth, "int", nHeight, "int", Stride1
      , "int", Stride2, "int", sx, "int", sy, "int", w, "int", h, "int*", x, "int*", y)
   }
   else
   {
      E := DllCall(&_ImageSearch2, "uint", Scan01, "uint", Scan02, "int", hWidth, "int", hHeight, "int", nWidth, "int", nHeight, "int", Stride1
      , "int", Stride2, "int", sx, "int", sy, "int", w, "int", h, "int", Variation, "int*", x, "int*", y)
   }
   Gdip_UnlockBits(pBitmapHayStack, BitmapData1), Gdip_UnlockBits(pBitmapNeedle, BitmapData2)
   return (E = "") ? -6 : E
}