{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.stirling-pdf;
in
{
  options.services.stirling-pdf = {
    enable = lib.mkEnableOption "the stirling-pdf service";

    package = lib.mkPackageOption pkgs "stirling-pdf" { };

    environment = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.str
          lib.types.int
        ]
      );
      default = { };
      example = {
        SERVER_PORT = 8080;
        INSTALL_BOOK_AND_ADVANCED_HTML_OPS = "true";
      };
      description = ''
        Environment variables for the stirling-pdf app.
        See <https://github.com/Stirling-Tools/Stirling-PDF#customisation> for available options.
      '';
    };

    environmentFiles = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = ''
        Files containing additional environment variables to pass to Stirling PDF.
        Secrets should be added in environmentFiles instead of environment.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.stirling-pdf = {
      environment = lib.mapAttrs (_: toString) cfg.environment;

      # following https://docs.stirlingpdf.com/Installation/Unix%20Installation
      path =
        with pkgs;
        [
          # `which` is used to test command availability
          # See https://github.com/Stirling-Tools/Stirling-PDF/blob/main/src/main/java/stirling/software/SPDF/config/ExternalAppDepConfig.java#L42
          which
          unpaper
          libreoffice
          qpdf
          ocrmypdf
          poppler-utils
          unoconv
          pngquant
          tesseract
          (python3.withPackages (
            p: with p; [
              weasyprint
              opencv-python-headless
            ]
          ))
          ghostscript_headless
        ]
        ++ lib.optional (cfg.environment.INSTALL_BOOK_AND_ADVANCED_HTML_OPS or "false" == "true") calibre;

      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        BindReadOnlyPaths = [ "${pkgs.tesseract}/share/tessdata:/usr/share/tessdata" ];
        CacheDirectory = "stirling-pdf";
        Environment = [ "HOME=%S/stirling-pdf" ];
        EnvironmentFile = cfg.environmentFiles;
        ExecStart = lib.getExe cfg.package;
        RuntimeDirectory = "stirling-pdf";
        StateDirectory = "stirling-pdf";
        SuccessExitStatus = 143;
        User = "stirling-pdf";
        WorkingDirectory = "/var/lib/stirling-pdf";

        # Hardening
        CapabilityBoundingSet = "";
        DynamicUser = true;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "~@cpu-emulation @debug @keyring @mount @obsolete @privileged @clock @setuid @chown"
        ];
        UMask = "0077";
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ DCsunset ];
}
