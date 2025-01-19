class EnsureTenantsSettingsFormat < ActiveRecord::Migration[8.0]
  def up
    Tenant.find_each do |tenant|
      # Comprehensive settings conversion
      converted_settings =
        case tenant.settings
        when Hash
          tenant.settings
        when String
          begin
            JSON.parse(tenant.settings)
          rescue JSON::ParserError
            {
              features: {
                api_access: false,
                custom_domain: false,
                advanced_security: false
              },
              limits: {
                user_count: 10,
                storage_gb: 100,
                api_rate_limit: 1000
              },
              timezone: 'UTC'
            }
          end
        when NilClass
          {
            features: {
              api_access: false,
              custom_domain: false,
              advanced_security: false
            }
          }
        else
          tenant.settings.to_h
        end

      # Update with converted settings, bypassing validations
      tenant.update_columns(settings: converted_settings)
    end
  end

  def down
    # Optional: Reverse migration if needed
  end
end
