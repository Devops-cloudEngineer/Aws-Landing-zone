output "organizational_units" {
  description = "List of organizational unit names"
  value = [for ou in aws_organizations_organizational_unit.Parent : ou.name]  
}



