{ webapp }:

webapp {
  name = "todoist";
  url = "https://todoist.com/app/";
  desktopItem = {
    desktopName = "Todoist";
    comment = "A todo list to organize work and life";
    categories = "Utility;Office";
  };
  icons = [
    {
      size = "32x32";
      src = ./icon-32x32.png;
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
      size = "1024x1024";
      src = ./icon-1024x1024.png;
    }
  ];
}
