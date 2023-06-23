# nixos-mac

NixOS on an Intel MacBook with a T2 chip.

# Recommended reading

Best guide BUT assumes familiarity with Linux `mkfs.ext4` and skips its steps: [SuperUser](https://superuser.com/questions/795879/how-to-configure-dual-boot-nixos-with-mac-os-x-on-an-uefi-macbook)

Reading currently but looks great: [Ray Harris @ dev.to](https://dev.to/raymondgh/day-4-reinstalling-nixos-on-my-apfs-t2-intel-macbook-pro-265n)

Ready-made ISO: [t2linux on GitHub](https://github.com/t2linux/nixos-t2-iso/releases)

# Instructions

## Partition the disk

Open "About This Mac" (click the top-left Apple icon) and on the first screen (Overview), look at the amount in GB next to Memory. This is the amount of RAM on your laptop.
Open Disk Utility (the app—search in Spotlight). Under the View menu, view all disks (not just volumes). Click the top-most disk in the left-hand menu; you should be able to collapse everything under it.
Click Partition. Make three partitions, all `MS-DOS (FAT)` (NOT `APFS`):
  1. `NIXHOST` for your personal files;
  2. `NIXROOT` for the literal OS and developer-y stuff (understanding incomplete, will clarify);
  3. `NIXSWAP`, with exactly as much storage as RAM you found earlier.

## Install rEFInd

There are plenty of tutorials out there. If you're advanced enough to want to boot Linux, you probably know how to search the Internet. <3

## Configure for Apple firmware

Read [this](https://wiki.t2linux.org/guides/wifi-bluetooth) and stop at the header "On Linux." You might have to `chmod +x firmware.sh` from inside Downloads before running it.
Look at the commands it asks you to execute when it's done. They should match the following exactly:
```
sudo umount /dev/nvme0n1p1
sudo mkdir /tmp/apple-wifi-efi
sudo mount /dev/nvme0n1p1 /tmp/apple-wifi-efi
bash /tmp/apple-wifi-efi/firmware.sh
```
If they don't, write them down, and execute them instead when I ask you to (later).

Also execute `sudo nvram manufacturing-enter-picker=true`.

## Make your USB bootable

Grab a USB you don't care about with at least 4GB of storage. Make absolutely sure there's nothing on it you care about.
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
Run the following commands __and search what they mean if you don't know__ (look right after the block for a summary):
```
mkswap -L NIXSWAP /dev/disk/by-label/NIXSWAP
mkfs.ext4 -L NIXROOT /dev/disk/by-label/NIXROOT
mkfs.ext4 -L NIXHOST /dev/disk/by-label/NIXHOST
```
The SuperUser link under Recommended Reading _implied_ these steps but didn't explain them, and it tripped me up the first time.

Now follow up on the firmware stuff from earlier. Scroll up and execute them, or if it asked you to execute different commands, execute those now.

Then, we'll set up WiFi. Execute the following:
```
systemctl start wpa_supplicant
wpa_cli
add_network
set_network 0 ssid "TYPE IN YOUR NETWORK HERE"
set_network 0 psk "TYPE IN YOUR PASSWORD HERE"
set_network 0 key_mgmt WPA-PSK
enable_network 0
```

Exit `wpa_cli` and make sure none of your partitions are mounted already:
```
lsblk -o NAME,FSTYPE,SIZE,LABEL,MOUNTPOINT
```
If you see any of them, run `umount /dev/...` on them.

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

Then edit this file to allow "unfree" (proprietary, not open-source) Apple drivers you'll need to run your laptop:
```
nano /mnt/etc/nixos/configuration.nix
```

Add this line anywhere in the file between the first and last braces, then quit with Control-`X` (not command! this is Linux) and respond to the prompt with `y`.
```
nixpkgs.config.allowUnfree = true;
```
Note the semicolon.

Only two more steps!
```
nixos-install
reboot
```

I'm currently here, so I'll update this guide with more detailed steps once I get it working.
