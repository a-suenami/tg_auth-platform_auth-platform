import * as Turbo from "@hotwired/turbo";
import "@app/controllers/admin_area/index"; // Stimulus
import UIkit from "uikit";
import Icons from "uikit/dist/js/uikit-icons";

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
  // ドロップダウンのトグルボタンクリック
  document.addEventListener("click", (e) => {
    const target = e.target as HTMLElement;
    const toggle = target.closest("[data-dropdown-toggle]") as HTMLElement;
    const dropdown = target.closest(".c-tag-card__dropdown") as HTMLElement;

    if (toggle) {
      e.preventDefault();
      e.stopPropagation();

      const dropdownId = toggle.getAttribute("data-dropdown-toggle");
      if (!dropdownId) return;

      const targetDropdown = document.getElementById(dropdownId) as HTMLElement;
      if (!targetDropdown) return;

      const isOpen = targetDropdown.getAttribute("data-dropdown-open") === "true";

      // すべてのドロップダウンを閉じる
      document.querySelectorAll("[data-dropdown-open='true']").forEach((d) => {
        d.setAttribute("data-dropdown-open", "false");
      });

      // クリックされたドロップダウンを開閉
      if (!isOpen) {
        targetDropdown.setAttribute("data-dropdown-open", "true");
      }
    } else if (dropdown) {
      // ドロップダウン内のリンククリック時は閉じない（リンクの処理を優先）
      e.stopPropagation();
    } else {
      // ドロップダウン外をクリックした場合は閉じる
      document.querySelectorAll("[data-dropdown-open='true']").forEach((d) => {
        d.setAttribute("data-dropdown-open", "false");
      });
    }
  });
}

document.addEventListener("turbo:load", async () => {
  formatLocalTimes();
  initModalObserver();
  initModalHandlers();
  initDropdownHandlers();

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
