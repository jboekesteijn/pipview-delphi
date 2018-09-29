; MUI
; =================
!include "MUI.nsh"

!define MUI_ABORTWARNING
!define MUI_COMPONENTSPAGE_SMALLDESC

SetCompressor lzma
SetDateSave off

; PipView Installer
; =================
Name "PipView 0.9.9.4"
BrandingText "(c) 2001-2004 Joost-Wim Boekesteijn"
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\win-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\win-uninstall.ico"

!define MUI_FINISHPAGE_LINK "De website van PipView bezoeken voor meer informatie"
!define MUI_FINISHPAGE_LINK_LOCATION "http://pipview.xxp.nu/"

!define MUI_FINISHPAGE_RUN "$INSTDIR\pipview.exe"
!define MUI_FINISHPAGE_RUN_TEXT "PipView starten"

; Options
; =======
OutFile "binaries\pipview-0994.exe"
InstallDir "$PROGRAMFILES\PipView"
InstallDirRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PipView" "InstallDirectory"
ShowInstDetails nevershow
ShowUninstDetails nevershow

; Installer Types
; ===============
InstType "Standaard"
InstType "Volledig"

; Pages
; =====
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
Page custom EnterLogin LeaveLogin
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

; Languages
; =========
!insertmacro MUI_LANGUAGE "Dutch"

; Reserve Files
; =============
ReserveFile "pipview_installer.ini"
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS

; Installer Sections
; ==================
Section "!PipView" SecPipView
	SetOutPath $INSTDIR
	SectionIn 1 2 RO

	File "..\binaries\pipview.exe"
	File "..\binaries\pipview.chm"

	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PipView" "InstallDirectory" "$INSTDIR"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PipView" "DisplayName" "PipView"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PipView" "DisplayVersion" "0.9.9.4"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PipView" "HelpLink" "http://pipview.xxp.nu/"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PipView" "URLInfoAbout" "http://pipview.xxp.nu/"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PipView" "URLUpdateInfo" "http://pipview.xxp.nu/"
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PipView" "NoRepair" 1
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PipView" "NoModify" 1
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PipView" "UninstallString" '"$INSTDIR\uninstall.exe"'

	WriteUninstaller "uninstall.exe"
SectionEnd

Section "Snelkoppelingen voor PipView maken" SecSnelkoppeling
	SectionIn 1 2

	CreateDirectory "$SMPROGRAMS\PipView"
	CreateShortCut "$SMPROGRAMS\PipView\PipView.lnk" "$INSTDIR\pipview.exe"
	CreateShortCut "$SMPROGRAMS\PipView\Verwijder PipView.lnk" "$INSTDIR\uninstall.exe"
	CreateShortCut "$SMPROGRAMS\PipView\PipView Help.lnk" "$INSTDIR\pipview.chm"
	CreateShortCut "$DESKTOP\PipView.lnk" "$INSTDIR\pipview.exe"
	CreateShortCut "$QUICKLAUNCH\PipView.lnk" "$INSTDIR\pipview.exe"

	WriteINIStr "$SMPROGRAMS\PipView\PipView Website.url" "InternetShortcut" "URL" "http://pipview.xxp.nu/"
SectionEnd

Section "PipView automatisch opstarten" SecOpstarten
	SectionIn 1 2
	CreateShortCut "$SMSTARTUP\PipView.lnk" "$INSTDIR\pipview.exe" "--startup"
SectionEnd

Section "Knoppen in Internet Explorer maken" SecIE
	SectionIn 2
	WriteRegStr HKCU "Software\Microsoft\Internet Explorer\Extensions\{7B5014FC-EBE9-403E-830C-C8E27CC1E4AE}" "CLSID" "{1FBA04EE-3024-11D2-8F1F-0000F87ABD16}"
	WriteRegStr HKCU "Software\Microsoft\Internet Explorer\Extensions\{7B5014FC-EBE9-403E-830C-C8E27CC1E4AE}" "MenuText" "PipView nu starten"
	WriteRegStr HKCU "Software\Microsoft\Internet Explorer\Extensions\{7B5014FC-EBE9-403E-830C-C8E27CC1E4AE}" "ButtonText" "PipView nu starten"
	WriteRegStr HKCU "Software\Microsoft\Internet Explorer\Extensions\{7B5014FC-EBE9-403E-830C-C8E27CC1E4AE}" "Default Visible" "Yes"
	WriteRegStr HKCU "Software\Microsoft\Internet Explorer\Extensions\{7B5014FC-EBE9-403E-830C-C8E27CC1E4AE}" "MenuStatusBar" "PipView wordt gestart en getoond"
	WriteRegStr HKCU "Software\Microsoft\Internet Explorer\Extensions\{7B5014FC-EBE9-403E-830C-C8E27CC1E4AE}" "ToolTip" "PipView nu starten"
	WriteRegStr HKCU "Software\Microsoft\Internet Explorer\Extensions\{7B5014FC-EBE9-403E-830C-C8E27CC1E4AE}" "Exec" "$INSTDIR\piplaunch.lnk"
	WriteRegStr HKCU "Software\Microsoft\Internet Explorer\Extensions\{7B5014FC-EBE9-403E-830C-C8E27CC1E4AE}" "Icon" "$INSTDIR\pipview.exe,101"
	WriteRegStr HKCU "Software\Microsoft\Internet Explorer\Extensions\{7B5014FC-EBE9-403E-830C-C8E27CC1E4AE}" "HotIcon" "$INSTDIR\pipview.exe,101"

	WriteRegStr HKCU "Software\Microsoft\Internet Explorer\Extensions\{363410CB-D0DD-496b-BC10-992C6E0A091A}" "CLSID" "{1FBA04EE-3024-11D2-8F1F-0000F87ABD16}"
	WriteRegStr HKCU "Software\Microsoft\Internet Explorer\Extensions\{363410CB-D0DD-496b-BC10-992C6E0A091A}" "MenuText" "Ga naar uw Persoonlijke Informatie Pagina"
	WriteRegStr HKCU "Software\Microsoft\Internet Explorer\Extensions\{363410CB-D0DD-496b-BC10-992C6E0A091A}" "ButtonText" "Ga naar uw Persoonlijke Informatie Pagina"
	WriteRegStr HKCU "Software\Microsoft\Internet Explorer\Extensions\{363410CB-D0DD-496b-BC10-992C6E0A091A}" "Default Visible" "Yes"
	WriteRegStr HKCU "Software\Microsoft\Internet Explorer\Extensions\{363410CB-D0DD-496b-BC10-992C6E0A091A}" "MenuStatusBar" "Uw Persoonlijke Informatie Pagina wordt direct geopend"
	WriteRegStr HKCU "Software\Microsoft\Internet Explorer\Extensions\{363410CB-D0DD-496b-BC10-992C6E0A091A}" "ToolTip" "Uw Persoonlijke Informatie Pagina wordt direct geopend"
	WriteRegStr HKCU "Software\Microsoft\Internet Explorer\Extensions\{363410CB-D0DD-496b-BC10-992C6E0A091A}" "Script" "$INSTDIR\directpip.html"
	WriteRegStr HKCU "Software\Microsoft\Internet Explorer\Extensions\{363410CB-D0DD-496b-BC10-992C6E0A091A}" "Icon" "$INSTDIR\pipview.exe,102"
	WriteRegStr HKCU "Software\Microsoft\Internet Explorer\Extensions\{363410CB-D0DD-496b-BC10-992C6E0A091A}" "HotIcon" "$INSTDIR\pipview.exe,102"

	CreateShortCut "$INSTDIR\piplaunch.lnk" "$INSTDIR\pipview.exe" "--show"
SectionEnd

; Descriptions
; ============
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
	!insertmacro MUI_DESCRIPTION_TEXT ${SecPipView} "De programmabestanden van PipView installeren"
	!insertmacro MUI_DESCRIPTION_TEXT ${SecSnelkoppeling} "Snelkoppelingen op het bureaublad, in het menu start en in 'Snel starten' plaatsen"
	!insertmacro MUI_DESCRIPTION_TEXT ${SecOpstarten} "PipView automatisch laten opstarten bij het inschakelen van de computer"
	!insertmacro MUI_DESCRIPTION_TEXT ${SecIE} "Knoppen aan de Internet Explorer-werkbalk toevoegen"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; Installer Functions
; ===================
Function .onInit
	!insertmacro MUI_INSTALLOPTIONS_EXTRACT "pipview_installer.ini"

	FindWindow $R0 "TfrmPipMain"
	IntCmp $R0 0 equal nonequal nonequal
	nonequal:
		SendMessage $R0 16 0 0
		Return
	equal:
FunctionEnd

Function EnterLogin
	ReadRegStr $0 HKCU "Software\PipView\0" "naam"

	StrCmp $0 "" input noinput
	noinput:
		Abort
	input:
		!insertmacro MUI_HEADER_TEXT "Login-informatie" "Stel hier uw naam en wachtwoord in"
		!insertmacro MUI_INSTALLOPTIONS_DISPLAY "pipview_installer.ini"
FunctionEnd

Function LeaveLogin
	!insertmacro MUI_INSTALLOPTIONS_READ $0 "pipview_installer.ini" "Field 3" "State"
	!insertmacro MUI_INSTALLOPTIONS_READ $1 "pipview_installer.ini" "Field 4" "State"

	WriteRegStr HKCU "Software\PipView\0" "naam" $0
	WriteRegStr HKCU "Software\PipView\0" "wachtwoord_raw" $1
FunctionEnd

; Uninstaller Functions
; ===================
Function un.onInit
	FindWindow $R0 "TfrmPipMain"
	IntCmp $R0 0 equal nonequal nonequal
	nonequal:
		SendMessage $R0 16 0 0
		Return
	equal:
FunctionEnd

; Uninstaller Section
; ===================
Section "Uninstall"
	Delete "$SMSTARTUP\PipView.lnk"
	Delete "$QUICKLAUNCH\PipView.lnk"
	Delete "$DESKTOP\PipView.lnk"

	RMDir /r "$SMPROGRAMS\PipView"
	RMDir /r "$INSTDIR"

	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PipView"
	DeleteRegKey HKCU "Software\Microsoft\Internet Explorer\Extensions\{7B5014FC-EBE9-403E-830C-C8E27CC1E4AE}"
	DeleteRegKey HKCU "Software\Microsoft\Internet Explorer\Extensions\{363410CB-D0DD-496b-BC10-992C6E0A091A}"
	DeleteRegKey HKCU "Software\PipView"
SectionEnd
