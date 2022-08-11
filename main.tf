terraform {
  required_providers {
    snowflake = {
      source = "Snowflake-Labs/snowflake"
      version = "0.36.0"
    }
  }
}

data "snowflake_tables" "this" {
  database = var.database_name
  schema   = var.schema_name
}

data "snowflake_views" "this" {
  database = var.database_name
  schema   = var.schema_name
}

data "snowflake_stages" "this" {
  database = var.database_name
  schema   = var.schema_name
}

locals {
  object_types = [for object_type in var.object_types : lower(object_type)]
  tables = contains(local.object_types, "table") && data.snowflake_tables.this.tables != null ? toset([
    for view in data.snowflake_tables.this.tables :
    view.name
  ]) : toset([])
  views = contains(local.object_types, "view") && data.snowflake_views.this.views != null ? toset([
    for view in data.snowflake_views.this.views :
    view.name
  ]) : toset([])
  stages = contains(local.object_types, "stage") && data.snowflake_stages.this.stages != null ? toset([
    for stage in data.snowflake_stages.this.stages :
    stage.name
  ]) : toset([])
}

resource "snowflake_table_grant" "this" {
  for_each      = local.tables
  database_name = var.database_name
  schema_name   = var.schema_name
  table_name    = each.value

  privilege = var.privilege

  roles  = var.roles

  depends_on = [
    data.snowflake_tables.this
  ]
}

resource "snowflake_view_grant" "this" {
  for_each      = local.views
  database_name = var.database_name
  schema_name   = var.schema_name
  view_name     = each.value

  privilege = var.privilege

  roles  = var.roles

  depends_on = [
    data.snowflake_views.this
  ]
}

resource "snowflake_stage_grant" "this" {
  for_each      = local.stages
  database_name = var.database_name
  schema_name   = var.schema_name
  stage_name    = each.value

  privilege = var.privilege

  roles  = var.roles

  depends_on = [
    data.snowflake_stages.this
  ]
}

