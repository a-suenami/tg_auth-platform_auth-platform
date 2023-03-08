import { Application } from '@hotwired/stimulus';
import UIkit from 'uikit';

export {};

declare global {
  interface Window {
    Stimulus: Application;
    UIkit: typeof UIkit;
  }
}
