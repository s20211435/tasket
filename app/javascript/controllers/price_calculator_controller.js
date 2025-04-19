import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["formTemplate", "productSelect", "quantityInput", "totalPrice", "itemTotal"]

  connect() {
    this.addChangeListeners()
    this.updateTotalPrice()
  }

  addForm() {
    const template = this.formTemplateTarget.cloneNode(true)
    template.classList.remove("d-none") // 非表示クラスを削除
    this.element.querySelector("#forms-container").appendChild(template)

    // 新しいフォーム内の要素にイベントリスナーを追加
    template.querySelectorAll("select, input").forEach((element) => {
      element.addEventListener("change", () => this.updateItemTotal(element.closest(".form-group")))
    })

    this.updateTotalPrice()
  }

  removeForm(event) {
    event.target.closest(".form-group").remove()
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

    const price = parseFloat(select.value) || 0
    const quantity = parseInt(input.value) || 0
    const total = price * quantity

    itemTotal.textContent = total.toLocaleString()
    this.updateTotalPrice()
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
}
