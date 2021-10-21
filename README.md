# Grant on All

This module enables the same functionality as the Snowflake statement

```sql
GRANT [PRIVILEGE] ON ALL [OBJECT_TYPE_PLURAL] IN SCHEMA [SCHEMA_NAME]
```

to the snowflake-terraform module.

It currently supports tables, views, and stages, but adding other
resource types is straightforward.


## Input Variables

The following input variables can be passed to the module:

- `object_types`: A list of strings of object types; some of `TABLE`,
  `VIEW`, and `STAGE` (case is not important)
- `database_name`: Database name to act on
- `schema_name`: Schema name to act on; must not be `"INFORMATION_SCHEMA"`
- `privilege`: Privilege to grant, e.g. `"SELECT"`
- `roles`: List of roles to grant the privilege to; by default, an empty list
- `shares`: List of shares to grant the privilege to; by default, an empty list

The `snowflake` provider must also be passed to the module; the role associated
with the provider must have `SECURITYADMIN` granted to it.

## Example

Grant `SELECT` privileges on all tables in the SEGMENT.SALESFORCE schema:

```hcl
module "grant_on_all" {
  source = "./grant_on_all"
  object_types = ["TABLE"]
  database_name = "SEGMENT"
  schema_name = "SALESFORCE"
  privilege = "SELECT"
  roles = [snowflake_role.salesforce.name]

  providers = {
    snowflake = snowflake.securityadmin
  }
}
```

