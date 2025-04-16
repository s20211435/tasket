import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // フラッシュメッセージを5秒後に消す
    setTimeout(() => {
      this.element.classList.add('fade-out');
      setTimeout(() => {
        this.element.remove();
      }, 500); // フェードアウト時間
    }, 5000); // 表示時間
  }
}
