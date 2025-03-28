variable "name" {}
variable "description" {}
variable "scope" {} # CLOUDFRONT or REGIONAL
variable "metric_name" {}
variable "tags" {
  type = map(string)
}
