terraform {
  source = "../../../../modules/web-app/acm"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  domain = "bachelorfantasyleague.app"
}
