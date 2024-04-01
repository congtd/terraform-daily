output "load_balancing_endpoint" {
  value = module.load_balancing.lb_endpoint
}

output "database_endpoint" {
  value = module.database.db_endpoint
}