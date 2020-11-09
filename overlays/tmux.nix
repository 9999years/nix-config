self: super: {
  # Only override if we're still at 3.1c
  tmux = if super.tmux.version == "3.1c" then
    super.tmux.overrideAttrs (old: rec {
      version = "3.2-rc";

      src = super.fetchFromGitHub {
        owner = "tmux";
        repo = "tmux";
        rev = version;
        sha256 = "0h4wpdjdspgr3c9i8l6hjyc488dqm60j3vaqzznvxqfjzzf3s7dg";
      };
    })
  else
    super.tmux;
}
