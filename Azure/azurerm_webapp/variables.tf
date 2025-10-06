variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Location for the resource group"
}

variable "address_prefixes" {
  description = "Address prefixes for the subnet"
  default     = []
}

variable "fe_image_name" {
  type        = string
  description = "اسم صورة الدوكر الخاصة بالواجهة الأمامية (Frontend Docker image name)"
}

variable "fe_tag" {
  type        = string
  description = "إصدار صورة الدوكر للواجهة الأمامية (Frontend Docker image tag)"
  default     = "latest"
}
variable "fe_app_name" {
  type        = string
  description = "اسم تطبيق الواجهة الأمامية في Azure"
}

variable "service_plan_name_fe" {
  type        = string
  description = "اسم خطة الخدمة (App Service Plan) للواجهة الأمامية"
}

variable "fe_sku" {
  type        = string
  description = "نوع خطة الخدمة (SKU) مثل P1v2 أو S1"
  default     = "P1v2"
}

variable "public_access" {
  type        = bool
  description = "تمكين أو تعطيل الوصول العام للتطبيق"
  default     = true
}

variable "be_app_name" {
  type        = string
  description = "اسم تطبيق الـ Backend في Azure"
}

variable "service_plan_name_be" {
  type        = string
  description = "اسم خطة الخدمة للـ Backend"
}

variable "be_sku" {
  type        = string
  description = "SKU لخطة الخدمة للـ Backend"
  default     = "P1v2"
}

variable "be_image_name" {
  type        = string
  description = "اسم صورة Docker الخاصة بالـ Backend"
}

variable "be_tag" {
  type        = string
  description = "Tag لصورة Docker الخاصة بالـ Backend"
  default     = "latest"
}

variable "sql_admin_password" {
  type        = string
  description = "SQL administrator password"
  sensitive   = true
}

variable "frontend_subnet_id" {
  description = "Subnet ID used for frontend web app VNet integration"
  type        = string
  default     = null
}

variable "backend_subnet_id" {
  description = "Subnet ID used for backend web app VNet integration"
  type        = string
  default     = null
}

variable "frontend_allowed_subnet_id" {
  description = "Subnet allowed to reach the frontend web app"
  type        = string
  default     = null
}

variable "backend_allowed_subnet_id" {
  description = "Subnet allowed to reach the backend web app"
  type        = string
  default     = null
}
