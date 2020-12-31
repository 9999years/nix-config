{ webapp }:

webapp {
  name = "notion";
  url = "https://notion.so/";
  desktopItem = {
    desktopName = "Notion";
    comment =
      "The all-in-one workspace for your notes, tasks, wikis, and databases.";
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
      size = "64x64";
      src = ./icon-64x64.png;
    }
  ];
}
