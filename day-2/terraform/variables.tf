variable "region" {
  type = string
  default = "ap-northeast-1"
}

variable "principal_arns" {
  description = "A list of principal arns allowed to assume the IAM role"
  default     = null
  type        = list(string)
}