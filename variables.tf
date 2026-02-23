variable "prefix" { default = "tp-mathis" }
variable "location" { default = "France Central" }
variable "vm_size" { default = "Standard_B1s" }
variable "admin_username" { default = "azureuser" }
variable "admin_password" {
  description = "Mot de passe administrateur"
  type        = string
  sensitive   = true  # <--- Cache le mot de passe dans les logs du terminal
}
