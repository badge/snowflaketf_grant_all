variable "object_types" {
  description = "Object types to grant privileges on"
  type = list(string)
  default = ["TABLE"]

  validation {
    condition = alltrue([
      for object_type in var.object_types : contains(["TABLE", "VIEW", "STAGE"], upper(object_type))
    ])
    error_message = "Object types must be either TABLE or VIEW."
  }
}

variable "database_name" {
  description = "Database name"
  type = string
}

variable "schema_name" {
  description = "Schema name"
  type = string

  validation {
    condition = var.schema_name != "INFORMATION_SCHEMA"
    error_message = "Cannot grant privileges on INFORMATION_SCHEMA schema!"
  }
}

variable "privilege" {
  description = "Privilege to grant on the objects"
  type = string
}

variable "roles" {
  description = "Snowflake roles"
  type = list(string)
  default = []
}

variable "shares" {
  description = "Snowflake shares"
  type = list(string)
  default = []
}

