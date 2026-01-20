import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { defaultTab: String }

  connect() {
    // 初期タブの表示
    // スマホ画面のみタブ機能が必要だが、ロジック自体は単純に動作させておく
    // CSS (md:block) でPC側の強制表示を行う前提
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
    this.tabTargets.forEach(tab => {
      if (tab.dataset.tabId === tabId) {
        tab.classList.add("border-blue-500", "text-blue-600")
        tab.classList.remove("border-transparent", "text-gray-500", "hover:text-gray-700", "hover:border-gray-300")
      } else {
        tab.classList.remove("border-blue-500", "text-blue-600")
        tab.classList.add("border-transparent", "text-gray-500", "hover:text-gray-700", "hover:border-gray-300")
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
