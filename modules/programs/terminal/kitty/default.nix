{ pkgs, host, ... }:
let
  inherit (import ../../../../hosts/${host}/variables.nix) monospaceFont;
in
{
  home-manager.sharedModules = [
    (_: {
      programs.kitty = {
        enable = true;
        font = {
          size = 12.0;
          name = monospaceFont;
        };
        settings = {
          # shell = "${getExe pkgs.tmux}";
          cursor_trail = 3; # Fancy cursor movements (especially in nixvim)
          cursor_trail_decay = "0.08 0.3"; # Animation speed
          cursor_trail_start_threshold = "4";
          strip_trailing_spaces = "smart";
          macos_option_as_alt = "yes";
          macos_quit_when_last_window_closed = true;
          copy_on_select = "yes";
          confirm_os_window_close = 0;
          scrollback_lines = 10000;
          enable_audio_bell = false;
          mouse_hide_wait = 60;
          update_check_interval = 0;

          # Scriptwiz Pure Black Theme colors
          background = "#0f0f0f";
          foreground = "#F9EEE5";
          cursor = "#9dc34f";
          selection_background = "#272A28";
          selection_foreground = "#F9EEE5";
          
          color0 = "#0f0f0f";
          color8 = "#6B746E";
          color1 = "#cb3d96";
          color9 = "#cb3d96";
          color2 = "#9dc34f";
          color10 = "#9dc34f";
          color3 = "#ef944d";
          color11 = "#ef944d";
          color4 = "#878E7A";
          color12 = "#878E7A";
          color5 = "#cb3d96";
          color13 = "#cb3d96";
          color6 = "#878E7A";
          color14 = "#878E7A";
          color7 = "#F9EEE5";
          color15 = "#E3DAC9";

          ## Tabs
          tab_title_template = "{index}";
          active_tab_font_style = "normal";
          inactive_tab_font_style = "normal";
          tab_bar_style = "powerline";
          tab_powerline_style = "round";
          active_tab_foreground = "#0f0f0f";
          active_tab_background = "#9dc34f";
          inactive_tab_foreground = "#878E7A";
          inactive_tab_background = "#131414";
        };
        # shellIntegration.mode = "no-sudo";
        keybindings = {
          "ctrl+alt+n" = "launch --cwd=current";
          "alt+w" = "copy_and_clear_or_interrupt";
          "ctrl+y" = "paste_from_clipboard";
          "alt+1" = "goto_tab 1";
          "alt+2" = "goto_tab 2";
          "alt+3" = "goto_tab 3";
          "alt+4" = "goto_tab 4";
          "alt+5" = "goto_tab 5";
          "alt+6" = "goto_tab 6";
          "alt+7" = "goto_tab 7";
          "alt+8" = "goto_tab 8";
          "alt+9" = "goto_tab 9";
          "alt+0" = "goto_tab 10";

          # Tmux
          "ctrl+t" = "launch --cwd=current --type=overlay tmux-sessionizer";
          # "ctrl+t" = "launch --cwd=current --title tmux-sessionizer tmux-sessionizer";
          "ctrl+shift+left" = "no_op";
          "ctrl+shift+right" = "no_op";
        };
      };
    })
  ];
}
