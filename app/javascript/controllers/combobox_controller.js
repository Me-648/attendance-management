import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown", "option"]

  connect() {
    this.hideDropdown()
  }

  show() {
    this.dropdownTarget.style.display = "block"
    this.dropdownTarget.setAttribute("aria-hidden", "false")
  }

  hide(event) {
    // クリックされた要素がこのコントローラーの要素内であれば何もしない
    if (this.element.contains(event.target)) return
    this.hideDropdown()
  }

  hideDropdown() {
    this.dropdownTarget.style.display = "none"
    this.dropdownTarget.setAttribute("aria-hidden", "true")
  }

  select(event) {
    const value = event.currentTarget.dataset.value
    this.inputTarget.value = value
    this.hideDropdown()
    // 値が変更されたことを通知（必要に応じて）
    this.inputTarget.dispatchEvent(new Event('change', { bubbles: true }))
    this.inputTarget.dispatchEvent(new Event('input', { bubbles: true }))
  }
}
