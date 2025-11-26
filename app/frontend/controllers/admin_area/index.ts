import { application } from '@app/controllers/application';
import ScheduleFormController from './schedule_form_controller';
import UserAutoTaggingFormController from './user_auto_tagging_form_controller';
import UserTagAssignmentFormController from './user_tag_assignment_form_controller';

application.register('schedule-form', ScheduleFormController);
application.register('user-auto-tagging-form', UserAutoTaggingFormController);
application.register('user-tag-assignment-form', UserTagAssignmentFormController);

console.log('this is frontend/controllers/admin_area/index.ts')
