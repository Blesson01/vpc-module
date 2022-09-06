data "aws_availability_zones" "az" {
  state = "available"
}

output "azs" {
  value = data.aws_availability_zones.az
} 