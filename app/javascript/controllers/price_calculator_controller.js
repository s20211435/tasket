import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "formTemplate", "productSelect", "quantityInput", "totalPrice", "itemTotal", 
    "searchInput", "categoryCheckboxes", "categoryCheckbox", "productList",
    "minPriceInput", "maxPriceInput", "stockFilter", "sortSelect", 
    "resultCount", "advancedToggle"
  ]

  connect() {
    this.addChangeListeners()
    this.updateTotalPrice()
    this.setupCategoryFilters()
    this.allProducts = this.getAllProducts() // 全商品データを保存
    this.updateResultCount()
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
    const minPrice = parseFloat(this.minPriceInputTarget.value) || 0
    const maxPrice = parseFloat(this.maxPriceInputTarget.value) || Infinity
    const stockFilter = this.stockFilterTarget.value
    
    // 選択されたカテゴリを取得（複数選択対応）
    const selectedCategories = []
    const allCategoryCheckbox = this.categoryCheckboxTargets.find(checkbox => checkbox.dataset.category === 'all')
    
    if (allCategoryCheckbox && allCategoryCheckbox.checked) {
      selectedCategories.push('all')
    } else {
      this.categoryCheckboxTargets.forEach((checkbox) => {
        if (checkbox.checked && checkbox.dataset.category !== 'all') {
          selectedCategories.push(checkbox.dataset.category)
        }
      })
    }

    let visibleCount = 0

    this.productListTarget.querySelectorAll("tr").forEach((row) => {
      const productName = row.getAttribute("data-name").toLowerCase()
      const productDescription = row.getAttribute("data-description").toLowerCase()
      const productCategory = row.getAttribute("data-category")
      const productPrice = parseFloat(row.getAttribute("data-price"))
      const productStock = parseInt(row.getAttribute("data-stock"))

      // テキスト検索（商品名と説明文）
      const matchesSearch = productName.includes(searchQuery) || productDescription.includes(searchQuery)
      
      // 価格範囲フィルタ
      const matchesPrice = productPrice >= minPrice && productPrice <= maxPrice
      
      // 在庫フィルタ
      let matchesStock = true
      switch (stockFilter) {
        case 'in_stock':
          matchesStock = productStock > 0
          break
        case 'low_stock':
          matchesStock = productStock <= 10 && productStock > 0
          break
        case 'out_of_stock':
          matchesStock = productStock === 0
          break
        default:
          matchesStock = true
      }
      
      // カテゴリフィルタリング
      let matchesCategory = false
      if (selectedCategories.includes('all') || selectedCategories.length === 0) {
        matchesCategory = true
      } else {
        matchesCategory = selectedCategories.includes(productCategory)
      }

      if (matchesSearch && matchesCategory && matchesPrice && matchesStock) {
        row.style.display = ""
        visibleCount++
        this.highlightText(row, searchQuery)
      } else {
        row.style.display = "none"
      }
    })

    this.updateResultCount(visibleCount)
  }

  sortProducts() {
    const sortValue = this.sortSelectTarget.value
    const rows = Array.from(this.productListTarget.querySelectorAll("tr"))
    
    rows.sort((a, b) => {
      const aName = a.getAttribute("data-name")
      const bName = b.getAttribute("data-name")
      const aPrice = parseFloat(a.getAttribute("data-price"))
      const bPrice = parseFloat(b.getAttribute("data-price"))
      const aStock = parseInt(a.getAttribute("data-stock"))
      const bStock = parseInt(b.getAttribute("data-stock"))

      switch (sortValue) {
        case 'name_asc':
          return aName.localeCompare(bName)
        case 'name_desc':
          return bName.localeCompare(aName)
        case 'price_asc':
          return aPrice - bPrice
        case 'price_desc':
          return bPrice - aPrice
        case 'stock_asc':
          return aStock - bStock
        case 'stock_desc':
          return bStock - aStock
        default:
          return 0
      }
    })

    // ソート済みの行を再配置
    rows.forEach(row => this.productListTarget.appendChild(row))
  }

  clearFilters() {
    this.searchInputTarget.value = ''
    this.minPriceInputTarget.value = ''
    this.maxPriceInputTarget.value = ''
    this.stockFilterTarget.value = 'all'
    this.sortSelectTarget.value = 'name_asc'
    
    // 全てのカテゴリチェックボックスをクリア
    this.categoryCheckboxTargets.forEach(checkbox => {
      if (checkbox.dataset.category === 'all') {
        checkbox.checked = true
      } else {
        checkbox.checked = false
      }
    })

    this.filterProducts()
  }

  toggleAdvancedSearch() {
    const advancedSearchCollapse = document.getElementById('advancedSearch')
    const toggleButton = this.advancedToggleTarget
    
    if (advancedSearchCollapse.classList.contains('show')) {
      toggleButton.innerHTML = '<i class="fas fa-cog me-1"></i>詳細'
      toggleButton.classList.remove('btn-primary')
      toggleButton.classList.add('btn-outline-primary')
    } else {
      toggleButton.innerHTML = '<i class="fas fa-cog me-1"></i>簡単'
      toggleButton.classList.remove('btn-outline-primary')
      toggleButton.classList.add('btn-primary')
    }
  }

  highlightText(row, searchQuery) {
    if (!searchQuery) return

    const nameElement = row.querySelector('[data-highlight-target="name"]')
    const descriptionElement = row.querySelector('[data-highlight-target="description"]')

    if (nameElement) {
      this.applyHighlight(nameElement, searchQuery)
    }
    if (descriptionElement) {
      this.applyHighlight(descriptionElement, searchQuery)
    }
  }

  applyHighlight(element, searchQuery) {
    const originalText = element.textContent
    const regex = new RegExp(`(${searchQuery})`, 'gi')
    const highlightedText = originalText.replace(regex, '<mark class="bg-warning">$1</mark>')
    element.innerHTML = highlightedText
  }

  formatPrice(price) {
    return `¥${price.toLocaleString()}`
  }

  getAllProducts() {
    return Array.from(this.productListTarget.querySelectorAll("tr")).map(row => ({
      name: row.getAttribute("data-name"),
      category: row.getAttribute("data-category"),
      price: parseFloat(row.getAttribute("data-price")),
      stock: parseInt(row.getAttribute("data-stock")),
      description: row.getAttribute("data-description"),
      element: row
    }))
  }

  updateResultCount(count = null) {
    if (count === null) {
      count = this.productListTarget.querySelectorAll("tr[style='']").length
    }
    this.resultCountTarget.textContent = count
  }

  setupCategoryFilters() {
    // 「全て」チェックボックスの特別な処理
    const allCategoryCheckbox = this.categoryCheckboxTargets.find(checkbox => checkbox.dataset.category === 'all')
    
    if (allCategoryCheckbox) {
      allCategoryCheckbox.addEventListener('change', () => {
        if (allCategoryCheckbox.checked) {
          // 「全て」がチェックされた場合、他のチェックボックスをクリア
          this.categoryCheckboxTargets.forEach(checkbox => {
            if (checkbox.dataset.category !== 'all') {
              checkbox.checked = false
            }
          })
        }
      })
    }

    // 個別カテゴリチェックボックスの処理
    this.categoryCheckboxTargets.forEach(checkbox => {
      if (checkbox.dataset.category !== 'all') {
        checkbox.addEventListener('change', () => {
          if (checkbox.checked && allCategoryCheckbox) {
            // 個別カテゴリがチェックされた場合、「全て」をクリア
            allCategoryCheckbox.checked = false
          }
        })
      }
    })
  }
}
