variable "nas_ip" {
  type = string
}

variable "controlplane_ip" {
  type = list(string)
}

variable "ip_range" {
  type = list(string)
}
