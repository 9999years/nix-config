self: super: {
  # Only override if we're still at 3.1b
  tmux = if super.tmux.version == "3.1b" then
    super.tmux.overrideAttrs (old: rec {
      version = "3.2-rc";

      src = super.fetchFromGitHub {
        owner = "tmux";
        repo = "tmux";
        rev = version;
        sha256 = "076bn87vddcma95hh6c37155ifrhn8q138m8p8xc5nq9qzkz5cad";
      };
    })
  else
    super.tmux;
}
