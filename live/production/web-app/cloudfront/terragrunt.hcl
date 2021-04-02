terraform {
  source = "../../../../modules/web-app/cloudfront"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  domain = "bachelorfantasyleague.app"
}
