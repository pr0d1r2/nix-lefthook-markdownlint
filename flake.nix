{
  description = "Lefthook-compatible markdownlint check";

  nixConfig = {
    extra-substituters = [ "https://pr0d1r2.cachix.org" ];
    extra-trusted-public-keys = [ "pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=" ];
  };

  inputs = {
    nixpkgs-lock.url = "github:pr0d1r2/nixpkgs-lock";
    nixpkgs.follows = "nixpkgs-lock/nixpkgs";

    set-and-setting = {
      url = "github:pr0d1r2/set-and-setting";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-lock.follows = "nixpkgs-lock";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      set-and-setting,
      ...
    }:
    set-and-setting.lib.mkConsumerFlake {
      inherit self nixpkgs set-and-setting;
      fragments = [
        "base"
        "actions"
        "nix"
        "shell"
        "ascii"
        "markdown"
        "yaml"
      ];
      src = ./.;
      extraPackages = pkgs: {
        default = pkgs.writeShellApplication {
          name = "lefthook-markdownlint";
          runtimeInputs = [
            pkgs.markdownlint-cli
            self.packages.${pkgs.stdenv.hostPlatform.system}.is-markdown-agentic
          ];
          text = builtins.readFile ./lefthook-markdownlint.sh;
        };
        is-markdown-agentic = pkgs.writeShellApplication {
          name = "is-markdown-agentic";
          text = builtins.readFile ./is-markdown-agentic.sh;
        };
      };
      extraChecks = pkgs: {
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
        actionlint = pkgs.runCommand "actionlint-check" { nativeBuildInputs = [ pkgs.actionlint ]; } ''
          WORKFLOWS_DIR=${./.}/.github/workflows \
            out=$out \
            bash ${./nix/actionlint-check.sh}
        '';
      };
    };
}
