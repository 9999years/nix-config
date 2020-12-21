{ webapp }:

webapp {
  name = "standardnotes";
  url = "https://app.standardnotes.org/";
  desktopItem = {
    desktopName = "Standard Notes";
    comment = "A free, open-source, and completely encrypted notes app.";
    categories = "Utility;Office;TextEditor";
  };
  icons = [
    {
      size = "16x16";
      src = ./icon-16x16.png;
    }
    {
      size = "32x32";
      src = ./icon-32x32.png;
    }
    {
      size = "180x180";
      src = ./icon-180x180.png;
    }
  ];
}
