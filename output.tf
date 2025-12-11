output "vm-jumpbox-private-key" {
  value     = tls_private_key.tls.private_key_openssh
  sensitive = true
}

output "vm-jumpbox-public-key" {
  value     = tls_private_key.tls.public_key_openssh
  sensitive = false
}