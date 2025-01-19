json.extract! tenant, :id, :name, :subdomain, :status, :settings, :created_at, :updated_at
json.url tenant_url(tenant, format: :json)
