variable "cephOSD_count" {
  type    = string
}

variable "repo_name" {
  type = string
  default = "stackhpc/stackhpc-kayobe-config"
}

variable "ssh_private_key" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "seed_vm_name" {
  type    = string
  default = "kayobe-seed"
}

variable "prefix" {
  type    = string
  default = "kayobe"
}

variable "compute_count" {
  type    = string
}

variable "controller_count" {
  type    = string
}

variable "seed_vm_image" {
  type    = string
  default = "CentOS-stream8"
}

variable "multinode_image" {
  type    = string
  default = "CentOS-stream8"
}
variable "multinode_keypair" {
  type = string
}

variable "seed_vm_flavor" {
  type = string
}

variable "multinode_flavor" {
  type = string
  default = "general.v1.tiny"
}

variable "seed_vm_network" {
  type = string
}

variable "seed_vm_subnet" {
  type = string
}

data "openstack_images_image_v2" "image" {
  name        = var.seed_vm_image
  most_recent = true
}

data "openstack_networking_subnet_v2" "network" {
  name = var.seed_vm_subnet
}

resource "openstack_compute_keypair_v2" "keypair" {
  name = var.multinode_keypair
  public_key = file(var.ssh_public_key)
}

resource "openstack_compute_instance_v2" "kayobe-seed" {
  name         = var.seed_vm_name
  flavor_name  = var.seed_vm_flavor
  key_pair     = var.multinode_keypair
  config_drive = true
  user_data    = file("templates/userdata.cfg.tpl")
  network {
    name = var.seed_vm_network
  }

  block_device {
    uuid                  = data.openstack_images_image_v2.image.id
    source_type           = "image"
    volume_size           = 100
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  provisioner "file" {
    source      = "scripts/configure-local-networking.sh"
    destination = "/home/centos/configure-local-networking.sh"

    connection {
      type        = "ssh"
      host        = self.access_ip_v4
      bastion_host = "bastion-sms"
      bastion_user = "gkoper"
      bastion_private_key = file(var.ssh_private_key)
      user        = "centos"
      agent       = true
      private_key = file(var.ssh_private_key)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash /home/centos/configure-local-networking.sh"
    ]

    connection {
      type        = "ssh"
      host        = self.access_ip_v4
      bastion_host = "bastion-sms"
      bastion_user = "gkoper"
      bastion_private_key = file(var.ssh_private_key)
      user        = "centos"
      agent       = true
      private_key = file(var.ssh_private_key)
    }

  }
}
resource "openstack_compute_instance_v2" "compute" {
  name         = format("%s-compute-%02d", var.prefix, count.index +1)
  flavor_name  = var.multinode_flavor
  key_pair     = var.multinode_keypair
  image_name   = var.multinode_image
  config_drive = true
  user_data    = file("templates/userdata.cfg.tpl")
  count        = var.compute_count
  network {
    name = var.seed_vm_network
  }
}
resource "openstack_compute_instance_v2" "controller" {
  name         = format("%s-controller-%02d", var.prefix, count.index +1)
  flavor_name  = var.multinode_flavor
  key_pair     = var.multinode_keypair
  image_name   = var.multinode_image
  config_drive = true
  user_data    = file("templates/userdata.cfg.tpl")
  count        = var.controller_count
  network {
    name = var.seed_vm_network
  }
}

resource "openstack_compute_instance_v2" "Ceph-OSD" {
  name         = format("%s-cephOSD-%02d", var.prefix, count.index +1)
  flavor_name  = var.multinode_flavor
  key_pair     = var.multinode_keypair
  image_name   = var.multinode_image
  config_drive = true
  user_data    = file("templates/userdata.cfg.tpl")
  count        = var.cephOSD_count
  network {
    name = var.seed_vm_network
  }
}