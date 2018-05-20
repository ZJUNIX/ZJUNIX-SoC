TOOLCHAIN := /mnt/d/Mips-SDK/bin/mips-sde-elf-

AS := $(TOOLCHAIN)as.exe
LD := $(TOOLCHAIN)ld.exe
OC := $(TOOLCHAIN)objcopy.exe
OD := $(TOOLCHAIN)objdump.exe

OBJS := start.o sd_init.o loadKernel.o
ELF := bootstrap.elf
BINARY := bootstrap.bin
HEXDUMP := bootstrap.hex

INSTALL_TARGET := ../../coe/bootstrap.hex

%.o : %.s
	$(AS) -mips32 -EL $< -o $@
	
$(ELF) : $(OBJS)
	$(LD) $(OBJS) -o $(ELF) -EL -T ldscript -Map ldmap.txt

$(BINARY) : $(ELF)
	$(OC) -S -O binary $(ELF) $(BINARY)

$(HEXDUMP) : $(BINARY)
	od -t x4 -v -An $(BINARY) > $(HEXDUMP)

all : $(HEXDUMP)

disasm : $(ELF)
	$(OD) -S $(ELF) > disasm.txt	

install : $(HEXDUMP)
	cp $(HEXDUMP) $(INSTALL_TARGET)

clean :
	rm $(OBJS) $(ELF) $(BINARY) $(HEXDUMP) *.txt

stream : $(BINARY)
	od -t x1 -v -An -w1 $(BINARY) | awk '{for(i=1;i<=NF;++i){printf "%s",$$i}}'
