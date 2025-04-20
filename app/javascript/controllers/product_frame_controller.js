import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["productsList"]
  static values = {
    checkInterval: { type: Number, default: 10000 }, // ポーリング間隔（ミリ秒）
    lastUpdate: String
  }

  connect() {
    console.log("Product frame controller connected");
    this.setupFormObserver();
    this.startPolling();
  }

  disconnect() {
    this.stopPolling();
  }

  setupFormObserver() {
    // フレームが空になったときの監視（既存の機能を保持）
    const observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        if (mutation.target.innerHTML.includes('Content missing')) {
          // 空になったら商品作成フォームを再読み込み
          fetch('/products/new', {
            headers: {
              Accept: 'text/html'
            }
          })
          .then(response => response.text())
          .then(html => {
            document.getElementById('product_form').innerHTML = html;
          });
        }
      });
    });

    // product_formを監視
    const form = document.getElementById('product_form');
    if (form) {
      observer.observe(form, { childList: true, subtree: true });
    }
  }

  showNewForm(event) {
    event.preventDefault();
    const url = event.currentTarget.getAttribute('href');

    fetch(url, {
      headers: {
        'Accept': 'text/html'
      }
    })
    .then(response => response.text())
    .then(html => {
      document.getElementById('product_form').innerHTML = html;
      this.setupFormSubmit();
    })
    .catch(error => console.error('商品フォームの取得中にエラーが発生しました:', error));
  }

  showEditForm(event) {
    event.preventDefault();
    const url = event.currentTarget.getAttribute('href');

    fetch(url, {
      headers: {
        'Accept': 'text/html'
      }
    })
    .then(response => response.text())
    .then(html => {
      document.getElementById('product_form').innerHTML = html;
      this.setupFormSubmit();
    })
    .catch(error => console.error('商品編集フォームの取得中にエラーが発生しました:', error));
  }

  deleteProduct(event) {
    event.preventDefault();

    if (!confirm(event.currentTarget.dataset.confirm)) {
      return;
    }

    const url = event.currentTarget.getAttribute('href');

    fetch(url, {
      method: 'DELETE',
      headers: {
        'Accept': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        // 新しいメソッドでフラッシュメッセージを表示
        this.showFlashMessage('success', data.message || '商品が削除されました');

        // 対象の要素を削除
        const productId = url.split('/').pop();
        const productElement = document.getElementById(`product_${productId}`);
        if (productElement) {
          productElement.remove();
        }
      }
    })
    .catch(error => {
      console.error('商品削除中にエラーが発生しました:', error);
      this.showFlashMessage('danger', 'エラーが発生しました');
    });
  }

  setupFormSubmit() {
    const form = document.querySelector('#product_form form');
    if (form) {
      form.addEventListener('submit', this.handleFormSubmit.bind(this));
    }
  }

  handleFormSubmit(event) {
    event.preventDefault();
    const form = event.currentTarget;
    const formData = new FormData(form);
    const url = form.getAttribute('action');
    const method = form.getAttribute('method') || 'POST';

    fetch(url, {
      method: method,
      body: formData,
      headers: {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        // フラッシュメッセージの表示
        this.showFlashMessage('success', data.message || '処理が完了しました');

        // 商品一覧を更新
        this.reloadProductsList();

        // フォームをリセット（新規作成の場合）
        if (method.toUpperCase() === 'POST') {
          form.reset();
        } else {
          // 編集の場合はフォームを閉じる
          document.getElementById('product_form').innerHTML = '';
        }
      } else {
        // エラーの表示
        this.showFormErrors(data.errors);
      }
    })
    .catch(error => {
      console.error('フォーム送信中にエラーが発生しました:', error);
    });
  }

  showFormErrors(errors) {
    // エラーメッセージの表示
    const form = document.querySelector('#product_form form');
    if (form && errors) {
      // 既存のエラーメッセージをクリア
      form.querySelectorAll('.error-message').forEach(el => el.remove());

      Object.entries(errors).forEach(([field, messages]) => {
        const input = form.querySelector(`[name="product[${field}]"]`);
        if (input) {
          const errorDiv = document.createElement('div');
          errorDiv.className = 'error-message text-danger';
          errorDiv.textContent = messages.join(', ');
          input.parentNode.insertBefore(errorDiv, input.nextSibling);
        }
      });
    }
  }

  startPolling() {
    // 初期状態を保存
    this.lastUpdateValue = new Date().toISOString();

    // ポーリングを開始
    this.pollingInterval = setInterval(() => {
      this.checkForUpdates();
    }, this.checkIntervalValue);
  }

  stopPolling() {
    if (this.pollingInterval) {
      clearInterval(this.pollingInterval);
    }
  }

  checkForUpdates() {
    fetch('/products?format=json', {
      headers: {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.json())
    .then(data => {
      // 最終更新時刻をチェックして変更があればリロード
      if (data.last_update && data.last_update !== this.lastUpdateValue) {
        console.log('商品データに変更があったため更新します');
        this.lastUpdateValue = data.last_update;
        this.reloadProductsList();
      }
    })
    .catch(error => console.error('商品データの確認中にエラーが発生しました:', error));
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
      // DOMParserを使用してHTML文字列から要素を抽出
      const parser = new DOMParser();
      const doc = parser.parseFromString(html, 'text/html');
      const productsList = doc.getElementById('products');

      if (productsList && this.hasProductsListTarget) {
        this.productsListTarget.innerHTML = productsList.innerHTML;
      } else {
        // products要素が見つからない場合はページ全体をリロード
        window.location.reload();
      }
    })
    .catch(error => {
      console.error('商品リストの更新中にエラーが発生しました:', error);
      window.location.reload();
    });
  }

  showDetails(event) {
    event.preventDefault();
    const url = event.currentTarget.getAttribute('href');

    window.location.href = url; // 通常の詳細ページへの遷移
    // または、モーダルで表示する場合:
    /*
    fetch(url, {
      headers: {
        'Accept': 'text/html',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.text())
    .then(html => {
      // モーダル表示用のコード
      const modalContent = document.createElement('div');
      modalContent.innerHTML = html;
      // モーダルを表示するコード
    })
    .catch(error => console.error('商品詳細の取得中にエラーが発生しました:', error));
    */
  }

  cancelForm(event) {
    event.preventDefault();
    // フォームをクリア
    document.getElementById('product_form').innerHTML = '';
  }

  // 既存のメソッドの代わりに使用する共通のフラッシュメッセージ表示メソッド
  showFlashMessage(type, message, duration = 5000) {
    const flashContainer = document.getElementById('flash_messages');

    // フラッシュメッセージ要素を作成
    const flashMessage = document.createElement('div');
    flashMessage.className = `alert alert-${type}`;
    flashMessage.textContent = message;

    // フラッシュコンテナに追加
    flashContainer.prepend(flashMessage);

    // 指定時間後にメッセージを削除
    setTimeout(() => {
      flashMessage.style.transition = 'opacity 0.5s ease';
      flashMessage.style.opacity = '0';

      // フェードアウト後に要素を削除
      setTimeout(() => {
        if (flashMessage && flashMessage.parentNode) {
          flashMessage.parentNode.removeChild(flashMessage);
        }
      }, 500);
    }, duration);
  }
}
