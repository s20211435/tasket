import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["productsList"]

  connect() {
    console.log("Product updates controller connected");
    this.setupEventSource();
  }

  disconnect() {
    this.closeEventSource();
  }

  setupEventSource() {
    this.eventSource = new EventSource('/products/updates');

    this.eventSource.addEventListener('product_updated', (event) => {
      console.log('商品が更新されました');
      this.handleProductUpdate(JSON.parse(event.data));
    });

    this.eventSource.addEventListener('product_created', (event) => {
      console.log('新しい商品が作成されました');
      this.handleProductUpdate(JSON.parse(event.data));
    });

    this.eventSource.addEventListener('product_deleted', (event) => {
      console.log('商品が削除されました');
      this.handleProductUpdate(JSON.parse(event.data));
    });

    this.eventSource.onerror = (error) => {
      console.error('イベントストリームでエラーが発生しました:', error);
      this.closeEventSource();

      // 5秒後に再接続を試みる
      setTimeout(() => this.setupEventSource(), 5000);
    };
  }

  closeEventSource() {
    if (this.eventSource) {
      this.eventSource.close();
      this.eventSource = null;
    }
  }

  handleProductUpdate(data) {
    // 変更があったため商品リストを更新
    this.reloadProductsList();
  }

  reloadProductsList() {
    fetch('/products', {
      headers: {
        'Accept': 'text/html',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.text())
    .then(html => {
      const parser = new DOMParser();
      const doc = parser.parseFromString(html, 'text/html');
      const productsList = doc.getElementById('products');

      if (productsList && this.hasProductsListTarget) {
        this.productsListTarget.innerHTML = productsList.innerHTML;
      } else {
        window.location.reload();
      }
    })
    .catch(error => {
      console.error('商品リストの更新中にエラーが発生しました:', error);
      window.location.reload();
    });
  }
}
