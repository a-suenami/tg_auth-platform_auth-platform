import * as Turbo from "@hotwired/turbo";
import "@app/controllers/admin_area/index"; // Stimulus
import UIkit from "uikit";
import Icons from "uikit/dist/js/uikit-icons";
import { toggleDropdown, closeAllDropdowns } from "@app/utils/dropdown";

import "@app/stylesheets/admin_area/application.scss";

Turbo.session.drive = true;

// loads the Icon plugin
UIkit.use(Icons);

// window.Vue = Vue;
window.UIkit = UIkit;

// Format timestamps to local timezone
function formatLocalTimes() {
  document.querySelectorAll(".js-local-time").forEach((el: Element) => {
    const timestamp = parseInt((el as HTMLElement).dataset.timestamp || "0");
    if (!timestamp) return;

    const date = new Date(timestamp);
    const formatted = date
      .toLocaleString("ja-JP", {
        year: "numeric",
        month: "2-digit",
        day: "2-digit",
        hour: "2-digit",
        minute: "2-digit",
        hour12: false,
      })
      .replace(/\//g, "/");

    el.textContent = formatted;
  });

  // Handle datetime-local inputs
  document
    .querySelectorAll('input[type="datetime-local"][data-utc-value]')
    .forEach((input: Element) => {
      const utcValue = (input as HTMLInputElement).dataset.utcValue;
      console.log("Processing datetime input, utcValue:", utcValue);

      let date: Date;

      if (!utcValue || utcValue === "") {
        // New schedule: Default to 1 hour from now (keep minutes)
        date = new Date();
        date.setHours(date.getHours() + 1);
        date.setSeconds(0);
        date.setMilliseconds(0);
      } else {
        // Edit schedule: Use existing time
        date = new Date(utcValue);
      }

      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, "0");
      const day = String(date.getDate()).padStart(2, "0");
      const hours = String(date.getHours()).padStart(2, "0");
      const minutes = String(date.getMinutes()).padStart(2, "0");

      const formattedValue = `${year}-${month}-${day}T${hours}:${minutes}`;
      console.log("Setting input value to:", formattedValue);
      (input as HTMLInputElement).value = formattedValue;
    });
}

// Run formatLocalTimes when modal opens
function initModalObserver() {
  UIkit.util.on("#schedule-modal", "shown", function () {
    console.log("Schedule modal opened, running formatLocalTimes...");
    formatLocalTimes();
  });
}

// モーダルを開く
function openModal(modalId: string) {
  const modal = document.querySelector(`[data-modal-id="${modalId}"]`) as HTMLElement;
  if (modal) {
    modal.setAttribute("data-modal-open", "true");
    document.body.style.overflow = "hidden";
  }
}

// モーダルを閉じる
function closeModal(modalId: string) {
  const modal = document.querySelector(`[data-modal-id="${modalId}"]`) as HTMLElement;
  if (modal) {
    modal.setAttribute("data-modal-open", "false");
    document.body.style.overflow = "";
    // Turbo Frameをクリア
    const frame = modal.querySelector("turbo-frame#modal-frame") as HTMLElement;
    if (frame) {
      frame.innerHTML = "";
    }
  }
}

// グローバルスコープに公開
(window as any).closeModal = closeModal;

// モーダルのイベントハンドラーを初期化
function initModalHandlers() {
  // 閉じるボタン（イベント委譲を使用してTurbo Frame内のボタンにも対応）
  document.addEventListener("click", (e) => {
    const target = e.target as HTMLElement;
    const button = target.closest("[data-action='close-modal']") as HTMLElement;
    if (button) {
      e.preventDefault();
      const modal = button.closest(".c-modal") as HTMLElement;
      if (modal) {
        const modalId = modal.getAttribute("data-modal-id");
        if (modalId) {
          closeModal(modalId);
        }
      }
    }
  });

  // オーバーレイクリックで閉じる
  document.querySelectorAll(".c-modal__overlay").forEach((overlay) => {
    overlay.addEventListener("click", (e) => {
      const modal = overlay.closest(".c-modal") as HTMLElement;
      if (modal && e.target === overlay) {
        const modalId = modal.getAttribute("data-modal-id");
        if (modalId) {
          closeModal(modalId);
        }
      }
    });
  });

  // Turbo Frameがロードされたときにモーダルを開く
  document.addEventListener("turbo:frame-load", (e: any) => {
    const frame = e.target as HTMLElement;
    if (frame && frame.classList.contains("c-modal__dialog__frame")) {
      const modal = frame.closest(".c-modal") as HTMLElement;
      if (modal) {
        const modalId = modal.getAttribute("data-modal-id");
        if (modalId) {
          openModal(modalId);
        }
      }
    }
  });

  // キーボードショートカット（⌘+S）
  document.addEventListener("keydown", (e) => {
    if ((e.metaKey || e.ctrlKey) && e.key === "s") {
      const saveButton = document.querySelector(
        'button[data-shortcut="⌘+S"]'
      ) as HTMLButtonElement;
      if (saveButton && saveButton.closest(".c-modal[data-modal-open='true']")) {
        e.preventDefault();
        saveButton.click();
      }
    }
  });
}

// ドロップダウンの開閉を制御
function initDropdownHandlers() {
  // カードのリンククリック時に、3点ドットボタンエリアがクリックされた場合はリンクを無効化
  // capture phaseで実行して、Turboの処理より先に実行
  document.addEventListener("click", (e) => {
    const target = e.target as HTMLElement;
    const toggle = target.closest("[data-dropdown-toggle]") as HTMLElement;
    const actionWrapper = target.closest(".c-tag-card__action-wrapper") as HTMLElement;
    const cardLink = target.closest(".c-tag-card") as HTMLAnchorElement;

    // 3点ドットボタンまたはそのエリアがクリックされた場合
    if (toggle || actionWrapper) {
      e.preventDefault();
      e.stopPropagation();

      // トグルボタンの場合はドロップダウンを開閉
      if (toggle) {
        const dropdownId = toggle.getAttribute("data-dropdown-toggle");
        if (dropdownId) {
          toggleDropdown(dropdownId);
        }
      }
      return;
    }

    // カードのリンクがクリックされたが、3点ドットボタンエリア内の場合は無効化
    if (cardLink && actionWrapper) {
      e.preventDefault();
      e.stopPropagation();
      return;
    }
  }, true); // capture phaseで実行

  // ドロップダウンの開閉と外側クリックの処理
  document.addEventListener("click", (e) => {
    const target = e.target as HTMLElement;
    const dropdown = target.closest(".c-tag-card__dropdown, .c-table-row-action__dropdown, .l-header__container__account__dropdown") as HTMLElement;

    if (dropdown) {
      // ドロップダウン内のリンククリック時は閉じない（リンクの処理を優先）
      e.stopPropagation();
    } else {
      // ドロップダウン外をクリックした場合は閉じる
      // ただし、トグルボタンがクリックされた場合はcapture phaseで既に処理済みなのでスキップ
      const toggle = target.closest("[data-dropdown-toggle]") as HTMLElement;
      if (!toggle) {
        closeAllDropdowns();
      }
    }
  });
}

// 絞り込みセクションの開閉を制御
function initFilterHandlers() {
  document.addEventListener("click", (e) => {
    const target = e.target as HTMLElement;
    const toggle = target.closest("[data-filter-toggle]") as HTMLElement;
    const filterSection = target.closest(".c-table-filter") as HTMLElement;

    if (toggle) {
      e.preventDefault();
      e.stopPropagation();

      const filterId = toggle.getAttribute("data-filter-toggle");
      if (!filterId) return;

      const targetFilter = document.getElementById(filterId) as HTMLElement;
      if (!targetFilter) return;

      const isOpen = targetFilter.getAttribute("data-filter-open") === "true";

      // クリックされた絞り込みセクションを開閉
      targetFilter.setAttribute("data-filter-open", isOpen ? "false" : "true");
    } else if (filterSection) {
      // 絞り込みセクション内のクリック時は閉じない（フォームの処理を優先）
      e.stopPropagation();
    }
  });
}

// タグピッカーの選択機能
function initTagPickerHandlers() {
  // 日付ピッカーの「選択」ボタンクリック
  document.addEventListener("click", (e) => {
    const target = e.target as HTMLElement;
    const selectButton = target.closest("[data-action='select-date']") as HTMLElement;
    if (selectButton) {
      e.preventDefault();

      // PeriodSettingsControllerのselectDateメソッドを呼び出す
      const periodSettingsController = document.querySelector('[data-controller*="period-settings"]');
      if (periodSettingsController && window.Stimulus) {
        const controller = window.Stimulus.getControllerForElementAndIdentifier(
          periodSettingsController,
          'period-settings'
        ) as any;
        if (controller && typeof controller.selectDate === 'function') {
          controller.selectDate(e);
        }
      }
      return;
    }
  });

  // タグピッカーの「選択」ボタンクリック
  document.addEventListener("click", (e) => {
    const target = e.target as HTMLElement;
    const selectButton = target.closest("[data-action='select-tags']") as HTMLElement;
    if (!selectButton) return;

    e.preventDefault();

    const modal = selectButton.closest(".c-modal") as HTMLElement;
    if (!modal) return;

    // 選択されたタグを取得
    const selectedCheckboxes = modal.querySelectorAll(
      'input[type="checkbox"][name="selected_tags[]"]:checked'
    ) as NodeListOf<HTMLInputElement>;

    const selectedTags: Array<{ id: string; name: string }> = [];
    selectedCheckboxes.forEach((checkbox) => {
      const tagId = checkbox.getAttribute("data-tag-id");
      const tagName = checkbox.getAttribute("data-tag-name");
      if (tagId && tagName) {
        selectedTags.push({ id: tagId, name: tagName });
      }
    });

    // 選択されたタグを表示エリアに追加
    const displayArea = document.querySelector(
      "[data-tag-picker-selected]"
    ) as HTMLElement;
    if (displayArea) {
      // 既存のタグ要素だけを削除（ボタンは保持）
      const existingTags = displayArea.querySelectorAll(".c-user-detail-tag__item");
      existingTags.forEach((tag) => tag.remove());

      // 選択されたタグを追加
      selectedTags.forEach((tag) => {
        const tagElement = document.createElement("div");
        tagElement.className = "c-user-detail-tag__item";
        tagElement.setAttribute("data-tag-id", tag.id);
        const closeIcon = `<svg width="12" height="12" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M0.283203 15.2539C0.166016 15.1432 0.0878906 15.013 0.0488281 14.8633C0.016276 14.7135 0.0195312 14.5638 0.0585938 14.4141C0.0976562 14.2643 0.172526 14.1341 0.283203 14.0234L6.5332 7.76367L0.283203 1.51367C0.172526 1.40299 0.0976562 1.27279 0.0585938 1.12305C0.0260417 0.973307 0.0260417 0.823568 0.0585938 0.673828C0.0976562 0.524089 0.172526 0.39388 0.283203 0.283203C0.39388 0.166016 0.524089 0.0911458 0.673828 0.0585938C0.823568 0.0195312 0.973307 0.0195312 1.12305 0.0585938C1.2793 0.0911458 1.41276 0.166016 1.52344 0.283203L7.77344 6.5332L14.0234 0.283203C14.1341 0.166016 14.2643 0.0911458 14.4141 0.0585938C14.5638 0.0195312 14.7135 0.0195312 14.8633 0.0585938C15.013 0.0911458 15.1465 0.166016 15.2637 0.283203C15.3743 0.39388 15.4492 0.524089 15.4883 0.673828C15.5273 0.823568 15.5273 0.973307 15.4883 1.12305C15.4492 1.27279 15.3743 1.40299 15.2637 1.51367L9.01367 7.76367L15.2637 14.0234C15.3743 14.1341 15.446 14.2643 15.4785 14.4141C15.5176 14.5638 15.5176 14.7135 15.4785 14.8633C15.446 15.013 15.3743 15.1432 15.2637 15.2539C15.153 15.3711 15.0195 15.446 14.8633 15.4785C14.7135 15.5176 14.5638 15.5176 14.4141 15.4785C14.2643 15.4395 14.1341 15.3646 14.0234 15.2539L7.77344 9.00391L1.52344 15.2539C1.41276 15.3646 1.28255 15.4395 1.13281 15.4785C0.983073 15.5176 0.833333 15.5176 0.683594 15.4785C0.533854 15.4395 0.400391 15.3646 0.283203 15.2539Z" fill="currentColor"/></svg>`;
        tagElement.innerHTML = `
          <span class="c-user-detail-tag__item__text">${tag.name}</span>
          <a href="#" class="c-user-detail-tag__item__remove" data-action="remove-tag" data-tag-id="${tag.id}">
            ${closeIcon}
          </a>
        `;
        // ボタンの前にタグを追加
        const addButton = displayArea.querySelector(".c-user-detail-tag__add");
        if (addButton) {
          displayArea.insertBefore(tagElement, addButton);
        } else {
          displayArea.appendChild(tagElement);
        }
      });
    }

    // モーダルを閉じる
    const modalId = modal.getAttribute("data-modal-id");
    if (modalId) {
      closeModal(modalId);
    }
  });

  // タグの削除ボタンクリック
  document.addEventListener("click", (e) => {
    const target = e.target as HTMLElement;
    const removeButton = target.closest("[data-action='remove-tag']") as HTMLElement;
    if (!removeButton) return;

    e.preventDefault();

    const tagId = removeButton.getAttribute("data-tag-id");
    if (!tagId) return;

    const tagElement = removeButton.closest(".c-user-detail-tag__item") as HTMLElement;
    if (tagElement) {
      tagElement.remove();
    }
  });
}

document.addEventListener("turbo:load", async () => {
  formatLocalTimes();
  initModalObserver();
  initModalHandlers();
  initDropdownHandlers();
  initFilterHandlers();
  initTagPickerHandlers();

  Array.from(document.getElementsByClassName("rl-clickable-tab")).forEach(
    (tab) => {
      tab.addEventListener("click", (e: Event) => {
        const target = e.target as HTMLAnchorElement;
        if (!target) return;

        const url = target.href;

        if ((e as MouseEvent).metaKey) {
          window.open(url, "_blank");
        } else {
          window.location.href = url;
        }
      });
    }
  );
});
