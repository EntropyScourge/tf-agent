# Variables
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "agent_display_name" {
  description = "Display name for the Dialogflow CX agent"
  type        = string
  default     = "My Conversational Agent"
}

variable "agent_description" {
  description = "Description for the Dialogflow CX agent"
  type        = string
  default     = "A conversational agent created with Terraform"
}

variable "default_language_code" {
  description = "Default language code for the agent"
  type        = string
  default     = "en"
}

variable "time_zone" {
  description = "Time zone for the agent"
  type        = string
  default     = "America/New_York"
}

