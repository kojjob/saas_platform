class CleanupTenantsSettings < ActiveRecord::Migration[8.0]
  def up
    Tenant.find_each do |tenant|
      # Ensure settings is a valid hash
      if tenant.settings.is_a?(String)
        begin
          parsed_settings = JSON.parse(tenant.settings)
          tenant.update_columns(settings: parsed_settings)
        rescue JSON::ParserError
          # Handle invalid JSON
          tenant.update_columns(settings: {})
        end
      end
    end
  end
end
