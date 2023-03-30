self: super: {
  vimPlugins =
    super.vimPlugins
    // {
      mini-indentscope-nvim = self.vimUtils.buildVimPluginFrom2Nix {
        pname = "mini.indentscope";
        version = "0.7.0";
        src = self.fetchFromGitHub {
          owner = "echasnovski";
          repo = "mini.indentscope";
          rev = "43f6761c9a3e397b7c12b3c72f678bcf61efcfcf";
          sha256 = "0+bNJUpgZSVk4sHK2WlZlqZ5GMNVAbx1g85NklVuvUg=";
        };
        meta.homepage = "https://github.com/echasnovski/mini.indentscope";
      };
    };
}
