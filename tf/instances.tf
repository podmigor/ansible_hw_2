resource "tls_private_key" "test" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_secret_manager_secret" "ssh-key" {
  secret_id = "ssh-key"
  replication {
    automatic = true
  }
}
/*
resource "google_secret_manager_secret" "ssh-key1" {
  secret_id = "ssh-key1"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "ssh-key2" {
  secret_id = "ssh-key2"
  replication {
    automatic = true
  }
}
*/
resource "google_compute_address" "static_runner" {
  name       = "vm-runner-public-address"
  project    = var.project
  region     = var.region
  depends_on = [module.network]
}

resource "google_compute_address" "static_web" {
  name       = "vm-web-public-address"
  project    = var.project
  region     = var.region
  depends_on = [module.network]
}

resource "google_compute_address" "static_db" {
  name       = "vm-db-public-address"
  project    = var.project
  region     = var.region
  depends_on = [module.network]
}

resource "google_compute_instance" "ansible-runner" {
  name         = "ansible-runner"
  machine_type = var.instance_type
  tags         = ["internal-ssh", "external-ssh"]
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }
  network_interface {
    network    = var.network_name
    subnetwork = var.subnet_name

    access_config {
      nat_ip = google_compute_address.static_runner.address
    }
  }
  provisioner "remote-exec" {
    connection {
      host        = google_compute_address.static_runner.address
      type        = "ssh"
      user        = var.user
      timeout     = "500s"
      private_key = tls_private_key.test.private_key_openssh
    }
    inline = [
      "sudo apt-get update && sudo apt-get install -y ansible git",
      "sudo chown ${var.user}:${var.user} /tmp/sshkey*",
    "git clone https://github.com/podmigor/ansible_hw_2.git"]
  }
  metadata = {
    ssh-keys = "${var.user}:${file(var.ssh_pub_key)}\n ${var.user}:${tls_private_key.test.public_key_openssh}"
  }
  metadata_startup_script = "ssh-keygen -b 2048 -t rsa -f /tmp/sshkey -q -N \"\" && gcloud secrets versions add ssh-key --data-file=\"/tmp/sshkey.pub\""
  depends_on = [
    module.network, tls_private_key.test
  ]
  service_account {
    scopes = ["cloud-platform"]
  }
}



resource "google_compute_instance" "ansible-web" {
  name         = "ansible-web"
  machine_type = var.instance_type
  tags         = ["internal-ssh", "external-ssh", "web"]
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }
  network_interface {
    network    = var.network_name
    subnetwork = var.subnet_name
    network_ip = "10.10.10.101"

    access_config {
      nat_ip = google_compute_address.static_web.address
    }
  }
  provisioner "remote-exec" {
    connection {
      host        = google_compute_address.static_web.address
      type        = "ssh"
      user        = var.user
      timeout     = "500s"
      private_key = tls_private_key.test.private_key_openssh
    }
    inline = [
      "sudo apt-get update && sudo apt-get install -y git",
      "sudo chown ${var.user}:${var.user} /tmp/sshkey*"]
  }
  metadata = {
    ssh-keys = "${var.user}:${file(var.ssh_pub_key)}\n ${var.user}:${tls_private_key.test.public_key_openssh}"
  }
  metadata_startup_script = "ssh-keygen -b 2048 -t rsa -f /tmp/sshkey -q -N \"\" && gcloud secrets versions add ssh-key --data-file=\"/tmp/sshkey.pub\""
  depends_on = [
    module.network, google_compute_instance.ansible-runner, tls_private_key.test
  ]
  service_account {
    scopes = ["cloud-platform"]
  }
}


resource "google_compute_instance" "ansible-db" {
  name         = "ansible-db"
  machine_type = var.instance_type
  tags         = ["internal-ssh", "external-ssh"]
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }
  network_interface {
    network    = var.network_name
    subnetwork = var.subnet_name
    network_ip = "10.10.10.102"

    access_config {
      nat_ip = google_compute_address.static_db.address
    }
  }
  provisioner "remote-exec" {
    connection {
      host        = google_compute_address.static_db.address
      type        = "ssh"
      user        = var.user
      timeout     = "500s"
      private_key = tls_private_key.test.private_key_openssh
    }
    inline = [
      "sudo apt-get update && sudo apt-get install -y git",
      "sudo chown ${var.user}:${var.user} /tmp/sshkey*"]
  }
  metadata = {
    ssh-keys = "${var.user}:${file(var.ssh_pub_key)}\n ${var.user}:${tls_private_key.test.public_key_openssh}"
  }
  metadata_startup_script = "ssh-keygen -b 2048 -t rsa -f /tmp/sshkey -q -N \"\" && gcloud secrets versions add ssh-key --data-file=\"/tmp/sshkey.pub\""
  depends_on = [
    module.network, google_compute_instance.ansible-runner, tls_private_key.test
  ]
  service_account {
    scopes = ["cloud-platform"]
  }
}

data "google_secret_manager_secret_version" "public_key" {
  secret     = "ssh-key"
  depends_on = [google_compute_instance.ansible-db, google_compute_instance.ansible-web, google_compute_instance.ansible-runner]
}

