{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    obsidian
    ludusavi # For game saves
    protonvpn-gui # VPN
    github-desktop
    # pokego # Overlayed

    # Android phone screen mirror / control over USB (scrcpy + adb)
    # Note: android-udev-rules / programs.adb were removed from nixpkgs;
    # systemd 258 handles uaccess for the device automatically.
    android-tools # provides adb
    scrcpy # mirror + control phone screen over USB

    # USB device listing (lsusb) — dock/USB debugging
    usbutils
  ];
}
