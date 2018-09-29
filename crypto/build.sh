gcc -Wall -pedantic -o PipCrypto.o -c PipCrypto.c
gcc -shared -s -o PipCrypto.dll PipCrypto.o