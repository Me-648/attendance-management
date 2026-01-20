import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "backdrop"]

  connect() {
    // 表示アニメーション
    requestAnimationFrame(() => {
      this.contentTarget.classList.add("modal__content--visible")
    })
  }

  // 即座に透明化（DOMには残す）
  hide(event) {
    this.contentTarget.classList.remove("modal__content--visible")
    this.element.classList.add("opacity-0")
  }

  // DOMを完全に削除
  close(event) {
    if (event) event.preventDefault()
    
    // 既に非表示なら即削除（保存成功時など）
    if (this.element.classList.contains("opacity-0")) {
      this.element.remove()
      return
    }

    // アニメーション用にクラスを操作
    this.hide()

    // 少し待ってから削除（アニメーション完了待ち）
    setTimeout(() => {
      if (this.element) {
        this.element.remove()
      }
    }, 300)
  }

  closeBackground(event) {
    if (event.target === event.currentTarget) {
      this.close(event)
    }
  }
}
