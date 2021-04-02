provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

/* Begin Previously Defined Resources */

data "terraform_remote_state" "api_ecr" {
  backend = "s3"

  config = {
    region  = var.aws_region
    profile = var.aws_profile
    bucket  = var.tf-state-bucket
    key     = "api/ecr/terraform.tfstate"
  }
}

data "terraform_remote_state" "api_vpc" {
  backend = "s3"

  config = {
    region  = var.aws_region
    profile = var.aws_profile
    bucket  = var.tf-state-bucket
    key     = "api/vpc/terraform.tfstate"
  }
}

/* End Previously Defined Resources */

resource "aws_ecs_cluster" "api_ecs_cluster" {
  name               = "bfl-ecs-cluster-${var.environment}"
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  tags = {
    Application = "Bachelor Fantasy League"
  }
}

resource "aws_ecs_task_definition" "api_task_definition" {
  family                   = "bfl-api-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = data.terraform_remote_state.api_ecr.outputs.ecr_admin_role_arn
  network_mode             = "awsvpc"

  memory = "512"
  cpu    = "256"

  container_definitions = <<-CONTAINER_DEFINITIONS
  [
    {
      "name": "bfl-api-${var.environment}",
      "image": "${var.image}",
      "portMappings": [
        {
          "containerPort": 4000,
          "hostPort": 4000
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region": "${var.aws_region}",
          "awslogs-group": "bfl-api-${var.environment}",
          "awslogs-create-group": "true",
          "awslogs-stream-prefix": "bfl-${var.environment}"
        }
      },
      "memory": 512,
      "cpu": 256,
      "essential": true,
      "secrets": [
        {
          "valueFrom": "/BFL/${var.environment}/CLIENT_HOST",
          "name": "CLIENT_HOST"
        },
        {
          "valueFrom": "/BFL/${var.environment}/JWT_SECRET",
          "name": "JWT_SECRET"
        },
        {
          "valueFrom": "/BFL/${var.environment}/NODE_ENV",
          "name": "NODE_ENV"
        },
        {
          "valueFrom": "/BFL/${var.environment}/POSTGRES_HOST",
          "name": "POSTGRES_HOST"
        },
        {
          "valueFrom": "/BFL/${var.environment}/POSTGRES_PORT",
          "name": "POSTGRES_PORT"
        },
        {
          "valueFrom": "/BFL/${var.environment}/POSTGRES_USER",
          "name": "POSTGRES_USER"
        },
        {
          "valueFrom": "/BFL/${var.environment}/POSTGRES_PASSWORD",
          "name": "POSTGRES_PASSWORD"
        },
        {
          "valueFrom": "/BFL/${var.environment}/POSTGRES_DATABASE",
          "name": "POSTGRES_DATABASE"
        },
        {
          "valueFrom": "/BFL/${var.environment}/SEED_WEEK_NUMBER",
          "name": "SEED_WEEK_NUMBER"
        },
        {
          "valueFrom": "/BFL/${var.environment}/SENDGRID_API_KEY",
          "name": "SENDGRID_API_KEY"
        },
        {
          "valueFrom": "/BFL/${var.environment}/SENDGRID_SENDER",
          "name": "SENDGRID_SENDER"
        },
        {
          "valueFrom": "/BFL/${var.environment}/SERVER_PORT",
          "name": "SERVER_PORT"
        }
      ]
    }
  ]
  CONTAINER_DEFINITIONS

  tags = {
    Application = "Bachelor Fantasy League"
  }
}

resource "aws_security_group" "api_task_security_group" {
  name   = "bfl_ecs_sg_production"
  vpc_id = data.terraform_remote_state.api_vpc.outputs.vpc_id

  ingress {
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
  }

  tags = {
    Application = "Bachelor Fantasy League"
  }
}

resource "aws_ecs_service" "api_ecs_service" {
  task_definition  = aws_ecs_task_definition.api_task_definition.arn
  platform_version = "1.4.0"
  cluster          = aws_ecs_cluster.api_ecs_cluster.id
  name             = "bfl-ecs-service-${var.environment}"
  desired_count    = 1

  network_configuration {
    subnets          = [data.terraform_remote_state.api_vpc.outputs.public_subnet_id]
    security_groups  = [aws_security_group.api_task_security_group.id]
    assign_public_ip = true
  }
}
