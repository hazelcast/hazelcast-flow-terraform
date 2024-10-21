variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "az" {
  type    = string
  default = "eu-west-2a"
}

variable "az2" {
  type    = string
  default = "eu-west-2b"
}

variable "system_name" {
  type    = string
  default = "flow"
}
variable "environment" {
  type        = string
  description = "Name of the environment that is used as part of the resource names and domains. "
  default     = "prod"
}

variable "domain_name" {
  type        = string
  description = "The subdomain where Flow DNS will be configured for access"
}

variable "http_access_ip_range" {
  type        = string
  description = "The IP range that Flow will accept inbound HTTP(s) traffic from. Defaults to anywhere"
  default     = "0.0.0.0/0"
}

variable "flow_version" {
  type        = string
  description = "The version / tag of Flow"
  default     = "latest"
}

variable "mc_version" {
  type        = string
  description = "The version / tag of Management Center"
  default     = "latest"
}

// Application configuration
variable "flow_persist_results" {
  type        = bool
  description = "Configures if Flow persists results of queries"
  default     = false
}

variable "flow_persist_remote_call_responses" {
  type        = bool
  description = "Configures if Flow persists results of remote calls"
  default     = false
}

variable "flow_workspace_git_url" {
  type        = string
  description = "The git url (including a PAT if required) for reading a workspace config from git"
  default     = ""
}

variable "flow_workspace_git_branch" {
  type        = string
  description = "The name of the git branch to read the workspace.conf file from"
  default     = "main"
}

variable "flow_workspace_git_path" {
  type        = string
  description = "The path within the git repository to the workspace.conf file"
  default     = "workspace.conf"
}
