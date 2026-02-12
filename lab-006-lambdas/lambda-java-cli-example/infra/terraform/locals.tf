locals {
  jar_fullpath = abspath("${path.module}/${var.jar_path}")
  label        = "lab-lambda-java"
  environment  = "lab"
}