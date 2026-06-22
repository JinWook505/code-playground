variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "code-playground"
}

variable "domain_name" {
  description = "Domain name"
  type        = string
  default     = "codeplayground.com"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2b"]
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

# RDS Configuration
variable "database_name" {
  description = "Database name"
  type        = string
  default     = "codeplayground"
}

variable "database_username" {
  description = "Database username"
  type        = string
  default     = "codeplayground_admin"
}

variable "database_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 100
}

# ElastiCache Configuration
variable "redis_node_type" {
  description = "Redis node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_num_nodes" {
  description = "Number of Redis nodes"
  type        = number
  default     = 2
}

# ECS Configuration - Backend
variable "backend_image" {
  description = "Backend Docker image"
  type        = string
}

variable "backend_cpu" {
  description = "Backend CPU units"
  type        = number
  default     = 1024
}

variable "backend_memory" {
  description = "Backend memory in MB"
  type        = number
  default     = 2048
}

variable "backend_desired_count" {
  description = "Backend desired count"
  type        = number
  default     = 2
}

# ECS Configuration - Frontend
variable "frontend_image" {
  description = "Frontend Docker image"
  type        = string
}

variable "frontend_cpu" {
  description = "Frontend CPU units"
  type        = number
  default     = 512
}

variable "frontend_memory" {
  description = "Frontend memory in MB"
  type        = number
  default     = 1024
}

variable "frontend_desired_count" {
  description = "Frontend desired count"
  type        = number
  default     = 1
}

# SSL Certificates
variable "ssl_certificate_arn" {
  description = "SSL certificate ARN for ALB"
  type        = string
  default     = ""
}

variable "cloudfront_certificate_arn" {
  description = "SSL certificate ARN for CloudFront (must be in ap-northeast-2)"
  type        = string
  default     = ""
}

# Secrets
variable "jwt_secret" {
  description = "JWT secret key"
  type        = string
  sensitive   = true
}