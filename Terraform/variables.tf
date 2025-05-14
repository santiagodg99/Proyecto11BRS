variable "aws_region" {
  description = "Región AWS donde se lanzará la instancia"
  type        = string
  default     = "eu-west-1"
}

variable "ami_id" {
  description = "AMI ID de Ubuntu o sistema compatible (ej: Ubuntu 18.04)"
  type        = string
}

variable "key_name" {
  description = "Nombre del par de llaves SSH existentes en AWS"
  type        = string
}

variable "my_ip" {
  description = "Tu IP pública para permitir acceso SSH (formato: x.x.x.x/32)"
  type        = string
}
