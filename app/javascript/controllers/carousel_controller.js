import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slide"]
  
  initialize() {
    this.index = 0
    this.slideWidth = 272 // width + gap
  }
  
  next() {
    if (this.index < this.slideTargets.length - 4) {
      this.index++
      this.updatePosition()
    }
  }
  
  previous() {
    if (this.index > 0) {
      this.index--
      this.updatePosition()
    }
  }
  
  updatePosition() {
    this.element.querySelector('div').style.transform = `translateX(-${this.index * this.slideWidth}px)`
  }
}