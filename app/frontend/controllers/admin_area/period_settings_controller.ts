import { Controller } from '@hotwired/stimulus';

/**
 * Period Settings Controller
 *
 * Manages period settings dropdown and shows/hides additional form fields based on selection.
 */
export default class extends Controller {
  static targets = ['select', 'content', 'relative', 'fixed', 'text', 'display'];

  declare readonly selectTarget: HTMLSelectElement;
  declare readonly contentTarget: HTMLElement;
  declare readonly relativeTarget: HTMLElement;
  declare readonly fixedTarget: HTMLElement;
  declare readonly textTarget: HTMLElement;
  declare readonly displayTargets: HTMLElement[];

  private currentDateType: string | null = null;

  connect() {
    this.handleChange();
  }

  handleChange() {
    const value = this.selectTarget.value;
    const selectedOption = this.selectTarget.options[this.selectTarget.selectedIndex];

    // Update display text
    this.textTarget.textContent = selectedOption.textContent || '期間を設定する';

    // Hide all content sections first
    this.contentTarget.style.display = 'none';
    this.relativeTarget.style.display = 'none';
    this.fixedTarget.style.display = 'none';

    // Show appropriate section based on selection
    if (value === 'relative') {
      this.contentTarget.style.display = 'block';
      this.relativeTarget.style.display = 'block';
    } else if (value === 'fixed') {
      this.contentTarget.style.display = 'block';
      this.fixedTarget.style.display = 'block';
    }
  }

  openDatepicker(event: Event) {
    event.preventDefault();
    const target = event.currentTarget as HTMLElement;
    this.currentDateType = target.getAttribute('data-date-type');

    // Get current date value from display
    const currentText = target.querySelector('.c-period-settings__fixed__argument__text')?.textContent || '';
    const currentDate = this.parseDateFromText(currentText);

    // Open modal via Turbo Frame
    const modalUrl = '/admin/user_auto_taggings/datepicker';
    const modal = document.querySelector('[data-modal-id="datepicker-modal"]') as HTMLElement;
    if (modal) {
      const modalFrame = modal.querySelector('turbo-frame#modal-frame') as any;
      if (modalFrame) {
        modalFrame.src = modalUrl;

        // Wait for frame to load and set initial values
        modalFrame.addEventListener('turbo:frame-load', () => {
          if (currentDate) {
            const yearSelect = modalFrame.querySelector('[data-datepicker-target="year"]') as HTMLSelectElement;
            const monthSelect = modalFrame.querySelector('[data-datepicker-target="month"]') as HTMLSelectElement;
            const daySelect = modalFrame.querySelector('[data-datepicker-target="day"]') as HTMLSelectElement;

            if (yearSelect && monthSelect && daySelect) {
              yearSelect.value = currentDate.year.toString();
              monthSelect.value = currentDate.month.toString();
              daySelect.value = currentDate.day.toString();
            }
          }
        }, { once: true });
      }
    }
  }

  selectDate(event: Event) {
    event.preventDefault();
    // event.currentTargetがnullの場合があるため、targetから取得
    const target = event.target as HTMLElement;
    const button = target.closest('[data-action="select-date"]') as HTMLElement;
    if (!button) return;

    const modal = button.closest('.c-modal') as HTMLElement;
    if (!modal) return;

    const datepicker = modal.querySelector('[data-controller*="datepicker"]') as HTMLElement;
    if (!datepicker) return;

    const yearSelect = datepicker.querySelector('[data-datepicker-target="year"]') as HTMLSelectElement;
    const monthSelect = datepicker.querySelector('[data-datepicker-target="month"]') as HTMLSelectElement;
    const daySelect = datepicker.querySelector('[data-datepicker-target="day"]') as HTMLSelectElement;

    if (yearSelect && monthSelect && daySelect) {
      const year = yearSelect.value;
      const month = monthSelect.value.padStart(2, '0');
      const day = daySelect.value.padStart(2, '0');
      const dateStr = `${year}/${month}/${day}`;

      // Update display
      if (this.currentDateType) {
        // displayTargetsから探す
        const displayTarget = this.displayTargets.find(
          (target) => target.getAttribute('data-date-type') === this.currentDateType
        );

        if (displayTarget) {
          const textElement = displayTarget.querySelector('.c-period-settings__fixed__argument__text');
          if (textElement) {
            textElement.textContent = dateStr;
            console.log('Date updated:', dateStr, 'to', this.currentDateType);
          } else {
            console.warn('Text element not found in displayTarget');
          }
        } else {
          // フォールバック: 直接DOMから探す
          const fallbackTarget = document.querySelector(
            `[data-period-settings-target="display"][data-date-type="${this.currentDateType}"]`
          ) as HTMLElement;
          if (fallbackTarget) {
            const textElement = fallbackTarget.querySelector('.c-period-settings__fixed__argument__text');
            if (textElement) {
              textElement.textContent = dateStr;
              console.log('Date updated (fallback):', dateStr, 'to', this.currentDateType);
            }
          } else {
            console.warn('Display target not found for date-type:', this.currentDateType);
          }
        }
      } else {
        console.warn('currentDateType is not set');
      }
    }

    // Close modal
    const modalId = modal.getAttribute('data-modal-id');
    if (modalId) {
      // closeModal関数を直接呼び出す
      const closeModal = (window as any).closeModal;
      if (closeModal && typeof closeModal === 'function') {
        closeModal(modalId);
      } else {
        // フォールバック: モーダルを直接閉じる
        modal.setAttribute('data-modal-open', 'false');
        document.body.style.overflow = '';
        const frame = modal.querySelector('turbo-frame#modal-frame') as HTMLElement;
        if (frame) {
          frame.innerHTML = '';
        }
      }
    }
  }

  private parseDateFromText(text: string): { year: number; month: number; day: number } | null {
    const match = text.match(/(\d{4})\/(\d{2})\/(\d{2})/);
    if (match) {
      return {
        year: parseInt(match[1], 10),
        month: parseInt(match[2], 10),
        day: parseInt(match[3], 10),
      };
    }
    return null;
  }
}

