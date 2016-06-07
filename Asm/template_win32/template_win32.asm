
    .386
    .model  flat , stdcall
    option  casemap :none

include     windows.inc
include     user32.inc
include     kernel32.inc
includelib  user32.lib
includelib  kernel32.lib

ICO_MAIN        equ 1000h
IDM_MAIN        equ 2000h
IDA_MAIN        equ 2000h
IDM_OPEN        equ 4101h
IDM_OPTION      equ 4102h
IDM_EXIT        equ 4103h
IDM_SETFONT     equ 4201h
IDM_SETCOLOR    equ 4202h
IDM_INACT       equ 4203h
IDM_GRAY        equ 4204h
IDM_BIG         equ 4205h
IDM_SMALL       equ 4206h
IDM_LIST        equ 4207h
IDM_DETAIL      equ 4208h
IDM_TOOLBAR     equ 4209h
IDM_TOOLBARTEXT equ 4210h
IDM_INPUTBAR    equ 4211h
IDM_STATUSBAR   equ 4212h
IDM_HELP        equ 4301h
IDM_ABOUT       equ 4302h

.data?
hInstance       dd      ?
hWinMain        dd      ?
hMenu           dd      ?
hSubMenu        dd      ?

.const
szClassName     db      'Template_win32' , 0
szCaptionMain   db      'Template_win32' , 0
szMenuAbout     db      'wassup about' , 0
szCaption       db      '�˵�ѡ��' , 0
szFormat        db      'ѡ�������� %08x' , 

.code

_DisplayMenuItem        proc    _dwCommandID
                        local   @szBuffer[256]:byte
        pushad
        invoke  wsprintf , addr @szBuffer , addr szFormat , _dwCommandID
        invoke  MessageBox , hWinMain , addr @szBuffer , offset szCaption , MB_OK
        popad
        ret
_DisplayMenuItem        endp

_Quit           proc
        invoke  DestroyWindow , hWinMain
        invoke  PostQuitMessage , NULL
        ret
_Quit           endp

_ProcWinMain    proc    uses ebx edi esi hWnd , uMsg , wParam , lParam
                local   @stPos:POINT , @hSysMenu
        mov     eax , uMsg
        .if     eax == WM_CREATE
                invoke  GetSubMenu , hMenu , 1
                mov     hSubMenu , eax
                invoke  GetSystemMenu , hWnd , FALSE
                mov     @hSysMenu , eax
                invoke  AppendMenu , @hSysMenu , MF_SEPARATOR , 0 , NULL
                invoke  AppendMenu , @hSysMenu , 0 , IDM_ABOUT , offset szMenuAbout
        .elseif eax == WM_COMMAND
                invoke  _DisplayMenuItem , wParam
                mov     eax , wParam
                movzx   eax , ax
                .if     eax == IDM_EXIT
                        call    _Quit
                .elseif eax >= IDM_TOOLBAR && eax <= IDM_STATUSBAR
                        mov ebx , eax
                        invoke  GetMenuState , hMenu , ebx , MF_BYCOMMAND
                        .if     eax == MF_CHECKED
                                mov eax , MF_UNCHECKED
                        .else
                                mov eax , MF_CHECKED
                        .endif
                        invoke  CheckMenuItem , hMenu , ebx , eax
                .elseif eax >= IDM_BIG && eax <= IDM_DETAIL
                        invoke  CheckMenuRadioItem , hMenu , IDM_BIG , IDM_DETAIL , eax , MF_BYCOMMAND
                .endif
        .elseif eax == WM_SYSCOMMAND
                mov     eax , wParam
                movzx   eax , ax
                .if     eax == IDM_HELP 
                        invoke  _DisplayMenuItem , wParam
                .else
                        invoke  DefWindowProc , hWnd , uMsg , wParam , lParam
                        ret
                .endif
        .elseif eax == WM_RBUTTONDOWN
                invoke  GetCursorPos , addr @stPos
                invoke  TrackPopupMenu ,
                            hSubMenu ,
                            TPM_LEFTALIGN ,
                            @stPos.x ,
                            @stPos.y ,
                            NULL ,
                            hWnd ,
                            NULL
        .elseif eax == WM_CLOSE
                call    _Quit
        .else
                invoke  DefWindowProc , hWnd , uMsg , wParam , lParam
                ret
        .endif
        xor     eax , eax
        ret
_ProcWinMain    endp

_WinMain        proc
                local   @stWndClass:WNDCLASSEX ,
                        @stMsg:MSG ,
                        @hAccelerator
                invoke  GetModuleHandle , NULL
                mov     hInstance , eax
                invoke  LoadMenu , hInstance , IDM_MAIN
                mov     hMenu , eax
                invoke  LoadAccelerators , hInstance , IDA_MAIN
                mov     @hAccelerator , eax
                invoke  RtlZeroMemory , addr @stWndClass , sizeof @stWndClass
                invoke  LoadIcon , hInstance , ICO_MAIN
                mov     @stWndClass.hIcon , eax
                mov     @stWndClass.hIconSm , eax
                invoke  LoadCursor , 0 , IDC_ARROW
                mov     @stWndClass.hCursor , eax
                push    hInstance
                pop     @stWndClass.hInstance
                mov     @stWndClass.cbSize , sizeof WNDCLASSEX
                mov     @stWndClass.style , CS_HREDRAW or CS_VREDRAW
                mov     @stWndClass.lpfnWndProc , offset _ProcWinMain
                mov     @stWndClass.hbrBackground , COLOR_WINDOW + 1
                mov     @stWndClass.lpszClassName , offset szClassName
                invoke  RegisterClassEx , addr @stWndClass
                invoke  CreateWindowEx ,
                            WS_EX_CLIENTEDGE ,
                            offset szClassName ,
                            offset szCaptionMain ,
                            WS_OVERLAPPEDWINDOW ,
                            100 , 100 , 400 , 300 ,
                            NULL , hMenu , hInstance , NULL
                mov     hWinMain , eax
                invoke  ShowWindow , hWinMain , SW_SHOWNORMAL
                invoke  UpdateWindow , hWinMain
                .while  TRUE
                        invoke  GetMessage , addr @stMsg , NULL , 0 , 0
                        .break  .if eax == 0
                        invoke  TranslateAccelerator , hWinMain , @hAccelerator , addr @stMsg
                        .if     eax == 0
                                invoke  TranslateMessage , addr @stMsg
                                invoke  DispatchMessage , addr @stMsg
                        .endif
                .endw
                ret
_WinMain        endp

start:
        call    _WinMain
        invoke  ExitProcess,NULL
        end     start