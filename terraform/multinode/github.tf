/**
 * # Github Repository
 *
 * The Terraform configuration needs to update Github Action Variable 
 * This way we can manage secret and inventory automatically
 */
data "github_repository" "repo" {
  full_name = var.repo_name
}
resource "github_repository_environment" "multinode_environment" {
  repository       = data.github_repository.repo.full_name
  environment      = "multinode"
}
resource "github_actions_environment_secret" "inventory" {
  repository       = data.github_repository.repo.name
  environment      = github_repository_environment.multinode_environment.environment
  secret_name      = "inventory"
  plaintext_value  = templatefile(
    "${path.module}/templates/ansible_inventory.tpl",
    { 
      user = "centos"
      prefix = "kayobe"
      compute_hostname = openstack_compute_instance_v2.compute.*.name
      controller_hostname = openstack_compute_instance_v2.controller.*.name
      seed_hostname = openstack_compute_instance_v2.kayobe-seed.name
      seed = openstack_compute_instance_v2.kayobe-seed.access_ip_v4
      computes = openstack_compute_instance_v2.compute.*.access_ip_v4
      controllers = openstack_compute_instance_v2.controller.*.access_ip_v4
      cephOSD_hostname = openstack_compute_instance_v2.Ceph-OSD.*.name
      cephOSDs =  openstack_compute_instance_v2.Ceph-OSD.*.access_ip_v4
    }
  )
}

