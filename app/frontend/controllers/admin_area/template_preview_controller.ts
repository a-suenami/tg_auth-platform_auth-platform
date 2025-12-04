import { Controller } from "@hotwired/stimulus";

/**
 * Template Preview Controller
 *
 * Syncs edit form values to preview form and handles preview updates via Turbo
 */
export default class extends Controller {
  static targets = [
    "editBody",
    "editTitle",
    "previewBody",
    "previewTitle",
    "previewForm",
    "tabContent",
  ];

  declare readonly editBodyTarget: HTMLTextAreaElement;
  declare readonly editTitleTarget: HTMLInputElement;
  declare readonly previewBodyTarget: HTMLInputElement;
  declare readonly previewTitleTarget: HTMLInputElement;
  declare readonly previewFormTarget: HTMLFormElement;
  declare readonly tabContentTarget: HTMLElement;

  declare readonly hasEditBodyTarget: boolean;
  declare readonly hasEditTitleTarget: boolean;
  declare readonly hasPreviewBodyTarget: boolean;
  declare readonly hasPreviewTitleTarget: boolean;
  declare readonly hasPreviewFormTarget: boolean;
  declare readonly hasTabContentTarget: boolean;

  connect() {
    if (this.hasTabContentTarget && window.UIkit) {
      window.UIkit.util.on(
        this.tabContentTarget,
        "shown",
        this.handleTabSwitch.bind(this)
      );
    }
  }

  // Sync edit form values to preview form hidden fields
  syncAll() {
    if (this.hasEditBodyTarget && this.hasPreviewBodyTarget) {
      this.previewBodyTarget.value = this.editBodyTarget.value;
    }
    if (this.hasEditTitleTarget && this.hasPreviewTitleTarget) {
      this.previewTitleTarget.value = this.editTitleTarget.value;
    }
  }

  // Submit preview form via Turbo
  submitPreviewForm() {
    if (!this.hasPreviewFormTarget) return;
    this.previewFormTarget.requestSubmit();
  }

  // Auto-preview when switching to preview tab
  handleTabSwitch() {
    if (!this.hasTabContentTarget || !window.UIkit) return;

    const switcher = window.UIkit.switcher(this.tabContentTarget);
    const activeIndex = switcher ? switcher.index() : -1;

    if (activeIndex === 1) {
      this.syncAll();

      const hasContent =
        (this.hasPreviewBodyTarget && this.previewBodyTarget.value) ||
        (this.hasPreviewTitleTarget && this.previewTitleTarget.value);

      if (hasContent) {
        this.submitPreviewForm();
      }
    }
  }

  // Submit edit form (workaround for UIkit switcher role="tab" issue)
  submitEditForm() {
    const editForm = document.getElementById(
      "mail-template-form"
    ) as HTMLFormElement | null;
    if (editForm) {
      editForm.requestSubmit();
    }
  }
}
