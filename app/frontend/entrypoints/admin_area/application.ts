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

document.addEventListener("turbo:load", async () => {
  formatLocalTimes();
  initModalObserver();

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
