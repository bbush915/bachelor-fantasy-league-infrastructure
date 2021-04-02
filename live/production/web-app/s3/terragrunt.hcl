terraform {
  source = "../../../../modules/web-app/s3"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  bucket = "www.bachelorfantasyleague.app"
}
