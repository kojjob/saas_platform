class AddConstraintsToTenants < ActiveRecord::Migration[8.0]
  def change
    change_column_null :tenants, :name, false
    change_column_null :tenants, :subdomain, false
    add_index :tenants, :subdomain, unique: true

    add_check_constraint :tenants, "status IN ('active', 'inactive', 'archived')",
      name: "status_inclusion"
  end
end
