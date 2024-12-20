local worker_environment = import '../../templates/rails_environment.libsonnet';
local worker_secrets = import '../../templates/rails_secrets.libsonnet';
local worker_image_tag = std.extVar('APP_IMAGE_TAG');

local cpu = 1024;
local memory = 1800;
local memory_reservation = 512;

{
  "cpu": "1024",
  "memory": "2048",
  "containerDefinitions": [
    {
      "command":  [
        "bash",
        "bin/sidekiq-entrypoint.sh",
        "bundle",
        "exec",
        "sidekiq",
        "-C",
        "config/sidekiq.yml",
        "-t",
        "25"
      ],
      "cpu": cpu,
      "entryPoint": [],
      "environment": worker_environment,
      "essential": true,
      "image": "287511440462.dkr.ecr.ap-northeast-1.amazonaws.com/id-platform-main-app-stg:" + worker_image_tag,
      "logConfiguration": {
        "logDriver": "awsfirelens",
        "options": {
          "Name": "datadog",
          "Host": "http-intake.logs.datadoghq.com",
          "dd_service": "auth-platform-worker",
          "dd_source": "sidekiq",
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
      "name": "worker",
      "portMappings": [],
      "secrets": worker_secrets,
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
  "family": "id-platform-main-service-worker-stg",
  "placementConstraints": [],
  "requiresCompatibilities": [
    "EC2"
  ],
  "runtimePlatform": {
    "cpuArchitecture": "ARM64",
    "operatingSystemFamily": "LINUX"
  },
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
