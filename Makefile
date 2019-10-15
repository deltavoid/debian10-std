#

Image := debian10-std.qcow2
InstallDisc := /home/zqy/Software/debian-live-10.0.0-amd64-standard.iso
#Port should be [10, 99]
#the vnc port is 59$(Port), the ssh port is 100$(Port)
Port := 10


.PHONY: run install vnc ssh env
default: run


run:
	sudo qemu-system-x86_64 \
	-M pc -name "debian10-std" \
	-no-user-config \
	-enable-kvm \
	-m 4G -mem-prealloc \
	-cpu host -smp sockets=2,cores=4,threads=1 \
	-drive file=$(Image),format=qcow2,if=none,id=drive0 \
	-device virtio-blk-pci,drive=drive0,id=drive0-dev,bootindex=1 \
	-netdev user,id=vnet,hostfwd=:0.0.0.0:100$(Port)-:22 \
	-device virtio-net-pci,netdev=vnet \
	-nographic \
	-vnc :$(Port) \
	-boot c

vnc:
	vncviewer localhost:59$(Port)

ssh:
	ssh zqy@localhost -p 100$(Port)


install: $(Image)
	sudo qemu-system-x86_64 \
	-M pc -name "debian10-std" \
	-no-user-config \
	-enable-kvm \
	-m 4G -mem-prealloc \
	-cpu host -smp sockets=2,cores=4,threads=1 \
	-cdrom /home/zqy/Software/debian-live-10.0.0-amd64-standard.iso \
	-drive file=$(Image),format=qcow2,if=none,id=drive0 \
	-device virtio-blk-pci,drive=drive0,id=drive0-dev,bootindex=1 \
	-netdev user,id=vnet,hostfwd=:0.0.0.0:10027-:22 \
	-device virtio-net-pci,netdev=vnet \
	-nographic \
	-vnc :$(Port) \
	-boot c


$(Image):
	qemu-img create -f qcow2 $(Image) 40g


env:
	sudo apt install qemu-kvm qemu 
#	sudo apt install libvirt-bin virtinst virt-manager virt-viewer
#	sudo apt install bridge-utils
