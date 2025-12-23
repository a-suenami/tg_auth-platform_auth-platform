import * as Turbo from '@hotwired/turbo';
// import '@app/controllers/ruler_area/index'; // Stimulus
import UIkit from 'uikit';
import Icons from 'uikit/dist/js/uikit-icons';

import '@app/stylesheets/user_area/application.scss';

// require('@rails/ujs').start();

Turbo.session.drive = true;

// loads the Icon plugin
UIkit.use(Icons);

// window.Vue = Vue;
window.UIkit = UIkit;

// Inflections.js が global is not defined を起こすのでその対策
(window as any).global = window;

document.addEventListener('turbo:load', async () => {
  Array.from(document.getElementsByClassName('rl-clickable-tab')).forEach(
    (tab) => {
      tab.addEventListener('click', (e) => {
        const url = e.target.href;

        if (e.metaKey) {
          window.open(url, '_blank');
        } else {
          window.location.href = url;
        }
      });
    },
  );
});

