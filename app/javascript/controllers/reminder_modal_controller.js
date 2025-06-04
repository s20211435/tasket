import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]
  static values = { activeReminders: Array }

  connect() {
    console.log("ReminderModal controller connected")
    console.log("Active reminders:", this.activeRemindersValue)
    console.log("Has modal target:", this.hasModalTarget)
    
    // 少し遅延させてBootstrapが読み込まれるのを待つ
    setTimeout(() => {
      if (this.activeRemindersValue && this.activeRemindersValue.length > 0) {
        console.log("Showing modal with reminders:", this.activeRemindersValue.length)
        this.showModal()
      } else {
        console.log("No active reminders to show")
      }
    }, 100)
  }

  showModal() {
    console.log("showModal called")
    if (this.hasModalTarget) {
      console.log("Modal target found, creating Bootstrap modal")
      try {
        const modal = new bootstrap.Modal(this.modalTarget, {
          backdrop: 'static',
          keyboard: false
        })
        modal.show()
        console.log("Modal show() called")
      } catch (error) {
        console.error("Error creating/showing modal:", error)
      }
    } else {
      console.error("Modal target not found")
    }
  }

  dismissReminder(event) {
    const reminderId = event.currentTarget.dataset.reminderId
    console.log("Dismissing reminder:", reminderId)

    fetch(`/home/dismiss_reminder/${reminderId}`, {
      method: 'PATCH',
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
        'Content-Type': 'application/json'
      }
    }).then(response => {
      if (response.ok) {
        const reminderCard = document.querySelector(`[data-reminder-id="${reminderId}"]`)
        if (reminderCard) {
          reminderCard.remove()
        }

        const remainingReminders = document.querySelectorAll('[data-reminder-id]')
        if (remainingReminders.length === 0) {
          const modal = bootstrap.Modal.getInstance(this.modalTarget)
          if (modal) {
            modal.hide()
          }
        }
      }
    }).catch(error => {
      console.error('リマインダーの確認済み処理でエラーが発生しました:', error)
    })
  }
}
