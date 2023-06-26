# nixos-mac

NixOS on an Intel MacBook with a T2 chip.

# Disclaimer

This is _not_ the most advanced way to install NixOS. With that said, it works, and it's easy to get started; the best part is you can improve unboundedly from within NixOS.

# Instructions

## Partition the disk

Open "About This Mac" (click the top-left Apple icon) and on the first screen (Overview), look at the amount in GB next to Memory. This is the amount of RAM on your laptop.
Open Disk Utility (the app—search in Spotlight). Under the View menu, view all disks (not just volumes). Click the top-most disk in the left-hand menu; you should be able to collapse everything under it.
Click Partition. Many on the Internet recommend making more than one partition (e.g. for user files & system files); I let NixOS handle it and just use one.

Make two partitions, all `MS-DOS (FAT)` (NOT `APFS`):
  1. `NIXOS` for literally everything on NixOS (as big as you can afford);
  3. `NIXSWAP`, for Linux-y reasons I don't fully understand, with about as much storage as RAM you found earlier.

## Configure for Apple firmware

Read [this](https://wiki.t2linux.org/guides/wifi-bluetooth) and stop at the header "On Linux." You might have to `chmod +x firmware.sh` from inside Downloads before running it.
Look at the commands it asks you to execute when it's done. Don't run them, but check if they match the following exactly:
```
sudo umount /dev/nvme0n1p1
sudo mkdir /tmp/apple-wifi-efi
sudo mount /dev/nvme0n1p1 /tmp/apple-wifi-efi
bash /tmp/apple-wifi-efi/firmware.sh
```
If they don't, write them down, and execute them instead when I ask you to (later).

Also execute `sudo nvram manufacturing-enter-picker=true` if you want the option to boot into macOS or NixOS every time you restart your computer.

## Make your USB bootable

Grab a USB you (really) don't care about with at least 4GB of storage. Make absolutely sure there's nothing on it you wouldn't want to erase permanently.
Grab an ISO from [t2linux on GitHub](https://github.com/t2linux/nixos-t2-iso/releases): choose the `minimal` option, and change the extension from `iso_part...` to just plain `iso`.
Either download Balena Etcher (again, search, plenty of tutorials) and boot the `iso` from above to your flash drive, or go the super-dangerous `dd` route if you'd like.
You _should_ get an error popup after it's done (macOS saying the flash drive is unreadable); this is good, and it means the flashing succeeded. Go ahead and eject.

## Installing NixOS

Bring up this guide on a different device (your phone?).

Restart your computer, holding Command+R the whole time.
Log in, find the Utilities menu, and click Startup Security Utility. Disable security and allow booting from flash drives, both for obvious reasons.

Restart your computer, holding the Option key the whole time.
You should see a menu with the metal-looking Macintosh HD icon and an additional (currently yellow, currently called "EFI Boot") one. Choose the latter.
Wait a bit. You'll eventually be at a command prompt with a flashing cursor. Congrats: you're running NixOS _from the flash drive_, but it isn't on your machine yet.

If you're squinting to read small text, execute `setfont ter-v32n`.

Now, execute `sudo -i`. The left-hand side should turn red. This is good, but it means you now have the power to fuck over your entire computer. Be cautious.

We're going to format our new partitions with Linux filesystems that Apple doesn't recognize.
Run the following commands to erase both partitions(!!! careful!!!) and turn them into a Linux swap and `ext4` filesystem, respectively:
```
mkswap -L NIXSWAP /dev/disk/by-label/NIXSWAP
mkfs.ext4 -L NIXOS /dev/disk/by-label/NIXOS
```

Let's follow up on the firmware stuff from earlier. If you had different commands earlier, run those; otherwise, run these, which are _basically_ the same but more reliable:
```
umount /dev/nvme0n1p1
mkdir /tmp/apple-wifi-efi
mount /dev/nvme0n1p1 /tmp/apple-wifi-efi
mkdir -p /lib/firmware
bash /tmp/apple-wifi-efi/firmware.sh
```

Then set up WiFi with the following:
```
systemctl start wpa_supplicant
wpa_cli
add_network
set_network 0 ssid "TYPE IN YOUR NETWORK HERE"
set_network 0 psk "TYPE IN YOUR PASSWORD HERE"
set_network 0 key_mgmt WPA-PSK
enable_network 0
q
```

Now, make sure none of your partitions are mounted already (if they do, they'll have a path in the rightmost column):
```
lsblk -o NAME,FSTYPE,SIZE,LABEL,MOUNTPOINT
```
If any are mounted, run `umount /dev/...` on the path.

Next, we're going to follow almost exactly the rest of the commands from SuperUser:
```
swapon /dev/disk/by-label/NIXSWAP
mount /dev/disk/by-label/NIXROOT /mnt
mkdir /mnt/boot
mkdir /mnt/boot/efi
mkdir /mnt/home
mount /dev/disk/by-label/EFI /mnt/boot/efi
mount /dev/disk/by-label/NIXHOME /mnt/home
```
Alright, we've integrated the new filesystems/partitions, so we can access them normally.

Now for the Nix-specific stuff:
```
nixos-generate-config --root /mnt
```

Then, delete `configuration.nix` and copy in `configuration.nix` from this repo, with the exception of your username and settings (duh).
You can run `nano configuration.nix` for a simple text editor; when you're done, hit Control-`X` (not command! this is Linux) and respond to the prompt with `y`.

Only two more steps!
```
nixos-install
reboot
```

# Recommended reading and sources I want to credit

Fantastic guide, most of my configuration came from here: [Ray Harris @ dev.to](https://dev.to/raymondgh/day-4-reinstalling-nixos-on-my-apfs-t2-intel-macbook-pro-265n)

Another shorter guide that assumes familiarity with `mkfs.ext4` et al.: [SuperUser](https://superuser.com/questions/795879/how-to-configure-dual-boot-nixos-with-mac-os-x-on-an-uefi-macbook)

Ready-made `.iso`s: [t2linux on GitHub](https://github.com/t2linux/nixos-t2-iso/releases)
