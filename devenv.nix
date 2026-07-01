{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  overlays = [
    (final: prev: {
      opentofu = prev.opentofu.overrideAttrs (oldAttrs: rec {
        version = "1.12.3";

        src = final.fetchFromGitHub {
          owner = "opentofu";
          repo = "opentofu";
          rev = "v${version}";
          hash = "sha256-/Or8+rMsGbZ9aY/oSOqHH0vMFx9Pl0ZRa9KrVJ4X8Ls=";
        };

        proxyVendor = true;
        vendorHash = "sha256-RuRfVoYl0TDcgWlH9udF3X8poQdPJHXeaj9D2k84vao=";
      });

      tflint = prev.tflint.overrideAttrs (oldAttrs: rec {
        version = "0.63.1";

        src = prev.fetchFromGitHub {
          owner = "terraform-linters";
          repo = "tflint";
          rev = "v${version}";
          hash = "sha256-HFzifDEhwr9C/A8xNMyF7k3qbKkpBLLJWXpcIbvTo6Y=";
        };

        nativeBuildInputs = [
          final.go_1_26
        ]
        ++ (builtins.filter (p: (p.pname or "") != "go") oldAttrs.nativeBuildInputs);

        proxyVendor = true;
        vendorHash = "sha256-CQcL0aFulURIBWb6P3ZDNv/cUu82rinf3uhf66Sxr3E=";
      });

      yamllint = prev.yamllint.overrideAttrs (oldAttrs: rec {
        version = "1.38.0";
        src = final.fetchFromGitHub {
          owner = "adrienverge";
          repo = "yamllint";
          rev = "v${version}";
          hash = "sha256-4H8tbn2TRzTGIXmP9Hnmc93rGSLsWh5A5R9KAIz0mKM=";
        };
      });
    })
  ];

  # https://devenv.sh/packages/
  packages = with pkgs; [
    git
    trivy
  ];

  # https://devenv.sh/languages/
  languages.opentofu = {
    enable = true;
    lsp.enable = true;
  };

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    nixfmt.enable = true;
    shellcheck.enable = true;
    terraform-format.enable = true;
    tflint.enable = true;
    yamllint.enable = true;

    trivy-scan = {
      enable = true;

      name = "Trivy Security Scan";
      entry = "${pkgs.trivy}/bin/trivy config .";
      files = "\\.tf$";
    };
  };

  # See full reference at https://devenv.sh/reference/options/
}
