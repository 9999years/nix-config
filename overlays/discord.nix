self: super: {
  # We only want this to apply on a particular outdated Discord; otherwise,
  # pick a newer one.
  discord = if super.discord.version == "0.0.11" then
    super.discord.overrideAttrs (old: rec {
      version = "0.0.12";
      src = self.fetchurl {
        url =
          "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
        sha256 = "0qrzvc8cp8azb1b2wb5i4jh9smjfw5rxiw08bfqm8p3v74ycvwk8";
      };
    })
  else
    super.discord;
}
