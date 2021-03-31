terraform {
  source = "../../../../modules/api/rds"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  name = "bfl_prod"
}
