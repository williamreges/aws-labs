locals {
  label                    = "lab-bastion"
  name                     = "bastion"
  namehostpublic           = "bastion-host"
  namehostprivate          = "server-private"
  tag_environment          = "lab"
  name_sg_instance_bastion = "lab-${local.namehostpublic}-sg"
  name_sg_instance_private = "lab-${local.namehostprivate}-sg"
}
