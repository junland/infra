# Get the public IP address of the machine running Terraform.
data "http" "my_ip" {
  url = "https://api.myip.com"

  request_headers = {
    Accept = "application/json"
  }
}
