


KERNEL := boot/vmlinuz-4.19.0-5-amd64
INITRD := boot/initrd.img-4.19.0-5-amd64
ROOT_IMAGE := debian8-std.qcow2
ROOT_DIR := root
INSTALL_IMAGE := /home/zqy/Software/debian-8.10.0-amd64-netinst.iso
#Port should be [10, 99]
#the vnc port is 59$(Port), the ssh port is 100$(Port)
PORT:= 20


.PHONY: run install vnc ssh env
#default: run_native


run_native:
	sudo qemu-system-x86_64 \
	-M pc \
	-no-user-config \
	-enable-kvm \
	-m 8G -mem-prealloc \
	-cpu host -smp sockets=1,cores=4,threads=2 \
	-drive file=$(ROOT_IMAGE),format=qcow2,if=none,id=drive0 \
	-device virtio-blk-pci,drive=drive0 \
	-netdev user,id=vnet,hostfwd=:0.0.0.0:100$(PORT)-:22 \
	-device virtio-net-pci,netdev=vnet \
	-nographic \
	-vnc :$(PORT) 

vnc:
	vncviewer localhost:59$(PORT)

ssh:
	ssh zqy@localhost -p 100$(PORT)

run_kernel:
	sudo qemu-system-x86_64 \
	-M pc \
	-enable-kvm \
	-m 8G -mem-prealloc \
	-cpu host -smp sockets=1,cores=4,threads=2 \
	-kernel $(KERNEL)   \
	-initrd $(INITRD) \
	-append 'root=/dev/sda1 console=tty0 console=ttyS0'  \
	-drive file=$(ROOT_IMAGE),format=qcow2,if=ide,id=drive0 \
	-netdev user,id=vnet,hostfwd=:0.0.0.0:100$(PORT)-:22 \
	-device virtio-net-pci,netdev=vnet \
	-serial stdio \
	-vnc :$(PORT)


install: $(ROOT_IMAGE)
	sudo qemu-system-x86_64 \
	-M pc \
	-no-user-config \
	-enable-kvm \
	-m 8G -mem-prealloc \
	-cpu host -smp sockets=1,cores=4,threads=2 \
	-cdrom $(INSTALL_IMAGE) \
	-drive file=$(ROOT_IMAGE),format=qcow2,if=none,id=drive0 \
	-device virtio-blk-pci,drive=drive0,id=drive0-dev,bootindex=1 \
	-netdev user,id=vnet,hostfwd=:0.0.0.0:100$(PORT)-:22 \
	-device virtio-net-pci,netdev=vnet \
	-nographic \
	-vnc :$(PORT) \
	-boot c


$(ROOT_IMAGE):
	qemu-img create -f qcow2 $(ROOT_IMAGE) 40g


mount:
	guestmount -a $(ROOT_IMAGE) -m /dev/sda1 $(ROOT_DIR)

unmount:
	guestunmount $(ROOT_DIR)



env:
	sudo apt install qemu-kvm qemu 
#	sudo apt install libvirt-bin virtinst virt-manager virt-viewer
#	sudo apt install bridge-utils
	sudo apt install libguestfs-tools
