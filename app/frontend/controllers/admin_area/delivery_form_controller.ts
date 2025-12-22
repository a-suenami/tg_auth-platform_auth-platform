import { Controller } from "@hotwired/stimulus";

/**
 * Handles delivery form type toggling (schedule vs birthday)
 *
 * Note: Datetime UTC conversion is handled by datetime-utc controller
 */
export default class extends Controller {
  static targets = ["scheduleFields", "birthdayFields"];
  static values = { type: String };

  declare scheduleFieldsTarget: HTMLElement;
  declare birthdayFieldsTarget: HTMLElement;
  declare hasScheduleFieldsTarget: boolean;
  declare hasBirthdayFieldsTarget: boolean;
  declare typeValue: string;

  connect() {
    this.updateFieldsVisibility();
  }

  toggleType(event: Event) {
    this.typeValue = (event.target as HTMLInputElement).value;
    this.updateFieldsVisibility();
  }

  private updateFieldsVisibility() {
    const isSchedule = this.typeValue === "schedule";
    if (this.hasScheduleFieldsTarget) {
      this.scheduleFieldsTarget.classList.toggle("uk-hidden", !isSchedule);
    }
    if (this.hasBirthdayFieldsTarget) {
      this.birthdayFieldsTarget.classList.toggle("uk-hidden", isSchedule);
    }
  }
}
