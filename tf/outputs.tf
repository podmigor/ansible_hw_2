output "ansible-runner-ip-runner" {
  value = google_compute_address.static_runner.address
}

output "ansible-worker-ip-web" {
  value = google_compute_address.static_web.address
}

output "ansible-worker-ip-db" {
  value = google_compute_address.static_db.address
}