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
        "bundle",
        "exec",
        "sidekiq",
        "-C",
        "config/sidekiq.yml"
      ],
      "cpu": cpu,
      "entryPoint": [],
      "environment": worker_environment,
      "essential": true,
      "image": "287511440462.dkr.ecr.ap-northeast-1.amazonaws.com/id-platform-main-app-stg:" + worker_image_tag,
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
  "executionRoleArn": "arn:aws:iam::287511440462:role/id-platform-main-ecs-task-execution-stg",
  "family": "id-platform-main-service-worker-stg",
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
