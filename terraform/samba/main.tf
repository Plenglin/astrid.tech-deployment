terraform {
  required_version = ">= 0.13.0"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
    proxmox = {
      source = "Telmate/proxmox"
      version = ">= 2.6.7"
    }
  }
}

provider "proxmox" {
  pm_api_url = var.pm_url_root
  pm_user = var.pm_user
  pm_password = var.pm_pass
  pm_tls_insecure = true
}

resource "random_password" "samba_root" {
  length = 24
  special = false
}

resource "local_file" "samba_root" {
  content = random_password.samba_root.result
  filename = "${path.module}/credentials/server_root.txt"
}

resource "proxmox_lxc" "samba" {
  target_node = "thonkpad"
  hostname = "samba"
  description = "ProxmoxResources server"

  vmid = 1000

  pool = "core-pool"
  memory = 512
  swap = 512
  cores = 2

  features {
    fuse    = true
    mount   = "nfs;cifs"
  }

  ostemplate = "local:vztmpl/debian-10-turnkey-fileserver_16.0-1_amd64.tar.gz"
  password = random_password.samba_root.result
  unprivileged = false
  start = true
  onboot = true
  ssh_public_keys = var.ssh_pubkey

  rootfs {
    storage = "local-lvm"
    size = "300G"
  }

  network {
    name = "eth0"
    bridge = "vmbr0"
    ip = "192.168.8.32/24"
    gw = "192.168.8.1"
  }
}

resource "random_password" "samba_smb_root" {
  length = 24
  special = false
}

resource "local_file" "samba_smb_root" {
  content = random_password.samba_smb_root.result
  filename = "${path.module}/credentials/samba_root.txt"
}
