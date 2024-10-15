terraform {
  backend "gcs" {
    bucket  = "quest-node-app"
    prefix  = "terraform/state"
  }
}
