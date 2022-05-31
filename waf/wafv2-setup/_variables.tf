variable "name" {
  description = "Name of the EKS cluster."
}

variable "wafv2_enable" {
  default     = false
  description = "Deploys WAF V2 with Managed rule groups"
}

variable "wafv2_managed_rule_groups" {
  type        = list(string)
  default     = []
  description = "List of WAF V2 managed rule groups, set to count"
}

variable "wafv2_managed_block_rule_groups" {
  type        = list(string)
  default     = []
  description = "List of WAF V2 managed rule groups, set to block"
}

variable "wafv2_rate_limit_rule" {
  type        = number
  default     = 0
  description = "The limit on requests per 5-minute period for a single originating IP address (leave 0 to disable)"
}

variable "wafv2_create_alb_association" {
  default     = false
  description = "If associate Web ACL with the ALB"
}

variable "wafv2_arn_alb_internet_facing" {
  description = "ARN of the ALB to associate with the Web ACL"
}

variable "wafv2_cloudwatch_logging" {
  default     = false
  description = "Enable CloudWatch Logging"
}

variable "wafv2_cloudwatch_retention" {
  default     = 1
  description = "CloudWatch Logging Retention in Days"
}
