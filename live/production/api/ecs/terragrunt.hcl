terraform {
  source = "../../../../modules/api/ecs"
}

include {
  path = find_in_parent_folders()
}