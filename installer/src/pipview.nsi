; Includes
; ========
!include "LogicLib.nsh"
!include "MUI.nsh"

; Variables
; =========
Var Naam
Var Wachtwoord

Var ShortcutStartup
Var ShortcutStartmenu
Var ShortcutDesktop
Var ShortcutQuicklaunch

; Options
; =======
Name "PipView 1.0.4"
BrandingText "© 2001-2006 Joost-Wim Boekesteijn"
OutFile "..\bin\pipview-1.0.4-setup.exe"
InstallDir "$PROGRAMFILES\PipView"
SetCompressor /SOLID lzma

!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\win-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\win-uninstall.ico"

; Installer pages
; ===============
!insertmacro MUI_PAGE_DIRECTORY
Page custom EnterLogin LeaveLogin
Page custom EnterOptions LeaveOptions
!insertmacro MUI_PAGE_INSTFILES

!define MUI_FINISHPAGE_LINK "De website van PipView bezoeken voor meer informatie"
!define MUI_FINISHPAGE_LINK_LOCATION "http://pipview.xxp.nu/"

!define MUI_FINISHPAGE_RUN "$INSTDIR\pipview.exe"
!define MUI_FINISHPAGE_RUN_TEXT "PipView starten"

!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
; =================
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

; Languages
; =========
!insertmacro MUI_LANGUAGE "Dutch"

; Installer Sections
; ==================
Section
	SetOutPath $INSTDIR

	File "..\..\program\bin\pipview.exe"

	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PipView" "DisplayName" "PipView"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PipView" "HelpLink" "http://pipview.xxp.nu/uitleg"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PipView" "URLInfoAbout" "http://pipview.xxp.nu/"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PipView" "URLUpdateInfo" "http://pipview.xxp.nu/"
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PipView" "NoRepair" 1
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PipView" "NoModify" 1
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PipView" "UninstallString" '"$INSTDIR\uninstall.exe"'

	WriteRegStr HKLM "Software\PipView" "naam" $Naam
	WriteRegStr HKLM "Software\PipView" "wachtwoord" $Wachtwoord

	WriteRegStr HKCU "Software\PipView" "naam" $Naam
	WriteRegStr HKCU "Software\PipView" "wachtwoord" $Wachtwoord

	${If} $ShortcutStartup == "yes"
		CreateShortCut "$SMSTARTUP\PipView.lnk" "$INSTDIR\pipview.exe"
	${EndIf}

	${If} $ShortcutStartmenu == "yes"
		CreateDirectory "$SMPROGRAMS\PipView"
		CreateShortCut "$SMPROGRAMS\PipView\PipView.lnk" "$INSTDIR\pipview.exe"
		CreateShortCut "$SMPROGRAMS\PipView\Verwijder PipView.lnk" "$INSTDIR\uninstall.exe"
		WriteINIStr "$SMPROGRAMS\PipView\PipView Website.url" "InternetShortcut" "URL" "http://pipview.xxp.nu/"
	${EndIf}

	${If} $ShortcutDesktop == "yes"
		CreateShortCut "$DESKTOP\PipView.lnk" "$INSTDIR\pipview.exe"
	${EndIf}

	${If} $ShortcutQuicklaunch == "yes"
		CreateShortCut "$QUICKLAUNCH\PipView.lnk" "$INSTDIR\pipview.exe"
	${EndIf}

	WriteUninstaller "uninstall.exe"
SectionEnd

; Installer Functions
; ===================

Function hasInstallRights
	ClearErrors
	UserInfo::GetName

	${If} ${Errors}
		StrCpy $2 "yes"
	${Else}
		Pop $0

		UserInfo::GetAccountType
		Pop $1

		${Select} $1
			${Case2} "Admin" "Power"
				StrCpy $2 "yes"
			${CaseElse}
				StrCpy $2 "no"
		${EndSelect}
	${EndIf}

	Push $2
FunctionEnd

Function un.hasInstallRights
	ClearErrors
	UserInfo::GetName

	${If} ${Errors}
		StrCpy $2 "yes"
	${Else}
		Pop $0

		UserInfo::GetAccountType
		Pop $1

		${Select} $1
			${Case2} "Admin" "Power"
				StrCpy $2 "yes"
			${CaseElse}
				StrCpy $2 "no"
		${EndSelect}
	${EndIf}

	Push $2
FunctionEnd

Function .onInit
	Call hasInstallRights
	Pop $0

	${If} $0 == "no"
		MessageBox MB_OK|MB_ICONEXCLAMATION  "U heeft onvoldoende rechten om PipView te installeren.$\n$\nVraag een hoofdgebruiker of administrator om PipView voor u te installeren."
		Quit
	${EndIf}

	!insertmacro MUI_INSTALLOPTIONS_EXTRACT "pipview_installer.ini"
	!insertmacro MUI_INSTALLOPTIONS_EXTRACT "pipview_options.ini"

	FindWindow $R0 "TfrmPipMain"

	${If} $R0 != 0
		SendMessage $R0 16 0 0
	${EndIf}
FunctionEnd

Function EnterLogin
	!insertmacro MUI_HEADER_TEXT "Login-informatie" "Stel hier uw naam en wachtwoord in"
	!insertmacro MUI_INSTALLOPTIONS_DISPLAY "pipview_installer.ini"
FunctionEnd

Function LeaveLogin
	!insertmacro MUI_INSTALLOPTIONS_READ $0 "pipview_installer.ini" "Field 3" "State"
	!insertmacro MUI_INSTALLOPTIONS_READ $1 "pipview_installer.ini" "Field 4" "State"

	PipCrypto::Encrypt ; encrypt $1 -> $2

	Push $0
	Pop $Naam

	Push $2
	Pop $Wachtwoord
FunctionEnd

Function EnterOptions
	!insertmacro MUI_HEADER_TEXT "Opties" "Stel hier overige installatie-opties in"
	!insertmacro MUI_INSTALLOPTIONS_DISPLAY "pipview_options.ini"
FunctionEnd

Function LeaveOptions
	StrCpy $ShortcutStartup "no"
	StrCpy $ShortcutStartmenu "no"
	StrCpy $ShortcutDesktop "no"
	StrCpy $ShortcutQuicklaunch "no"

	!insertmacro MUI_INSTALLOPTIONS_READ $0 "pipview_options.ini" "Field 5" "State"

	${If} $0 == "1"
		StrCpy $ShortcutStartup "yes"
	${EndIf}

	!insertmacro MUI_INSTALLOPTIONS_READ $0 "pipview_options.ini" "Field 6" "State"
	${If} $0 == "1"
		StrCpy $ShortcutStartmenu "yes"
	${EndIf}

	!insertmacro MUI_INSTALLOPTIONS_READ $0 "pipview_options.ini" "Field 7" "State"
	${If} $0 == "1"
		StrCpy $ShortcutDesktop "yes"
	${EndIf}

	!insertmacro MUI_INSTALLOPTIONS_READ $0 "pipview_options.ini" "Field 8" "State"
	${If} $0 == "1"
		StrCpy $ShortcutQuicklaunch "yes"
	${EndIf}

	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PipView" "Users" "me"

	!insertmacro MUI_INSTALLOPTIONS_READ $0 "pipview_options.ini" "Field 3" "State"
	${If} $0 == "1"
		WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PipView" "Users" "all"
		SetShellVarContext all
	${EndIf}
FunctionEnd

; Uninstaller Functions
; ===================
Function un.onInit
	Call un.hasInstallRights
	Pop $0

	${If} $0 == "no"
		MessageBox MB_OK|MB_ICONEXCLAMATION  "U heeft onvoldoende rechten om PipView te verwijderen.$\n$\nVraag een hoofdgebruiker of administrator om PipView voor u te verwijderen."
		Quit
	${EndIf}

	FindWindow $R0 "TfrmPipMain"

	${If} $R0 != 0
		SendMessage $R0 16 0 0
	${EndIf}
FunctionEnd

; Uninstaller Section
; ===================
Section "Uninstall"
	ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PipView" "Users"

	${If} $0 == "all"
		SetShellVarContext all
	${EndIf}

	Delete "$SMSTARTUP\PipView.lnk"
	Delete "$QUICKLAUNCH\PipView.lnk"
	Delete "$DESKTOP\PipView.lnk"

	RMDir /r "$SMPROGRAMS\PipView"
	RMDir /r "$INSTDIR"

	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PipView"
	DeleteRegKey HKLM "Software\PipView"
	DeleteRegKey HKCU "Software\PipView"
SectionEnd
