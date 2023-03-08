import * as Turbo from '@hotwired/turbo';
import '@app/controllers/admin_area/index'; // Stimulus
import UIkit from 'uikit';
import Icons from 'uikit/dist/js/uikit-icons';

import '@app/stylesheets/admin_area/application.scss';

Turbo.session.drive = true;

// loads the Icon plugin
UIkit.use(Icons);

// window.Vue = Vue;
window.UIkit = UIkit;

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
