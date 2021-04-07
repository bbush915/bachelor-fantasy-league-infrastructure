terraform {
  source = "../../../../modules/api/elb"
}

include {
  path = find_in_parent_folders()
}
