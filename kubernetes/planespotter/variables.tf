variable "rtlsdr_adsb_serial" {
  type = string
}

variable "vault_backend" {
  type = object({
    name = string
    kind = string
  })
}