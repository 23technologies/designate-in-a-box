resource "openstack_compute_keypair_v2" "key" {
  name = var.prefix
}

resource "openstack_compute_instance_v2" "node" {
  name              = var.prefix
  availability_zone = var.availability_zone
  flavor_name       = var.flavor
  key_pair          = openstack_compute_keypair_v2.key.name
  config_drive      = var.enable_config_drive
  image_id          = data.openstack_images_image_v2.image.id

  depends_on = [
    openstack_networking_router_interface_v2.router_interface
  ]

  network { port = openstack_networking_port_v2.port_management.id }

  user_data = <<-EOT
#cloud-config
package_update: true
package_upgrade: true
write_files:
  - content: ${openstack_compute_keypair_v2.key.public_key}
    path: /home/ubuntu/.ssh/id_rsa.pub
    permissions: '0600'
  - content: |
      ${indent(6, openstack_compute_keypair_v2.key.private_key)}
    path: /home/ubuntu/.ssh/id_rsa
    permissions: '0600'
  - content: |
      ${indent(6, file("files/bootstrap.yml"))}
    path: /opt/bootstrap.yml
    permissions: '0644'
  - content: |
      ${indent(6, file("files/cleanup.yml"))}
    path: /opt/cleanup.yml
    permissions: '0644'
  - content: |
      ${indent(6, file("files/cleanup.sh"))}
    path: /root/cleanup.sh
    permissions: '0700'
  - content: |
      ${indent(6, file("files/bootstrap.sh"))}
    path: /root/bootstrap.sh
    permissions: '0700'
  - content: |
      ${indent(6, file("files/deploy-part-1.yml"))}
    path: /opt/deploy-part-1.yml
    permissions: '0644'
  - content: |
      ${indent(6, file("files/deploy-part-2.yml"))}
    path: /opt/deploy-part-2.yml
    permissions: '0644'
  - content: |
      ${indent(6, file("files/deploy-part-3.yml"))}
    path: /opt/deploy-part-3.yml
    permissions: '0644'
  - content: |
      #!/usr/bin/env bash
      sudo -iu dragon ansible-playbook -i designate-in-a-box.23technologies.xyz, /opt/deploy-part-1.yml -e domain=${var.domain} -e endpoint=${var.endpoint}
      sudo -iu dragon ansible-playbook -i designate-in-a-box.23technologies.xyz, /opt/deploy-part-2.yml
      sudo -iu dragon ansible-playbook -i designate-in-a-box.23technologies.xyz, /opt/deploy-part-3.yml \
        -e @/opt/configuration/inventory/host_vars/designate-in-a-box.23technologies.xyz.yml \
        -e @/opt/configuration/environments/manager/configuration.yml \
        -e @/opt/configuration/environments/manager/images.yml \
        -e @/opt/configuration/environments/secrets.yml

      sudo -iu dragon sh -c 'INTERACTIVE=false osism-run custom facts'
      sudo -iu dragon sh -c 'INTERACTIVE=false osism-generic hosts'

      sudo -iu dragon sh -c 'docker-compose -f /opt/manager/docker-compose.yml restart'
      until [[ "$(/usr/bin/docker inspect -f '{{.State.Health.Status}}' manager_ara-server_1)" == "healthy" ]];
      do
          sleep 1;
      done;

      sudo -iu dragon sh -c 'INTERACTIVE=false osism-run custom letsencrypt'
      sudo -iu dragon sh -c 'INTERACTIVE=false osism-run custom dummy'

      sudo -iu dragon sh -c 'INTERACTIVE=false osism-kolla deploy common'
      sudo -iu dragon sh -c 'INTERACTIVE=false osism-kolla deploy haproxy'
      sudo -iu dragon sh -c 'INTERACTIVE=false osism-kolla deploy memcached'
      sudo -iu dragon sh -c 'INTERACTIVE=false osism-kolla deploy redis'
      sudo -iu dragon sh -c 'INTERACTIVE=false osism-kolla deploy mariadb'
      sudo -iu dragon sh -c 'INTERACTIVE=false osism-kolla deploy rabbitmq'

      sudo -iu dragon sh -c 'INTERACTIVE=false osism-kolla deploy keystone'
      sudo -iu dragon sh -c 'INTERACTIVE=false osism-kolla deploy horizon'
      sudo -iu dragon sh -c 'INTERACTIVE=false osism-kolla deploy neutron'
      sudo -iu dragon sh -c 'INTERACTIVE=false osism-kolla deploy designate'

      sudo -iu dragon sh -c 'INTERACTIVE=false osism-run custom iptables'

      sudo -iu dragon sh -c 'INTERACTIVE=false osism-infrastructure openstackclient'
      sudo -iu dragon sh -c 'INTERACTIVE=false osism-run custom create-project'
    path: /root/deploy.sh
    permissions: 0700
runcmd:
  - "/root/bootstrap.sh"
  - "/root/deploy.sh"
  - "/root/cleanup.sh"
final_message: "The system is finally up, after $UPTIME seconds"
power_state:
  mode: reboot
  condition: True
EOT
}
