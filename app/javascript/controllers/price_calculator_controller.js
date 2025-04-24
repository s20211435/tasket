import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["formTemplate", "productSelect", "quantityInput", "totalPrice", "itemTotal", "searchInput", "categoryFilter", "productList"]

  connect() {
    this.addChangeListeners()
    this.updateTotalPrice()
  }

  addForm() {
    const template = this.formTemplateTarget.cloneNode(true)
    template.classList.remove("d-none") // 非表示クラスを削除
    this.element.querySelector("#forms-container").appendChild(template)

    // 新しいフォーム内の要素にイベントリスナーを追加
    const quantityInput = template.querySelector("[data-price-calculator-target='quantityInput']")
    quantityInput.addEventListener("change", () => this.updateItemTotal(template))

    // 合計金額を再計算
    this.updateTotalPrice()
  }

  removeForm(event) {
    const formGroup = event.target.closest(".form-group")
    const formsContainer = this.element.querySelector("#forms-container")

    // 一番上のフォームは削除できないようにする
    if (formsContainer.firstElementChild === formGroup) {
      alert("一番上のフォームは削除できません。")
      return
    }

    formGroup.remove()
    this.updateTotalPrice()
  }

  resetForms() {
    const formsContainer = this.element.querySelector("#forms-container")
    const firstForm = formsContainer.firstElementChild

    // 最初のフォーム以外を削除
    while (formsContainer.children.length > 1) {
      formsContainer.lastElementChild.remove()
    }

    // 最初のフォームを初期化
    firstForm.querySelector("[data-price-calculator-target='productSelect']").value = ""
    firstForm.querySelector("[data-price-calculator-target='quantityInput']").value = "1"
    firstForm.querySelector("[data-price-calculator-target='itemTotal']").textContent = "0"

    // 合計金額をリセット
    this.totalPriceTarget.textContent = "0"
  }

  updateItemTotal(formGroup) {
    const select = formGroup.querySelector("[data-price-calculator-target='productSelect']")
    const input = formGroup.querySelector("[data-price-calculator-target='quantityInput']")
    const itemTotal = formGroup.querySelector("[data-price-calculator-target='itemTotal']")

    // 商品の価格を取得
    const price = parseFloat(select.value) || 0
    const quantity = parseInt(input.value, 10) || 0
    const total = price * quantity

    // 小計を更新
    itemTotal.textContent = total.toLocaleString()
    // 合計金額を更新
    this.updateTotalPrice()

    // 在庫やカテゴリ情報を取得
    const stockInfo = formGroup.querySelector("[data-stock-info]")
    const categoryInfo = formGroup.querySelector("[data-category-info]")

    const selectedOption = select.options[select.selectedIndex]
    const stock = selectedOption?.getAttribute("data-stock") || "不明"
    const category = selectedOption?.getAttribute("data-category") || "不明"

    if (stockInfo) stockInfo.textContent = stock
    if (categoryInfo) categoryInfo.textContent = category

  }

  updateTotalPrice() {
    let total = 0
    this.element.querySelectorAll("[data-price-calculator-target='itemTotal']").forEach((itemTotal) => {
      total += parseFloat(itemTotal.textContent.replace(/,/g, "")) || 0
    })
    this.totalPriceTarget.textContent = total.toLocaleString()
  }

  addChangeListeners() {
    // 既存のフォーム内の要素にイベントリスナーを追加
    this.productSelectTargets.forEach((select) => {
      select.addEventListener("change", (event) => this.updateItemTotal(event.target.closest(".form-group")))
    })
    this.quantityInputTargets.forEach((input) => {
      input.addEventListener("change", (event) => this.updateItemTotal(event.target.closest(".form-group")))
    })
  }

  openProductModal(event) {
    this.currentFormGroup = event.target.closest(".form-group")
    const modal = new bootstrap.Modal(document.getElementById("productModal"))
    modal.show()
  }

  selectProduct(event) {
    const button = event.target
    const productPrice = button.getAttribute("data-product-price")
    const productStock = button.getAttribute("data-product-stock")
    const productCategory = button.getAttribute("data-product-category")

    // 現在のフォームに選択した商品情報を反映
    const productSelect = this.currentFormGroup.querySelector("[data-price-calculator-target='productSelect']")
    const stockInfo = this.currentFormGroup.querySelector("[data-stock-info]")
    const categoryInfo = this.currentFormGroup.querySelector("[data-category-info]")
    const quantityInput = this.currentFormGroup.querySelector("[data-price-calculator-target='quantityInput']")

    productSelect.value = productPrice
    stockInfo.textContent = productStock
    categoryInfo.textContent = productCategory

    // モーダルを閉じる
    const modal = bootstrap.Modal.getInstance(document.getElementById("productModal"))
    modal.hide()

    // 小計を更新
    this.updateItemTotal(this.currentFormGroup)

    // フォーム内の数量変更時に再計算するイベントリスナーを追加
    quantityInput.addEventListener("change", () => this.updateItemTotal(this.currentFormGroup))

    // 合計金額を再計算
    this.updateTotalPrice()
  }

  filterProducts() {
    const searchQuery = this.searchInputTarget.value.toLowerCase()
    const selectedCategory = this.categoryFilterTarget.value

    this.productListTarget.querySelectorAll("tr").forEach((row) => {
      const productName = row.getAttribute("data-name").toLowerCase()
      const productCategory = row.getAttribute("data-category")

      const matchesSearch = productName.includes(searchQuery)
      const matchesCategory = !selectedCategory || productCategory === selectedCategory

      if (matchesSearch && matchesCategory) {
        row.style.display = ""
      } else {
        row.style.display = "none"
      }
    })
  }
}
