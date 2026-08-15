{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    obsidian
    ludusavi # For game saves
    proton-vpn # VPN
    github-desktop
    # pokego # Overlayed

    # Android phone screen mirror / control over USB (scrcpy + adb)
    # Note: android-udev-rules / programs.adb were removed from nixpkgs;
    # systemd 258 handles uaccess for the device automatically.
    android-tools # provides adb
    scrcpy # mirror + control phone screen over USB

    # USB device listing (lsusb) — dock/USB debugging
    usbutils

    # Neovim (NvChad) — extra editor; config is a plain git repo at
    # ~/.config/nvim (hand-edited, no Nix rebuild per tweak).
    neovim
    # Formatter binaries used by lua/configs/conform.lua
    stylua
    nixfmt # provides `nixfmt` (conform: nixfmt)
    shfmt
    prettier
    # LSP servers for lua/configs/lspconfig.lua (nvim-lspconfig finds them on
    # PATH; no mason downloads needed). Names must match the servers list.
    nixd
    lua-language-server
    typescript-language-server
    bash-language-server
    dockerfile-language-server
    docker-compose-language-service
    vscode-langservers-extracted # html, css, json
    yaml-language-server
    pyright
    rust-analyzer
    gopls
    clang-tools # clangd (C/C++)
    lazydocker
  ];
}
