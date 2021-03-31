terraform {
  source = "../../../../modules/api/bastion-host"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  ssh_key = "bfl-ssh"
}
