import { Controller } from "@hotwired/stimulus"

/**
 * Manages individual form field validation and UI feedback
 * Supports various validation types and real-time feedback
 */
export default class extends Controller {
  static targets = ["input", "errorMessage", "successIcon", "errorIcon"]
  
  static values = {
    type: String,
    required: Boolean,
    minLength: Number,
    pattern: String
  }

  static classes = ["error", "success"]

  connect() {
    // Set up initial validation state
    this.valid = true
    this.errorMessage = ""
    
    // Initialize validator based on field type
    this.setupValidator()
  }

  /**
   * Configures the appropriate validator function based on field type
   */
  setupValidator() {
    switch (this.typeValue) {
      case "text":
        this.validator = this.validateText.bind(this)
        break
      case "email":
        this.validator = this.validateEmail.bind(this)
        break
      case "subdomain":
        this.validator = this.validateSubdomain.bind(this)
        break
      case "json":
        this.validator = this.validateJSON.bind(this)
        break
      default:
        this.validator = () => true
    }
  }

  /**
   * Validates the field value and updates UI accordingly
   */
  validate() {
    const wasValid = this.valid
    this.valid = this.validator(this.inputTarget.value)
    
    if (this.valid !== wasValid) {
      this.updateUI()
      this.notifyForm()
    }
  }

  /**
   * Updates field UI based on validation state
   * Shows/hides error messages and icons
   */
  updateUI() {
    // Toggle error/success states
    this.element.classList.toggle(this.errorClass, !this.valid)
    this.element.classList.toggle(this.successClass, this.valid)

    // Update icons
    if (this.hasSuccessIconTarget) {
      this.successIconTarget.classList.toggle("hidden", !this.valid)
    }
    if (this.hasErrorIconTarget) {
      this.errorIconTarget.classList.toggle("hidden", this.valid)
    }

    // Update error message
    if (this.hasErrorMessageTarget) {
      this.errorMessageTarget.textContent = this.valid ? "" : this.errorMessage
      this.errorMessageTarget.classList.toggle("hidden", this.valid)
    }
  }

  /**
   * Dispatches validation events to notify the form controller
   */
  notifyForm() {
    const eventName = this.valid ? "form-field:valid" : "form-field:invalid"
    const event = new CustomEvent(eventName, {
      bubbles: true,
      detail: {
        field: this.inputTarget.name,
        message: this.errorMessage
      }
    })
    this.element.dispatchEvent(event)
  }

  // Validation methods for different field types...
}