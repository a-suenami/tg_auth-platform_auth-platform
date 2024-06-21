local app_environment = import '../templates/rails_environment.libsonnet';
local app_secrets = import '../templates/rails_secrets.libsonnet';
local app_image_tag = std.extVar('APP_IMAGE_TAG');

local cpu = 10;
local memory = 512;
local memory_reservation = 256;

{
  "containerDefinitions": [
    {
      "command": [],
      "cpu": cpu,
      "entryPoint": [],
      "environment": app_environment,
      "essential": true,
      "image": "287511440462.dkr.ecr.ap-northeast-1.amazonaws.com/id-platform-main-app-stg:" + app_image_tag,
      "logConfiguration": {
        "logDriver": "awsfirelens",
        "options": {
          "Name": "datadog",
          "Host": "http-intake.logs.datadoghq.com",
          "dd_service": "auth-platform-app",
          "dd_source": "ruby",
          "dd_tags": "env:staging",
          "TLS": "on",
          "provider": "ecs"
        },
        "secretOptions": [
          {
            "name": "apikey",
            "valueFrom": "/id-platform/stg/ecs/main/datadog_api_key"
          }
        ]
      },
      "memory": memory,
      "memoryReservation": memory_reservation,
      "mountPoints": [],
      "name": "app",
      "portMappings": [],
      "secrets": app_secrets,
      "volumesFrom": []
    },
    // fluent bit
    {
      "essential": true,
      "image": "amazon/aws-for-fluent-bit:2.28.4",
      "name": "log_router",
      "firelensConfiguration": {
          "type": "fluentbit",
          "options": {
              "enable-ecs-log-metadata": "true",
              "config-file-type": "file",
              "config-file-value": "/fluent-bit/configs/parse-json.conf"
          }
      },
      "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
              "awslogs-group": "/ecs/firelens",
              "awslogs-region": "ap-northeast-1",
              "awslogs-stream-prefix": "app"
          }
      },
      "environment": null,
      "secrets": null,
      "memoryReservation": 50,
      "cpu": 64,
    }
  ],
  "executionRoleArn": "arn:aws:iam::287511440462:role/id-platform-main-ecs-task-execution-stg",
  "family": "id-platform-main-oneshot-stg",
  "placementConstraints": [],
  "requiresCompatibilities": [
    "EC2"
  ],
  "tags": [
    {
      "key": "env",
      "value": "stg"
    },
    {
      "key": "project",
      "value": "id-platform"
    }
  ],
  "taskRoleArn": "arn:aws:iam::287511440462:role/id-platform-main-ecs-task-stg",
  "volumes": []
}
