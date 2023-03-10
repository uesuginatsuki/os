SHELL = bash

EDK2    := ~/SDK/edk2
WORKDIR := work
ESP     := ${WORKDIR}/esp.img

LOADER  := ${WORKDIR}/loader.elf
KERNEL  := kernel/kernel.elf

################################################################

.PHONY: all clean run

all: ${ESP}
clean:
	rm -rf ${WORKDIR}
run: ${ESP}
	qemu-system-x86_64 -bios /usr/share/ovmf/OVMF.fd -hda ${ESP}

${ESP}: ${LOADER} ${KERNEL}
	dd if=/dev/zero of=$@ bs=1M count=128
	mformat -i $@ ::
	mmd -i $@ ::EFI ::EFI/BOOT
	mcopy -i $@ ${LOADER} ::EFI/BOOT/BOOTX64.EFI
	mcopy -i $@ ${KERNEL} ::kernel.elf

################################################################

.PHONY: loader

loader:
	mkdir -p ${WORKDIR}
	cd ${EDK2} && \
	  source edksetup.sh && \
	  build
	mv ${EDK2}/Build/MyLoaderX64/DEBUG_CLANG38/X64/Loader.efi ${LOADER}

################################################################

.PHONY: kernel

kernel: ${KERNEL}

${KERNEL}:
	make -C kernel

################################################################
