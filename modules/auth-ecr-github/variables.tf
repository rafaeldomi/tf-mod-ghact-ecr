variable "role_name" {
    type = string
}

variable "allow_repo" {
    type = list(string)
}

variable "permissions" {
  description = "Define custom permissions"
  type = map(object({
    effect    = string
    resources = list(string)
    actions   = list(string)
  }))
  default = {}
}
