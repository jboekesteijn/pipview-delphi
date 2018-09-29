#define WIN32_LEAN_AND_MEAN
#include <windows.h>

#include "exdll.h"

void __declspec(dllexport) Encrypt(HWND hwndParent, int string_size, char *variables, stack_t **stacktop, extra_parameters *extra)
{
	int count, length;
	char input[128];
	char output[256];

	EXDLL_INIT();

	wsprintf(input, "%s", getuservariable(INST_1));

	output[0] = '\0';

	length = lstrlen(input);

	for(count = 0; count < length; count++)
		wsprintf(output, "%s%02X", output, input[count] ^ (count + 1));

	setuservariable(INST_2, output);
}

BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID lpReserved)
{
	return TRUE;
}
