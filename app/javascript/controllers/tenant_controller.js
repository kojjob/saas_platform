import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    // Close menu when clicking outside
    document.addEventListener('click', this.handleClickOutside.bind(this))
  }

  disconnect() {
    document.removeEventListener('click', this.handleClickOutside.bind(this))
  }

  toggleMenu(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle('hidden')
  }

  handleClickOutside(event) {
    if (!this.menuTarget.contains(event.target) && !event.target.closest('[data-action="click->tenant#toggleMenu"]')) {
      this.menuTarget.classList.add('hidden')
    }
  }
}