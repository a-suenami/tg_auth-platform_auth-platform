import { application } from "@app/controllers/application";
import SidekiqJobFormController from "./sidekiq_job_form_controller";

application.register("sidekiq-job-form", SidekiqJobFormController);

console.log("this is frontend/controllers/ruler_area/index.ts");
