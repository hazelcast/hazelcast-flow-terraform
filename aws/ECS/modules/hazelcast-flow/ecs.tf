resource "aws_ecs_cluster" "cluster" {
  name = var.system_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_service_discovery_private_dns_namespace" "flow" {
  name        = var.service_discovery_domain
  description = "Flow ${var.system_name} on ${var.environment} environment service discovery "
  vpc         = var.vpc_id
}

data "aws_secretsmanager_secret" "mc_license" {
  name = "/hazelcast-flow/MC_LICENSE"
}

resource "aws_security_group" "ecs_service" {
  vpc_id      = var.vpc_id
  name_prefix = var.system_name
  description = "Fargate service security group for ${var.environment}"

  revoke_rules_on_delete = true

  ingress {
    protocol        = "-1"
    from_port       = 0
    to_port         = 0
    security_groups = [var.external_connectivity_security_group_id, aws_security_group.alb.id]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

module "flow" {
  source                    = "./modules/flow"
  service_name              = "flow-${var.system_name}"
  environment               = var.environment
  region                    = var.region
  vpc_id                    = var.vpc_id
  subnets                   = var.subnets
  image                     = "docker.io/hazelcast/hazelcast-flow:${var.flow_version}"
  task_definition_cpu       = 2048
  task_definition_memory    = 4096
  port                      = 9021
  protocol                  = "HTTP"
  namespace_id              = aws_service_discovery_private_dns_namespace.flow.id
  execution_role_arn        = aws_iam_role.execution.arn
  task_role_arn             = aws_iam_role.task.arn
  cluster_id                = aws_ecs_cluster.cluster.id
  cloudwatch_log_group_name = aws_cloudwatch_log_group.main.name
  security_groups           = [aws_security_group.ecs_service.id, var.external_connectivity_security_group_id]
  health_check = {
    path = "/api/actuator/health"
    port = 9021
  }
  environment_variables = {
    VYNE_DB_HOST                                 = var.database_host
    VYNE_DB_PORT                                 = var.database_port
    VYNE_DB_USERNAME                             = var.database_username
    VYNE_DB_PASSWORD                             = var.database_password
    VYNE_ANALYTICS_PERSIST_REMOTE_CALL_RESPONSES = tostring(var.flow_persist_remote_call_responses)
    VYNE_ANALYTICS_PERSIST_RESULTS               = tostring(var.flow_persist_results)
    VYNE_WORKSPACE_GIT_URL                       = var.flow_workspace_git_url
    VYNE_WORKSPACE_GIT_BRANCH                    = var.flow_workspace_git_branch
    VYNE_WORKSPACE_GIT_PATH                      = var.flow_workspace_git_path
    OPTIONS                                      = "--vyne.config.custom.managementCenterUrl=https://${var.domain_name}/mc"
  }
}

module "mc" {
  source                    = "./modules/flow"
  service_name              = "management-center-${var.system_name}"
  environment               = var.environment
  region                    = var.region
  vpc_id                    = var.vpc_id
  subnets                   = var.subnets
  image                     = "docker.io/hazelcast/management-center-flow:${var.flow_version}"
  task_definition_cpu       = 1024
  task_definition_memory    = 2048
  port                      = 8080
  protocol                  = "HTTP"
  namespace_id              = aws_service_discovery_private_dns_namespace.flow.id
  execution_role_arn        = aws_iam_role.execution.arn
  task_role_arn             = aws_iam_role.task.arn
  cluster_id                = aws_ecs_cluster.cluster.id
  cloudwatch_log_group_name = aws_cloudwatch_log_group.main.name
  security_groups           = [aws_security_group.ecs_service.id, var.external_connectivity_security_group_id]
  health_check = {
    path = "/health"
    port = 8080
  }
  secrets = {
    MC_LICENSE = data.aws_secretsmanager_secret.mc_license.arn
  }
  environment_variables = {
    JAVA_OPTS                  = "-Dhazelcast.mc.flow.address=https://${var.domain_name}/flow -Dhazelcast.mc.flow.internalAddress=http://flow-${var.system_name}.${var.service_discovery_domain}:9021"
    MC_DEFAULT_CLUSTER         = "flow"
    MC_DEFAULT_CLUSTER_MEMBERS = "flow-${var.system_name}.${var.service_discovery_domain}:25701"
    MC_INIT_CMD                = "./bin/mc-conf.sh security reset && ./bin/mc-conf.sh dev-mode configure"
  }
}