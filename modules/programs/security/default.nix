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
    maigret
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
    netexec
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