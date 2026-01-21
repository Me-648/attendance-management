import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel", "icon"]
  static values = { defaultTab: String }
  static classes = [ "active", "inactive" ]

  connect() {
    // 初期タブの表示
    if (this.defaultTabValue) {
      this.showTab(this.defaultTabValue)
    }
  }

  switch(event) {
    event.preventDefault()
    const tabId = event.currentTarget.dataset.tabId
    this.showTab(tabId)
  }

  showTab(tabId) {
    // タブのアクティブ装飾
    this.tabTargets.forEach((tab, index) => {
      const isActive = tab.dataset.tabId === tabId

      // アイコンの表示制御
      // タブとアイコンの並び順が一致していると仮定(indexでアクセス)
      // または tab要素内に icon要素があると仮定して検索する方が堅牢
      // ここでは、tab要素のスコープ内のiconを探す方式で実装
      const icon = tab.querySelector('[data-tabs-target="icon"]')

      // classes APIが定義されていればそれを使用、なければデフォルト
      if (this.hasActiveClass && this.hasInactiveClass) {
        if (isActive) {
          tab.classList.add(...this.activeClasses)
          tab.classList.remove(...this.inactiveClasses)
          if (icon) icon.classList.remove("hidden")
        } else {
          tab.classList.remove(...this.activeClasses)
          tab.classList.add(...this.inactiveClasses)
          if (icon) icon.classList.add("hidden")
        }
      } else {
        // Fallback or legacy styles
        if (isActive) {
          tab.classList.add("border-blue-500", "text-blue-600")
          tab.classList.remove("border-transparent", "text-gray-500", "hover:text-gray-700", "hover:border-gray-300")
        } else {
          tab.classList.remove("border-blue-500", "text-blue-600")
          tab.classList.add("border-transparent", "text-gray-500", "hover:text-gray-700", "hover:border-gray-300")
        }
      }
    })

    // パネルの表示/非表示
    this.panelTargets.forEach(panel => {
      // PC (md以上) では常に表示したいので、hiddenクラスの付け外しはスマホ用クラス (block/hidden) に限定する手もあるが
      // ここでは単純に hidden をトグルし、HTML側で class="hidden md:block" のように
      // "md:block" が "hidden" より優先されることを利用する (CSSの詳細度ではなく順序やImportant依存になるので注意)
      // Tailwindでは `display: block` (md:block) は `display: none` (hidden) を上書きできる
      if (panel.dataset.tabId === tabId) {
        panel.classList.remove("hidden")
      } else {
        panel.classList.add("hidden")
      }
    })
  }
}
