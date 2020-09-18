{ pkgs }:
with pkgs; [
  awscli2
  helm
  kotlin
  kubernetes
  postgresql_12
  tflint
  yq
  yarn
  openjdk14_headless
  rebecca.gitflow # https://github.com/hatchcredit/gitflow
]
