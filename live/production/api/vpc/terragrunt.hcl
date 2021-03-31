terraform {
  source = "../../../../modules/api/vpc"
}

include {
  path = find_in_parent_folders()
}
