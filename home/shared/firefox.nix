{
  config,
  pkgs,
  inputs,
  outputs,
  ...
}: {
  # TODO Import my custom CSS module
  #imports = [outputs.homeManagerModules.sidebery-css];

  # Enable and configure FireFox
  programs.firefox = {
    enable = true;

    # Policy settings
    policies = {
      # Basic settings
      HardwareAcceleration = true;
      DefaultDownloadDirectory = "\${home}/Downloads";

      # Disable annoying stuff
      AppAutoUpdate = false;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DisplayBookmarksToolbar = "always";
      OfferToSaveLogins = false;

      # Hard-disable Firefox's DoH
      DNSOverHTTPS = {
        Enabled = false;
        Locked = true;
      };

      # Search configuration
      SearchSuggestEnabled = true;
      FirefoxSuggest = {
        SponsoredSuggestions = false;
        ImproveSuggest = false;
      };
    };

    # Configure my user profile
    profiles."sonar" = {
      isDefault = true;

      # Install extensions
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        bitwarden
        clearurls
        darkreader
        duckduckgo-privacy-essentials
        foxytab
        ghostery
        improved-tube
        notion-web-clipper
        privacy-badger
        sidebery
        ublock-origin
        wikiwand-wikipedia-modernized
      ];

      # Configure search settings
      search = {
        default = "DuckDuckGo";
        force = true;
        order = ["DuckDuckGo" "Nix Packages" "NixOS Wiki" "Google"];

        # Add Nix and Wiki searching
        engines = {
          # Nix package search
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@np"];
          };

          # Nix wiki search
          "NixOS Wiki" = {
            urls = [
              {
                template = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@nw"];
          };

          # Disable garbage
          "Bing".metaData.hidden = true;
          "Amazon.com".metaData.hidden = true;
          "eBay".metaData.hidden = true;
        };
      };

      # Firefox settings
      settings = {
        # General settings
        "browser.contentblocking.category" = "standard";
        "browser.gnome-search-provider.enabled" = true;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.search.suggest.enabled" = true;
        "browser.startup.page" = 3;
        "browser.download.useDownloadDir" = false;
        "dom.security.https_only_mode" = true;
        "experiments.activeExperiment" = false;
        "experiments.enabled" = false;
        "experiments.supported" = false;
        "extensions.pocket.enabled" = false;
        "gfx.webrender.all" = true;
        "network.allow-experiments" = false;
        "privacy.donottrackheader.enabled" = true;
        "privacy.donottrackheader.value" = 1;
        "signon.rememberSignons" = false;
        "widget.use-xdg-desktop-portal.file-picker" = 1;

        # Theme settings
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.uidensity" = 0;
        "svg.context-properties.content.enabled" = true;
        "browser.theme.dark-private-windows" = false;
        "widget.gtk.rounded-bottom-corners.enabled" = true;
        "layers.acceleration.force-enabled" = true;
      };

      # Set up userChrome to import my css tweaks
      userChrome = ''
        @import url(window_control_placeholder_support.css);
        @import url(window_control_force_linux_system_style.css);
        @import url(hide_tabs_toolbar.css);
        @import url(urlbar_centered_text.css);
        @import url(autohide_sidebar.css);

        #sidebar-header {
          display: none;
        }

        #sidebar-box{
          --uc-sidebar-width: 34px;
          --uc-sidebar-hover-width: 230px;
          --uc-autohide-sidebar-delay: 600ms;
          --uc-autohide-transition-duration: 115ms;
          --uc-autohide-transition-type: linear;
          position: relative;
          min-width: var(--uc-sidebar-width) !important;
          width: var(--uc-sidebar-width) !important;
          max-width: var(--uc-sidebar-width) !important;
          z-index:1;
        }
      '';
    };
  };

  # Add the actual CSS tweaks
  home.file = let
    currHash = "sha256-8xO0QtDNx4uAT52T+dND+EsInBXVgWVel2yM6recSmY=";
  in {
    # Fix window controls
    ".mozilla/firefox/sonar/chrome/window_control_placeholder_support.css".text =
      builtins.readFile
      (pkgs.fetchFromGitHub {
          owner = "MrOtherGuy";
          repo = "firefox-csshacks";
          rev = "master";
          hash = currHash;
        }
        + "/chrome/window_control_placeholder_support.css");

    # Fix window control theme
    ".mozilla/firefox/sonar/chrome/window_control_force_linux_system_style.css".text =
      builtins.readFile
      (pkgs.fetchFromGitHub {
          owner = "MrOtherGuy";
          repo = "firefox-csshacks";
          rev = "master";
          hash = currHash;
        }
        + "/chrome/window_control_force_linux_system_style.css");

    # Hide the tab toolbar
    ".mozilla/firefox/sonar/chrome/hide_tabs_toolbar.css".text =
      builtins.readFile
      (pkgs.fetchFromGitHub {
          owner = "MrOtherGuy";
          repo = "firefox-csshacks";
          rev = "master";
          hash = currHash;
        }
        + "/chrome/hide_tabs_toolbar.css");

    # Center the text in the url bar
    ".mozilla/firefox/sonar/chrome/urlbar_centered_text.css".text =
      builtins.readFile
      (pkgs.fetchFromGitHub {
          owner = "MrOtherGuy";
          repo = "firefox-csshacks";
          rev = "master";
          hash = currHash;
        }
        + "/chrome/urlbar_centered_text.css");

    # Automatically collapse sidebery
    ".mozilla/firefox/sonar/chrome/autohide_sidebar.css".text =
      builtins.readFile
      (pkgs.fetchFromGitHub {
          owner = "MrOtherGuy";
          repo = "firefox-csshacks";
          rev = "master";
          hash = currHash;
        }
        + "/chrome/autohide_sidebar.css");
  };
}
