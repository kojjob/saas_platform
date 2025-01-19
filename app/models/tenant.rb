class Tenant < ApplicationRecord
  # Constants
  VALID_TIMEZONES = ActiveSupport::TimeZone.all.map(&:name).freeze

  DEFAULT_SETTINGS = {
    features: {
      api_access: false,
      custom_domain: false,
      advanced_security: false,
      sso_enabled: false,
      audit_logging: false,
      advanced_analytics: false
    },
    limits: {
      user_count: 10,
      storage_gb: 100,
      api_rate_limit: 1000,
      concurrent_users: 50,
      backup_retention_days: 30
    },
    preferences: {
      timezone: "UTC",
      default_language: "en",
      notification_email: nil,
      support_email: nil
    },
    security: {
      password_expiry_days: 90,
      mfa_required: false,
      session_timeout_minutes: 120,
      ip_whitelist: []
    },
    branding: {
      primary_color: nil,
      logo_url: nil,
      favicon_url: nil
    }
  }.freeze

  # Enums
  enum :status, {
    active: "active",
    inactive: "inactive",
    archived: "archived",
    maintenance: "maintenance"
  }, validate: true

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 255 }
  validates :subdomain, presence: true,
            format: { with: /\A[a-z0-9]+(-[a-z0-9]+)*\z/, message: "can only contain lowercase letters, numbers, and hyphens" },
            length: { minimum: 3, maximum: 63 },
            uniqueness: { case_sensitive: false }
  validates :status, presence: true
  validate :settings_must_be_valid_json
  validate :timezone_must_be_valid

  # Callbacks
  before_validation :normalize_subdomain
  before_validation :set_default_settings

  # JSONB Settings Configuration
  attribute :settings, :jsonb, default: -> {
    {
      features: {
        api_access: false,
        custom_domain: false,
        advanced_security: false,
        sso_enabled: false,
        audit_logging: false,
        advanced_analytics: false
      },
      limits: {
        user_count: 10,
        storage_gb: 100,
        api_rate_limit: 1000,
        concurrent_users: 50,
        backup_retention_days: 30
      },
      preferences: {
        timezone: "UTC",
        default_language: "en",
        notification_email: nil,
        support_email: nil
      },
      security: {
        password_expiry_days: 90,
        mfa_required: false,
        session_timeout_minutes: 120,
        ip_whitelist: []
      },
      branding: {
        primary_color: nil,
        logo_url: nil,
        favicon_url: nil
      }
    }
  }

  # Settings Access Methods
  def features
    get_setting(:features)
  end

  def limits
    get_setting(:limits)
  end

  def preferences
    get_setting(:preferences)
  end

  def security_settings
    get_setting(:security)
  end

  def branding
    get_setting(:branding)
  end

  # Feature Checking Methods
  def feature_enabled?(feature_name)
    features.dig(feature_name.to_s) == true || features.dig(feature_name.to_sym) == true
  end

  def feature_available?(feature_name)
    return false if archived? || inactive?
    feature_enabled?(feature_name)
  end

  # Resource Usage Methods
  def reached_limit?(limit_name)
    current_usage = calculate_usage(limit_name)
    limit = limits.dig(limit_name.to_s) || limits.dig(limit_name.to_sym)
    return false if limit.nil?
    current_usage >= limit
  end

  # Safe Settings Access
  def get_setting(*keys, default: nil)
    result = safe_settings.dig(*keys.map(&:to_sym)) || safe_settings.dig(*keys.map(&:to_s))
    result.nil? ? default : result
  end

  def safe_settings
    case settings
    when Hash then settings
    when String
      begin
        JSON.parse(settings)
      rescue JSON::ParserError
        {}
      end
    when NilClass then {}
    else settings.to_h
    end
  end

  # Usage Statistics
  def stats
    {
      "Total Users"  => calculate_users_stat,
      "Storage Used" => calculate_storage_stat,
      "API Calls"    => calculate_api_stat
    }
  end

  # Status Helpers
  def status_description
    case status
    when "active" then "Fully operational"
    when "maintenance" then "Under maintenance"
    when "inactive" then "Temporarily disabled"
    when "archived" then "Permanently archived"
    end
  end

  private

  def set_default_settings
    # Set default settings if none are provided
    self.settings ||= {
      "features" => {
        "user_limit" => 5,
        "storage_limit" => 1024, # 1GB in MB
        "api_access" => false
      },
      "theme" => {
        "primary_color" => "#4F46E5",
        "secondary_color" => "#6366F1"
      },
      "notifications" => {
        "email" => true,
        "slack" => false
      }
    }
  end

  def settings_must_be_valid_json
    return if settings.is_a?(Hash)

    begin
      JSON.parse(settings) if settings.is_a?(String)
    rescue JSON::ParserError
      errors.add(:settings, "must be a valid JSON object")
    end
  end

  def timezone_must_be_valid
    return unless preferences&.dig("timezone")
    unless VALID_TIMEZONES.include?(preferences["timezone"])
      errors.add(:settings, "contains invalid timezone")
    end
  end

  def normalize_subdomain
    return unless subdomain
    self.subdomain = subdomain.to_s.downcase
                             .gsub(/[^a-z0-9-]/, "-")
                             .gsub(/-+/, "-")
                             .gsub(/^-|-$/, "")
  end

  # def set_default_settings
  #   self.settings = self.class.attribute_types['settings'].default.call.deep_merge(settings || {})
  # end

  def calculate_usage(limit_name)
    case limit_name.to_s
    when "user_count" then users.count
    when "storage_gb" then calculate_storage_usage
    when "api_rate_limit" then calculate_api_usage
    else 0
    end
  end

  def calculate_users_stat
    {
      value: 25,
      change: "+12%",
      trend: "up",
      icon: "users"
    }
  end

  def calculate_storage_stat
    used = calculate_storage_usage
    {
      value: "#{used} GB",
      change: "+8%",
      trend: "up",
      icon: "database"
    }
  end

  def calculate_api_stat
    calls = calculate_api_usage
    {
      value: "#{calls}k",
      change: "-3%",
      trend: "down",
      icon: "code"
    }
  end

  def calculate_storage_usage
    # Implement actual storage calculation
    rand(1..100)
  end

  def calculate_api_usage
    # Implement actual API usage calculation
    rand(1..1000)
  end
end
