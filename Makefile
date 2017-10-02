obj-m := net-speeder.o

openvz:
gcc -O2 -o netspeeder netspeeder.c -lpcap -lnet $1 -DCOOKED

kvm:
gcc -O2 -o netspeeder netspeeder.c -lpcap -lnet $1