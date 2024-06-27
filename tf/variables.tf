variable "my_name" {
  type    = string
}

variable "my_email" {
  type    = string
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "domain" {
  type    = string
  default = "netbuildertraining.com"
}

variable "access_key" {
  type = string
  sensitive = true
}

variable "secret_key" {
  type = string
  sensitive = true
}

variable "MACHINE_IDENTITY_CLIENT_ID" {
  type = string
  sensitive = true
}

variable "MACHINE_IDENTITY_CLIENT_SECRET" {
  type = string
  sensitive = true
}

variable "AUTH0_CLIENT_ID" {
  type = string
  sensitive = true
}

variable "AUTH0_CLIENT_SECRET" {
  type = string
  sensitive = true
}

variable "AUTH0_ISSUER_BASE_URL" {
  type = string
  sensitive = true
}
variable "AUTH0_SECRET" {
  type = string
  sensitive = true
}

variable "MONGO_URI" {
  type = string
  sensitive = true
  
}
variable "test" {
  type = string
}
variable "pem_path" {
  type = string
}

variable "AUTH0_BASE_URL" {
  type = string
  sensitive = true
}