final: prev: {
  rustywind = final.rustPlatform.buildRustPackage rec {
    pname = "rustywind";
    version = "v0.16.0";

    src = final.fetchFromGitHub {
      owner = "avencera";
      repo = pname;
      rev = version;
      sha256 = "xDpRS8WrFu5uPtbXJGXrxElJinxl1lkpYZ1tGrNrBHA=";
    };

    cargoSha256 = "r9ukb4ZyXbMWFNlrikQE/ELSvDL164W2kwjyxZYbwZA=";
  };

  vimPlugins =
    prev.vimPlugins
    // {
      mini-indentscope-nvim = final.vimUtils.buildVimPluginFrom2Nix {
        pname = "mini.indentscope";
        version = "0.7.0";
        src = final.fetchFromGitHub {
          owner = "echasnovski";
          repo = "mini.indentscope";
          rev = "43f6761c9a3e397b7c12b3c72f678bcf61efcfcf";
          sha256 = "0+bNJUpgZSVk4sHK2WlZlqZ5GMNVAbx1g85NklVuvUg=";
        };
        meta.homepage = "https://github.com/echasnovski/mini.indentscope";
      };
    };
}
