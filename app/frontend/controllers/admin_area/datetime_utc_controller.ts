import { Controller } from "@hotwired/stimulus";

/**
 * Reusable datetime UTC input handler
 *
 * Handles:
 * - Display: Converts UTC value to user's local timezone for input display
 * - Submit: Converts local input back to UTC ISO8601 string
 *
 * Usage:
 *   <form data-controller="datetime-utc">
 *     <input type="datetime-local"
 *            data-datetime-utc-target="input"
 *            data-utc="2025-01-15T10:00:00Z"
 *            data-name="delivery[scheduled_at]">
 *   </form>
 *
 * Or with default value (1 hour from now):
 *   <input type="datetime-local"
 *          data-datetime-utc-target="input"
 *          data-name="public_started_at"
 *          data-default="true">
 */
export default class extends Controller {
  static targets = ["input"];

  declare inputTargets: HTMLInputElement[];

  connect() {
    this.inputTargets.forEach((input) => this.setupInput(input));
    // Use submit event to create hidden fields before form submission
    this.element.addEventListener("submit", this.handleSubmit.bind(this));
  }

  private handleSubmit(_e: Event) {
    this.inputTargets.forEach((input) => {
      const name = input.dataset.name;
      if (!name || !input.value) return;

      const localDate = new Date(input.value);
      if (isNaN(localDate.getTime())) return;

      // Check if hidden field already exists
      let hiddenField = this.element.querySelector(
        `input[type="hidden"][name="${name}"]`
      ) as HTMLInputElement | null;

      if (!hiddenField) {
        hiddenField = document.createElement("input");
        hiddenField.type = "hidden";
        hiddenField.name = name;
        this.element.appendChild(hiddenField);
      }

      hiddenField.value = localDate.toISOString();
    });
  }

  private setupInput(input: HTMLInputElement) {
    const utcValue = input.dataset.utc;
    const useDefault = input.dataset.default === "true";

    let date: Date;

    if (utcValue) {
      // Edit mode: use existing UTC value
      date = new Date(utcValue);
    } else if (useDefault) {
      // New mode with default: 1 hour from now
      date = new Date();
      date.setHours(date.getHours() + 1);
      date.setSeconds(0, 0);
    } else {
      // New mode without default: leave empty
      return;
    }

    if (!isNaN(date.getTime())) {
      input.value = this.toDatetimeLocal(date);
    }
  }

  // Format Date to datetime-local input value (YYYY-MM-DDTHH:MM)
  private toDatetimeLocal(date: Date): string {
    const pad = (n: number) => String(n).padStart(2, "0");
    return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}`;
  }
}
