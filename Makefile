SHELL = bash

EDK2    := ~/SDK/edk2
WORKDIR := work
ESP     := ${WORKDIR}/esp.img

LOADER  := ${WORKDIR}/loader.elf
KERNEL  := kernel/kernel.elf

################################################################

.PHONY: all clean loader kernel run

all: ${ESP}
clean:
	rm -rf ${WORKDIR}

loader: ${LOADER}
kernel: ${KERNEL}
run: ${ESP}
	qemu-system-x86_64 -bios /usr/share/ovmf/OVMF.fd -hda ${ESP}

${WORKDIR}:
	mkdir -p ${WORKDIR}

${ESP}: ${KERNEL}
	@if [ -f ${LOADER} ]; then echo 'please run "make loader" before.'; exit; fi
	dd if=/dev/zero of=$@ bs=1M count=128
	mformat -i $@ ::
	mmd -i $@ ::EFI ::EFI/BOOT
	mcopy -i $@ ${LOADER} ::EFI/BOOT/BOOTX64.EFI
	mcopy -i $@ ${KERNEL} ::kernel.elf

################################################################

${LOADER}: ${WORKDIR}
	cd ${EDK2} && \
	  source edksetup.sh && \
	  build
	mv ${EDK2}/Build/MyLoaderX64/DEBUG_CLANG38/X64/Loader.efi $@

${KERNEL}:
	make -C kernel

################################################################
