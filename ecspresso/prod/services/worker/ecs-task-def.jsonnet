local worker_environment = import '../../templates/rails_environment.libsonnet';
local worker_secrets = import '../../templates/rails_secrets.libsonnet';
local worker_image_tag = std.extVar('APP_IMAGE_TAG');

local cpu = 1024;
local memory = 1800;
local memory_reservation = 512;

{
  "containerDefinitions": [
    {
      "command": [
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
      "environment": worker_environment,
      "essential": true,
      "image": "843188904699.dkr.ecr.ap-northeast-1.amazonaws.com/id-platform-main-app-prod:" + worker_image_tag,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/id-platform-main-service-worker/worker",
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "worker"
        }
      },
      "memory": memory,
      "memoryReservation": memory_reservation,
      "mountPoints": [],
      "name": "worker",
      "portMappings": [],
      "secrets": worker_secrets,
      "volumesFrom": []
    }
  ],
  "executionRoleArn": "arn:aws:iam::843188904699:role/id-platform-main-ecs-task-execution-prod",
  "family": "id-platform-main-service-worker-prod",
  "placementConstraints": [],
  "requiresCompatibilities": [
    "EC2"
  ],
  "tags": [
    {
      "key": "env",
      "value": "prod"
    },
    {
      "key": "project",
      "value": "id-platform"
    }
  ],
  "taskRoleArn": "arn:aws:iam::843188904699:role/id-platform-main-ecs-task-prod",
  "volumes": []
}
