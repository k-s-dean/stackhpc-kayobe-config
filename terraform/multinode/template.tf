resource "local_file" "ansible_inventory" {
  content = templatefile(
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
  filename = "ansible_inventory" 
}


