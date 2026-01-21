import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.timeout = setTimeout(() => {
      this.close()
    }, 5000)
  }

  close() {
    this.element.classList.add("opacity-0", "translate-x-full")
    setTimeout(() => {
      this.element.remove()
    }, 300) 
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }
}
