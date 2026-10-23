{ pkgs, ... }:
{
  services.gnome.gnome-keyring.enable = true;
  security = {
    rtkit.enable = true;
    polkit.enable = true;
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
      packages = [ pkgs.apparmor-profiles ];
    };
    pki.caCertificateBlacklist = [
      "Comodo AAA Services root"
      "emSign ECC Root CA - G3"
    ];

    # Prevent replacing the running kernel without a reboot
    protectKernelImage = true;
    acme.acceptTerms = true;
  };
}
