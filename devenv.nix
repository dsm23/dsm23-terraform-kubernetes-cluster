{
  pkgs,
  ...
}:

{
  # https://devenv.sh/packages/
  packages = with pkgs; [
    k3d
    kubectl
  ];

  # https://devenv.sh/languages/
  languages.opentofu = {
    enable = true;
    lsp.enable = true;
  };

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    commitizen.enable = true;
    nixfmt.enable = true;
    shellcheck.enable = true;
    terraform-format.enable = true;
    terraform-validate.enable = true;
    tflint.enable = true;
    yamllint.enable = true;
    zizmor.enable = true;
  };

  # See full reference at https://devenv.sh/reference/options/
}
