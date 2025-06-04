import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "startDate", "endDate"]

  connect() {
    this.reminderIndex = this.containerTarget.children.length

    // 日付フィールドがある場合、バリデーションを追加
    if (this.hasStartDateTarget && this.hasEndDateTarget) {
      this.startDateTarget.addEventListener('change', this.validateDates.bind(this))
      this.endDateTarget.addEventListener('change', this.validateDates.bind(this))
    }
  }

  addReminder() {
    const template = this.createReminderTemplate()
    this.containerTarget.insertAdjacentHTML('beforeend', template)
    this.reminderIndex++
  }

  removeReminder(event) {
    const reminderField = event.target.closest('.reminder-fields')
    const destroyField = reminderField.querySelector('input[name*="_destroy"]')

    if (destroyField) {
      destroyField.value = '1'
      reminderField.style.display = 'none'
    } else {
      reminderField.remove()
    }
  }

  validateDates() {
    const startDate = new Date(this.startDateTarget.value)
    const endDate = new Date(this.endDateTarget.value)

    // エラーメッセージをクリア
    this.clearDateErrors()

    if (startDate && endDate && endDate < startDate) {
      this.showDateError('終了日は開始日以降の日付を選択してください')
      this.endDateTarget.setCustomValidity('終了日は開始日以降の日付を選択してください')
    } else {
      this.endDateTarget.setCustomValidity('')
    }
  }

  showDateError(message) {
    // 既存のエラーメッセージを削除
    this.clearDateErrors()

    // エラーメッセージを表示
    const errorDiv = document.createElement('div')
    errorDiv.className = 'text-danger mt-1 date-validation-error'
    errorDiv.textContent = message
    this.endDateTarget.parentNode.appendChild(errorDiv)

    // 終了日フィールドにエラークラスを追加
    this.endDateTarget.classList.add('is-invalid')
  }

  clearDateErrors() {
    // エラーメッセージを削除
    const errorMessages = document.querySelectorAll('.date-validation-error')
    errorMessages.forEach(error => error.remove())

    // エラークラスを削除
    this.endDateTarget.classList.remove('is-invalid')
  }

  createReminderTemplate() {
    return `
      <div class="reminder-fields card mb-3">
        <div class="card-body">
          <div class="row">
            <div class="col-md-6">
              <label class="form-label">リマインダータイトル</label>
              <input type="text" name="event[reminders_attributes][${this.reminderIndex}][title]" class="form-control">
            </div>
            <div class="col-md-5">
              <label class="form-label">リマインド日時</label>
              <input type="datetime-local" name="event[reminders_attributes][${this.reminderIndex}][remind_at]" class="form-control">
            </div>
            <div class="col-md-1 d-flex align-items-end">
              <button class="btn btn-outline-danger btn-sm remove-reminder" type="button" data-action="click->events-form#removeReminder">削除</button>
            </div>
          </div>
        </div>
      </div>
    `
  }
}
