----
<https://forums.developer.nvidia.com/t/fixed-suspend-resume-issues-with-the-driver-version-470/187150/3>

Works with nvidia-driver-495 as well.

Good news for affected users! I found a fix!

A LITTLE BACKGROUND
You may already know that NVIDIA drivers on Linux rely on either of two different methods for power management ( as described here 22 ), which include:

- Kernel Driver Callback: Works out of the box with no configuration required, but lacks advanced power management features and preserves only a portion of the video memory.
- systemd (/proc/driver/nvidia/suspend): Provides advanced power management features and preserves complete video memory, but requires configuration and setup.

THE CAUSE
Having mentioned the above, upon further inspection I found out the 470 driver migrated to systemd method while previous versions relied on Kernel Driver Callback. Apparently this is broken on some setups and kernels.

THE WORKAROUND
Now it’s obvious we have to revert back to Kernel Driver Callback method for now that the systemd method is broken, and here’s how you can do that:

Disable NVIDIA systemd services
```
sudo systemctl stop nvidia-suspend.service
sudo systemctl stop nvidia-hibernate.service
sudo systemctl stop nvidia-resume.service

sudo systemctl disable nvidia-suspend.service
sudo systemctl disable nvidia-hibernate.service
sudo systemctl disable nvidia-resume.service
```
Remove NVIDIA systemd script
`sudo rm /lib/systemd/system-sleep/nvidia`
Reboot and you should be able to suspend and resume properly with driver version 470.xx.

NOTE: Backup your configuration just in case, or downgrade the driver if this does not work on your setup. This was tested on Kubuntu 21.04 with GeForce GT 710.

----
