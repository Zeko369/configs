# Automount

## 1. Make mount point
```bash
mkdir /mnt/big
```

## 2. Get drive UUID
```bash
sudo blkid
sudo fdisk -l
```

## 3. Edit fstab
```bash
sudo vim /etc/fstab
# then paste this
# UUID=1bd37cc5-9310-4fbf-b28e-4cef2d7e62a9 /mnt/big  ext4  defaults  0  2
```

## 4. Mount
```bash
sudo mount -a
```

## Allow others
```bash
sudo setfacl -R -m u:plex:rwx /mnt/big
```
