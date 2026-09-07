# qutebrowser as second browser - NixOS module (self-contained)
# Matches the flake's browser-module pattern (see modules/programs/browser/firefox/).
# Firefox stays the default browser - this module is imported independently.

{
  lib,
  pkgs,
  ...
}: let
  # rbw-based Bitwarden fill (vendored from WingsZeng/qute-rbw, cryzed's
  # qute-bitwarden adapted for rbw): rofi picker -> fake-key user<Tab>pass.
  # Vendored byte-identical for easy re-syncs, so style-only flake8 hits
  # (long lines / comment spacing) are ignored rather than upstreamed.
  quteRbw = pkgs.writers.writePython3Bin "qute-rbw" {
    libraries = [pkgs.python3Packages.tldextract];
    flakeIgnore = ["E501" "E265" "E203"];
  } ./qute-rbw;
in {
  home-manager.sharedModules = [
    (_: {
      programs.qutebrowser = {
        enable = true;

        # Tabs: BreadOnPenguins-style toggle + vertical readability
        settings = {
          "tabs.title.format" = "{audio}{current_title}";
          "tabs.show" = "multiple"; # hide bar when only one tab
          # Site-NATIVE dark themes (prefers-color-scheme: dark) - applied at
          # launch (Blink arg, restart: true by design, hence a default here
          # not a keybind). ,d below is the separate forced-rendering toggle.
          "colors.webpage.preferred_color_scheme" = "dark";
          # Restore open tabs on every launch (session saved on quit)
          "auto_save.session" = true;
        };
        keyBindings.normal."tT" = "config-cycle tabs.position top left";
        # Bitwarden fill via rbw (rofi picker -> fake-key user<Tab>pass)
        keyBindings.normal.",p" = "spawn --userscript qute-rbw --terminal kitty";
        # Webpage light/dark toggle: ForceDarkMode web attribute applies LIVE
        # on QtWebEngine >= 6.7 (no restart; current tab needs :reload to
        # re-render). Session-scoped: resets to light on restart because the
        # HM-generated config.py uses load_autoconfig(False).
        keyBindings.normal.",d" = "config-cycle colors.webpage.darkmode.enabled true false";
        aliases.dark = "config-cycle colors.webpage.darkmode.enabled true false";
        # Tab bar toggle: cycles back to the module default (multiple), not always
        keyBindings.normal.",b" = "config-cycle tabs.show multiple never";

        # Fonts + padding go in extraConfig: the settings renderer does not
        # escape inner double quotes, which would break font specs like
        # 10pt "Iosevka Nerd Font".
        extraConfig = ''
          _f = "Iosevka Nerd Font"
          _fs = '10pt "Iosevka Nerd Font"'
          c.fonts.web.family.standard = _f
          c.fonts.web.family.sans_serif = _f
          c.fonts.web.family.serif = _f
          c.fonts.web.family.fixed = _f
          c.fonts.statusbar = _fs
          c.fonts.tabs.selected = _fs
          c.fonts.tabs.unselected = _fs
          c.fonts.completion.category = 'bold 10pt "Iosevka Nerd Font"'
          c.fonts.completion.entry = _fs
          c.fonts.keyhint = _fs
          c.fonts.messages.info = _fs
          c.fonts.messages.warning = _fs
          c.fonts.messages.error = _fs
          c.fonts.prompts = _fs
          c.tabs.padding = {'top': 5, 'bottom': 5, 'left': 9, 'right': 9}
          # qutebrowser#8908 / QTBUG-145344: GBM buffer path black-flashes
          # video content on AMD + Wayland + Qt 6.11.x. 3.7.0's auto-
          # workaround checks webengine == 6.11.0 exactly, so 6.11.1 (ours)
          # is skipped; 6.11.1 users in the issue confirmed this env var
          # still fixes it. Must be dict-ASSIGNMENT syntax: HM's settings
          # renderer would flatten a nested attrset into a dotted
          # config.set("qt.environ.KEY", ...) which qutebrowser rejects
          # ("No option" error - dict options can't use dotted paths).
          # Drop when QTBUG-145344 is fixed properly.
          c.qt.environ['QTWEBENGINE_FORCE_USE_GBM'] = '0'
        '';
      };

      # rbw CLI Bitwarden client. Config (~/.config/rbw/config.json) is
      # intentionally NOT HM-managed (settings = null): the user runs
      # `rbw config set email` / `rbw login` themselves, and a rebuild
      # must not wipe that.
      programs.rbw.enable = true;
      home.packages = [pkgs.pinentry-curses];

      # HM has no qutebrowser.userscripts option -> land the binary in
      # ~/.local/share/qutebrowser/userscripts/ (qutebrowser's spawn
      # --userscript lookup path).
      xdg.dataFile."qutebrowser/userscripts/qute-rbw" = {
        source = "${quteRbw}/bin/qute-rbw";
        executable = true;
      };
    })
  ];
}