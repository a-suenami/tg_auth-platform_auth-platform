import { Controller } from "@hotwired/stimulus";

/**
 * Sidekiq Job Form Controller
 *
 * Shows dynamic hints when selecting a job from the dropdown.
 */
export default class extends Controller {
  static targets = ["select", "jobHint", "argsHint", "argsInput"];
  static values = {
    hints: Object,
  };

  declare readonly selectTarget: HTMLSelectElement;
  declare readonly jobHintTarget: HTMLElement;
  declare readonly argsHintTarget: HTMLElement;
  declare readonly argsInputTarget: HTMLInputElement;
  declare readonly hintsValue: Record<string, { args: string; desc: string }>;

  selectChanged() {
    const selected = this.selectTarget.value;
    const hint = this.hintsValue[selected];

    if (selected && hint) {
      this.jobHintTarget.textContent = hint.desc;
      this.jobHintTarget.style.display = "block";
      this.argsHintTarget.textContent = `例: ${hint.args}`;
      this.argsHintTarget.style.display = "block";
      this.argsInputTarget.placeholder =
        hint.args === "(不要)" ? "引数不要" : hint.args;
    } else {
      this.jobHintTarget.style.display = "none";
      this.argsHintTarget.style.display = "none";
      this.argsInputTarget.placeholder = "arg1,arg2,arg3";
    }
  }
}
