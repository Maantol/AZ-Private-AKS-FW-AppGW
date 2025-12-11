#Create Random Integer: Creates random integer between 1-1000
resource "random_integer" "suffix" {
  min = 1
  max = 1000
}

#Create TLS Private Key: VM and AKS Linux machine
resource "tls_private_key" "tls" {
  algorithm = "RSA"
  rsa_bits  = 4096
}