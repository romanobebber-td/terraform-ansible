
resource "libvirt_network" "rede_app" {
  name      = "rede-app"
  mode      = "nat"
  addresses = ["10.10.20.0/24"]
  dhcp {
    enabled = true
  }
  dns {
    enabled = true
  }
}


resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-base.img"
  source = "/var/lib/libvirt/images/ubuntu-base.img"
  format = "qcow2"
}

resource "libvirt_volume" "disco_app" {
  name           = "disco-app.qcow2"
  base_volume_id = libvirt_volume.ubuntu_base.id
  size           = 10737418240 # 10 GB
}

resource "libvirt_volume" "disco_nginx" {
  name           = "disco-nginx.qcow2"
  base_volume_id = libvirt_volume.ubuntu_base.id
  size           = 10737418240
}

resource "libvirt_volume" "disco_db" {
  name           = "disco-db.qcow2"
  base_volume_id = libvirt_volume.ubuntu_base.id
  size           = 10737418240
}

resource "libvirt_cloudinit_disk" "cloudinit" {
  name      = "cloudinit.iso"
  user_data = <<EOF


users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    shell: /bin/bash
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJXLsjmddzqSw46z2x1/yMmlF0iq7KTHmU2ST5FmQZl5 admin_romano@ubunturomano

EOF
}

resource "libvirt_domain" "vm_app" {
  name   = "vm-app"
  memory = "1024"
  vcpu   = 1
  network_interface {
    network_id = libvirt_network.rede_app.id
  }
  disk {
    volume_id = libvirt_volume.disco_app.id
  }
  cloudinit = libvirt_cloudinit_disk.cloudinit.id
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}

resource "libvirt_domain" "vm_nginx" {
  name   = "vm-nginx"
  memory = "512"
  vcpu   = 1
  network_interface {
    network_id = libvirt_network.rede_app.id
  }
  disk {
    volume_id = libvirt_volume.disco_nginx.id
  }
  cloudinit = libvirt_cloudinit_disk.cloudinit.id
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}

resource "libvirt_domain" "vm_db" {
  name   = "vm-db"
  memory = "1024"
  vcpu   = 1
  network_interface {
    network_id = libvirt_network.rede_app.id
  }
  disk {
    volume_id = libvirt_volume.disco_db.id
  }
  cloudinit = libvirt_cloudinit_disk.cloudinit.id
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}
