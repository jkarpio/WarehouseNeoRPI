#!/bin/bash 

curl -L https://downloads.raspberrypi.org/NOOBS_latest --output NOOBS.zip

unzip NOOBS.zip -d NOOBS
rm -f NOOBS.zip

cd NOOBS/os/
cp -r ../../os_template/Warehouse_Neo ./

mv Raspbian/boot.tar.xz Warehouse_Neo/

mkdir root

tar -xJpf Raspbian/root.tar.xz -C root

rm -rf Raspbian

cd root

mount -o bind /sys/ ./sys/
mount -o bind /dev/pts/ ./dev/pts/
mount -o bind /dev/ ./dev/
mount -t proc none ./proc/

cp /usr/bin/qemu-arm ./usr/bin/
chroot ./ qemu-arm /bin/bash -x << EOF

apt-get update

apt-get install --yes mono-runtime-common mono-complete  gtk-sharp2

apt-get remove --yes --purge wolfram* minecraft-pi scratch* sonic-pi bluej greenfoot nodered nodejs

curl http://build.microinvestlatino.com/~micro/neo/warehouseneo.deb  --output warehouse.deb

dpkg -i warehouse.deb

rm -f warehouse.deb

EOF

umount -f -l ./sys/
umount -f -l ./dev/pts/
umount -f -l ./dev/
umount -f -l ./proc/

bsdtar --format=gnutar  -cpvJf ../Warehouse_Neo/root.tar.xz --exclude=./proc/* --exclude=./lost+found/* --exclude=./dev/* --exclude=./sys/* ./

cd ..

rm -rf root/

cd ..

cp ../A.png ./defaults/slides/A.png

tar -cvf ../NOOBS.tar ./

