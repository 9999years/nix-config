{ webapp }:

webapp {
  name = "workflowy";
  url = "https://workflowy.com/";
  desktopItem = {
    desktopName = "WorkFlowy";
    comment = "A simpler way to organize your work.";
    categories = "Utility;Office";
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
      size = "48x48";
      src = ./icon-48x48.png;
    }
    {
      size = "64x64";
      src = ./icon-64x64.png;
    }
    {
      size = "128x128";
      src = ./icon-128x128.png;
    }
    {
      size = "256x256";
      src = ./icon-256x256.png;
    }
  ];
}
