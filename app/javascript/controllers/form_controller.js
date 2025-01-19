import { Controller } from "@hotwired/stimulus"

/**
 * Form Controller handles all interactive behavior for the tenant form
 * including real-time validation, subdomain preview, JSON formatting,
 * and status updates.
 */
export default class extends Controller {
  // Define Stimulus targets for DOM elements we'll interact with
  static targets = [
    "form",
    "subdomainPreview",
    "urlPreview",
    "statusBar",
    "statusIcon", 
    "statusMessage",
    "statusDetail",
    "nameInput",
    "subdomainInput",
    "settingsInput"
  ]

  // Configuration constants
  static values = {
    // Validation rules
    minSubdomainLength: { type: Number, default: 3 },
    maxSubdomainLength: { type: Number, default: 63 },
    subdomainPattern: { type: String, default: "^[a-z0-9][a-z0-9-]*[a-z0-9]$" },
    // Timing configurations
    statusDuration: { type: Number, default: 5000 },
    validationDelay: { type: Number, default: 500 }
  }

  /**
   * Initialize the controller and set up event listeners
   * Called automatically by Stimulus when the controller connects
   */
  connect() {
    this.setupFormValidation()
    this.setupSubdomainPreview()
    this.setupJsonFormatter()
    this.boundHandleInput = this.handleInput.bind(this)
    
    // Initialize debounced functions
    this.debouncedValidateSubdomain = this.debounce(
      this.validateSubdomain.bind(this),
      this.validationDelayValue
    )

    // Set up validation timer references
    this.validationTimers = new Map()
  }

  /**
   * Clean up event listeners when controller disconnects
   */
  disconnect() {
    this.clearAllValidationTimers()
  }

  // Form Validation Methods

  /**
   * Sets up form validation listeners and behaviors
   * @private
   */
  setupFormValidation() {
    this.formTarget.addEventListener("submit", this.handleSubmit.bind(this))
    
    // Add validation listeners to required fields
    this.requiredFields.forEach(field => {
      const input = this.formTarget.querySelector(`[name*="[${field}]"]`)
      if (input) {
        input.addEventListener("blur", () => this.validateField(field))
      }
    })
  }

  /**
   * Handles form submission and prevents if validation fails
   * @param {Event} event - The form submission event
   */
  handleSubmit(event) {
    if (!this.validateForm()) {
      event.preventDefault()
      this.showStatus("error", "Please correct the errors before submitting")
    }
  }

  /**
   * Validates the entire form
   * @returns {boolean} - Whether the form is valid
   */
  validateForm() {
    let isValid = true
    
    // Validate required fields
    this.requiredFields.forEach(field => {
      if (!this.validateField(field)) {
        isValid = false
      }
    })
    
    // Validate JSON if present
    if (this.hasSettingsInputTarget && this.settingsInputTarget.value.trim()) {
      if (!this.validateJson()) {
        isValid = false
      }
    }
    
    return isValid
  }

  /**
   * Validates a specific field
   * @param {string} fieldName - The name of the field to validate
   * @returns {boolean} - Whether the field is valid
   */
  validateField(fieldName) {
    const input = this.formTarget.querySelector(`[name*="[${fieldName}]"]`)
    if (!input) return true

    const value = input.value.trim()
    let isValid = true
    let errorMessage = ""

    switch (fieldName) {
      case "name":
        if (!value) {
          isValid = false
          errorMessage = "Organization name is required"
        } else if (value.length < 2) {
          isValid = false
          errorMessage = "Organization name must be at least 2 characters"
        }
        break

      case "subdomain":
        if (!value) {
          isValid = false
          errorMessage = "Subdomain is required"
        } else if (!this.isValidSubdomain(value)) {
          isValid = false
          errorMessage = "Invalid subdomain format"
        }
        break

      case "status":
        if (!value) {
          isValid = false
          errorMessage = "Status is required"
        }
        break
    }

    this.updateFieldValidationState(input, isValid, errorMessage)
    return isValid
  }

  // Subdomain Handling Methods

  /**
   * Sets up real-time subdomain preview and validation
   * @private
   */
  setupSubdomainPreview() {
    if (this.hasSubdomainInputTarget) {
      this.subdomainInputTarget.addEventListener("input", this.boundHandleInput)
    }
  }

  /**
   * Handles subdomain input changes
   * @param {Event} event - The input event
   */
  handleInput(event) {
    const value = this.sanitizeSubdomain(event.target.value)
    
    // Update preview
    if (this.hasSubdomainPreviewTarget) {
      this.subdomainPreviewTarget.textContent = value || "your-subdomain"
    }
    
    // Trigger validation
    this.debouncedValidateSubdomain(value)
  }

  /**
   * Validates the subdomain format and availability
   * @param {string} subdomain - The subdomain to validate
   * @private
   */
  async validateSubdomain(subdomain) {
    if (!subdomain) return

    this.showStatus("validating", `Checking availability of "${subdomain}"...`)

    try {
      // Simulate API call - replace with actual endpoint
      const response = await this.checkSubdomainAvailability(subdomain)
      
      if (response.available) {
        this.showStatus("success", "Subdomain is available")
      } else {
        this.showStatus("error", "Subdomain is not available", response.message)
      }
    } catch (error) {
      this.showStatus("error", "Error checking subdomain", error.message)
    }
  }

  // JSON Handling Methods

  /**
   * Sets up JSON formatting capabilities
   * @private
   */
  setupJsonFormatter() {
    if (this.hasSettingsInputTarget) {
      this.settingsInputTarget.addEventListener("blur", () => this.formatJson())
    }
  }

  /**
   * Formats and validates JSON input
   * @returns {boolean} - Whether the JSON is valid
   */
  formatJson() {
    if (!this.hasSettingsInputTarget) return true
    
    const input = this.settingsInputTarget
    const value = input.value.trim()
    
    if (!value) return true

    try {
      const formatted = JSON.stringify(JSON.parse(value), null, 2)
      input.value = formatted
      this.showStatus("success", "JSON formatted successfully")
      return true
    } catch (error) {
      this.showStatus("error", "Invalid JSON format", error.message)
      return false
    }
  }

  // UI Feedback Methods

  /**
   * Shows status message in the status bar
   * @param {string} type - The type of status (success, error, validating)
   * @param {string} message - The main status message
   * @param {string} detail - Optional detailed message
   */
  showStatus(type, message, detail = "") {
    if (!this.hasStatusBarTarget) return

    // Remove existing hide timer
    if (this.statusTimer) {
      clearTimeout(this.statusTimer)
    }

    this.statusBarTarget.classList.remove("translate-y-full")
    
    if (this.hasStatusIconTarget) {
      this.statusIconTarget.innerHTML = this.getStatusIcon(type)
    }
    
    if (this.hasStatusMessageTarget) {
      this.statusMessageTarget.textContent = message
    }
    
    if (this.hasStatusDetailTarget) {
      this.statusDetailTarget.textContent = detail
    }

    // Auto-hide success messages
    if (type === "success") {
      this.statusTimer = setTimeout(() => {
        this.dismissStatus()
      }, this.statusDurationValue)
    }
  }

  /**
   * Dismisses the status bar
   */
  dismissStatus() {
    if (this.hasStatusBarTarget) {
      this.statusBarTarget.classList.add("translate-y-full")
    }
  }

  // Helper Methods

  /**
   * Returns HTML for status icons
   * @param {string} type - The type of status
   * @returns {string} - HTML string for the icon
   * @private
   */
  getStatusIcon(type) {
    const icons = {
      success: `<svg class="h-6 w-6 text-green-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                        d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                </svg>`,
      error: `<svg class="h-6 w-6 text-red-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                      d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
              </svg>`,
      validating: `<svg class="h-6 w-6 text-blue-400 animate-spin" fill="none" viewBox="0 0 24 24">
                     <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
                     <path class="opacity-75" fill="currentColor" 
                           d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"/>
                   </svg>`
    }
    return icons[type] || ""
  }

  /**
   * Creates a debounced version of a function
   * @param {Function} func - The function to debounce
   * @param {number} wait - The debounce delay in milliseconds
   * @returns {Function} - The debounced function
   * @private
   */
  debounce(func, wait) {
    let timeout
    return (...args) => {
      clearTimeout(timeout)
      timeout = setTimeout(() => func.apply(this, args), wait)
    }
  }

  /**
   * Sanitizes subdomain input
   * @param {string} value - The input value to sanitize
   * @returns {string} - The sanitized value
   * @private
   */
  sanitizeSubdomain(value) {
    return value.toLowerCase()
      .replace(/[^a-z0-9-]/g, "-")
      .replace(/-+/g, "-")
      .replace(/^-|-$/g, "")
  }

  /**
   * Validates subdomain format
   * @param {string} subdomain - The subdomain to validate
   * @returns {boolean} - Whether the subdomain is valid
   * @private
   */
  isValidSubdomain(subdomain) {
    return subdomain.length >= this.minSubdomainLengthValue &&
           subdomain.length <= this.maxSubdomainLengthValue &&
           new RegExp(this.subdomainPatternValue).test(subdomain)
  }

  /**
   * Simulates checking subdomain availability
   * @param {string} subdomain - The subdomain to check
   * @returns {Promise<Object>} - The availability response
   * @private
   */
  async checkSubdomainAvailability(subdomain) {
    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    // This should be replaced with actual API call
    return {
      available: this.isValidSubdomain(subdomain),
      message: this.isValidSubdomain(subdomain) ? 
        "Subdomain is available" : 
        "Invalid subdomain format"
    }
  }

  /**
   * Updates validation state of a field
   * @param {HTMLElement} input - The input element
   * @param {boolean} isValid - Whether the field is valid
   * @param {string} errorMessage - The error message if invalid
   * @private
   */
  updateFieldValidationState(input, isValid, errorMessage) {
    const wrapper = input.closest(".field-wrapper")
    if (!wrapper) return

    // Remove existing error message
    const existingError = wrapper.querySelector(".error-message")
    if (existingError) {
      existingError.remove()
    }

    // Update input styles
    input.classList.toggle("border-red-300", !isValid)
    input.classList.toggle("focus:ring-red-500", !isValid)
    input.classList.toggle("focus:border-red-500", !isValid)

    // Add new error message if invalid
    if (!isValid) {
      const errorElement = document.createElement("p")
      errorElement.className = "mt-2 text-sm text-red-600 error-message"
      errorElement.textContent = errorMessage
      wrapper.appendChild(errorElement)
    }
  }

  /**
   * Clears all validation timers
   * @private
   */
  clearAllValidationTimers() {
    this.validationTimers.forEach(timer => clearTimeout(timer))
    this.validationTimers.clear()
  }

  // Getters

  /**
   * Gets list of required field names
   * @returns {string[]} - Array of required field names
   * @private
   */
  get requiredFields() {
    return ["name", "subdomain", "status"]
  }
}