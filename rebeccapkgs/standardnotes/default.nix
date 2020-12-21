{ webapp }:

let name = "standardnotes";
in webapp {
  url = "https://app.standardnotes.org/";
  desktopItem = {
    inherit name;
    desktopName = "Standard Notes";
    icon = name;
    comment = "A free, open-source, and completely encrypted notes app.";
    categories = "Utility;Office;TextEditor";
  };
  icons = [
    {
      inherit name;
      size = "16x16";
      src = ./icon-16x16.png;
    }
    {
      inherit name;
      size = "32x32";
      src = ./icon-32x32.png;
    }
    {
      inherit name;
      size = "180x180";
      src = ./icon-180x180.png;
    }
  ];
}
