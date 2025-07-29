# Output important information
output "agent_id" {
  description = "The ID of the created Dialogflow CX agent"
  value       = google_dialogflow_cx_agent.agent.id
}

output "agent_name" {
  description = "The name of the created Dialogflow CX agent"
  value       = google_dialogflow_cx_agent.agent.name
}

output "service_account_email" {
  description = "Email of the service account created for the agent"
  value       = google_service_account.dialogflow_sa.email
}

output "agent_uri" {
  description = "URI to access the agent in Google Cloud Console"
  value       = "https://dialogflow.cloud.google.com/cx/projects/${var.project_id}/locations/${var.region}/agents/${google_dialogflow_cx_agent.agent.name}"
}