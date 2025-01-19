class AddTenantStatusConstraint < ActiveRecord::Migration[8.0]
  def up
    # Remove old constraint
    execute "ALTER TABLE tenants DROP CONSTRAINT IF EXISTS status_inclusion"

    # Add new constraint with maintenance
    execute <<-SQL
      ALTER TABLE tenants#{' '}
      ADD CONSTRAINT status_inclusion#{' '}
      CHECK (status IN ('active', 'inactive', 'archived', 'maintenance'));
    SQL
  end

  def down
    # Revert to previous constraint
    execute "ALTER TABLE tenants DROP CONSTRAINT IF EXISTS status_inclusion"
    execute <<-SQL
      ALTER TABLE tenants#{' '}
      ADD CONSTRAINT status_inclusion#{' '}
      CHECK (status IN ('active', 'inactive', 'archived'));
    SQL
  end
end
