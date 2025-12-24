import { application } from "@app/controllers/application";
import UserAutoTaggingFormController from "./user_auto_tagging_form_controller";
import AutoTaggingTagSelectorController from "./auto_tagging_tag_selector_controller";
import TemplatePreviewController from "./template_preview_controller";
import FormValidationController from "./form_validation_controller";
import PeriodSettingsController from "./period_settings_controller";
import DatepickerController from "./datepicker_controller";
import ConditionBlockController from "./condition_block_controller";
import ConditionBlocksController from "./condition_blocks_controller";
import SidenavToggleController from "./sidenav_toggle_controller";
import DeliveryFormController from "./delivery_form_controller";
import DeliveryTagSelectorController from "./delivery_tag_selector_controller";
import DatetimeUtcController from "./datetime_utc_controller";
import UserTagAssignmentFormController from "./user_tag_assignment_form_controller";
import UserSearchTagSelectorController from "./user_search_tag_selector_controller";

application.register(
  "auto-tagging-tag-selector",
  AutoTaggingTagSelectorController
);
application.register("template-preview", TemplatePreviewController);
application.register("delivery-form", DeliveryFormController);
application.register("delivery-tag-selector", DeliveryTagSelectorController);
application.register("datetime-utc", DatetimeUtcController);
application.register("user-auto-tagging-form", UserAutoTaggingFormController);
application.register(
  "user-tag-assignment-form",
  UserTagAssignmentFormController
);
application.register(
  "user-search-tag-selector",
  UserSearchTagSelectorController
);
application.register("form-validation", FormValidationController);
application.register("period-settings", PeriodSettingsController);
application.register("datepicker", DatepickerController);
application.register("condition-block", ConditionBlockController);
application.register("condition-blocks", ConditionBlocksController);
application.register("sidenav-toggle", SidenavToggleController);

console.log("this is frontend/controllers/admin_area/index.ts");
