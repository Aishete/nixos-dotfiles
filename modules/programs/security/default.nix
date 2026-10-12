# Pentest / security-tool suite migrated from a pinned old-channel
# `nix profile` install into the flake, so these tools share the system's
# python/gcc/openssl closures instead of carrying duplicate ones.
# Removed from the profile in favor of systemPackages; hermes-agent's
# profile entry ("desktop") is intentionally NOT part of this.
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Recon / OSINT
    amass
    fierce
    dnsenum
    dnstwist
    theharvester
    # maigret: skip-listed 2026-10-15 — python3.14-python-socks check phase (all 429 proxy tests fail: local test http server never listens in sandbox) breaks aiohttp-socks->maigret on current pin
    sherlock
    recon-ng
    subfinder
    dnsx
    naabu
    whois
    dnsutils # dig, nslookup
    whatweb
    wafw00f
    exiftool

    # Web exploitation / fuzzing
    ffuf
    feroxbuster
    gobuster
    nikto
    nuclei
    katana
    httpx
    sqlmap

    # Exploitation / post-exploitation
    metasploit
    exploitdb
    pwntools
    radare2
    mitmproxy
    # netexec: skip-listed 2026-10-15 — python3.12 dep chain (anyio tests, aardwolf) broken on current pin; stays in nix profile until pin advances
    medusa
    bettercap

    # Password / creds
    hashcat
    john
    hydra # Hydra CI framework (nixpkgs top-level `hydra`)
    thc-hydra # THC-Hydra login cracker
    trufflehog
    gitleaks
    holehe

    # Phishing
    gophish

    # Network / sniffing
    nmap
    masscan
    tcpdump
    socat # also used by hyprland scripts
    binwalk
    testssl # testssl.sh
  ];
}