variable "cluster_endpoint" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "nodes" {
  type = list(object({
    name     = string
    endpoint = string
    role     = string
  }))
}
