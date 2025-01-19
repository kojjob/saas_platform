class CreateTenants < ActiveRecord::Migration[8.0]
  def change
    create_table :tenants do |t|
      t.string :name
      t.string :subdomain
      t.string :status
      t.jsonb :settings

      t.timestamps
    end
  end
end
