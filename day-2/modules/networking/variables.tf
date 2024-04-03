variable "vpc_cird" {

}

variable "public_subnet_count" {

}

variable "private_subnet_count" {

}


variable "db_subnet_group" {
  type    = bool
  default = false
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
}
