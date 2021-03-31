terraform {
  source = "../../../../modules/api/ecr"
}

include {
  path = find_in_parent_folders()
}