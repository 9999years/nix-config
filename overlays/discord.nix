self: super: {
  # We only want this to apply on a particular outdated Discord; otherwise,
  # pick a newer one.
  discord = if super.discord.version == "0.0.12" then
    super.discord.overrideAttrs (old: rec {
      version = "0.0.13";
      src = self.fetchurl {
        url =
          "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
        sha256 = "0d5z6cbj9dg3hjw84pyg75f8dwdvi2mqxb9ic8dfqzk064ssiv7y";
      };
    })
  else
    super.discord;
}
