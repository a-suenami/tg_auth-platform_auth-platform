local app_environment = import '../../templates/rails_environment.libsonnet';
local app_secrets = import '../../templates/rails_secrets.libsonnet';
local app_image_tag = std.extVar('APP_IMAGE_TAG');

local cpu = 1024;
local memory = 3200;
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
    {
      "command": [
        "/bin/bash",
        "-c",
        "envsubst '$HEALTH_CHECK_ALLOW_IPS $RULER_ALLOW_IPS' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf && exec nginx -g 'daemon off;'"
      ],
      "cpu": 256,
      "entryPoint": [],
      "environment": [
        {
          "name": "RULER_ALLOW_IPS",
          "value": "allow 167.179.95.236/32; allow 219.104.123.178/32; allow 217.178.59.190/32; allow 240d:1b:5c:9600::/56; allow 240d:1b:ad::/56; allow 2409:10:2500:3700::/56;"
        },
        {
          "name": "HEALTH_CHECK_ALLOW_IPS",
          "value": "allow 10.85.0.0/16; allow 52.193.111.118/32; allow 52.196.125.133/32; allow 13.113.213.40/32; allow 52.197.186.229/32; allow 52.198.79.40/32; allow 13.114.12.29/32; allow 13.113.240.89/32; allow 52.68.245.9/32; allow 13.112.142.176/32;"
        }
      ],
      "essential": true,
      "image": "287511440462.dkr.ecr.ap-northeast-1.amazonaws.com/id-platform-main-nginx-stg:latest",
      "links": [
        "app"
      ],
      "logConfiguration": {
        "logDriver": "awsfirelens",
        "options": {
          "Name": "datadog",
          "Host": "http-intake.logs.datadoghq.com",
          "dd_service": "auth-platform-nginx",
          "dd_source": "nginx",
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
      "memory": 256,
      "memoryReservation": 128,
      "mountPoints": [],
      "name": "nginx",
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 0,
          "protocol": "tcp"
        }
      ],
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
  "family": "id-platform-main-service-app-stg",
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
