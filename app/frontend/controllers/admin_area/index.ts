import { application } from '@app/controllers/application';
import ScheduleFormController from './schedule_form_controller';
import UserAutoTaggingFormController from './user_auto_tagging_form_controller';
import AutoTaggingTagSelectorController from "./auto_tagging_tag_selector_controller";

application.register('schedule-form', ScheduleFormController);
application.register('user-auto-tagging-form', UserAutoTaggingFormController);
application.register('auto-tagging-tag-selector', AutoTaggingTagSelectorController);

console.log('this is frontend/controllers/admin_area/index.ts')
