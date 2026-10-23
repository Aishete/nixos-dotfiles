{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    pritunl-client
  ];

  systemd.packages = [ pkgs.pritunl-client ];

  systemd.targets.multi-user.wants = [ "pritunl-client.service" ];
}
