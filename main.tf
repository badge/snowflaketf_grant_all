terraform {
  required_providers {
    snowflake = {
      source  = "chanzuckerberg/snowflake"
      version = "~> 0.25.19"
    }
  }

  required_version = ">= 0.14.9"
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
  tables = toset([
    for table in data.snowflake_tables.this.tables :
    table.name
    if contains(local.object_types, "table")
  ])
  views = toset([
    for view in data.snowflake_views.this.views :
    view.name
    if contains(local.object_types, "table")
  ])
  stages = toset([
    for stage in data.snowflake_stages.this.stages :
    stage.name
    if contains(local.object_types, "stage")
  ])
}

resource "snowflake_table_grant" "this" {
  for_each      = local.tables
  database_name = var.database_name
  schema_name   = var.schema_name
  table_name    = each.value

  privilege = var.privilege

  roles  = var.roles
  shares = var.shares

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
  shares = var.shares

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
  shares = var.shares

  depends_on = [
    data.snowflake_stages.this
  ]
}

