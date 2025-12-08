data "http" "my_ip" {
  url = "https://api.myip.com"

  request_headers = {
    Accept = "application/json"
  }
}
