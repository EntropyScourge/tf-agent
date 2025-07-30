# Enable required APIs
resource "google_project_service" "dialogflow_api" {
  service = "dialogflow.googleapis.com"
  
  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_project_service" "cloud_build_api" {
  service = "cloudbuild.googleapis.com"
  
  disable_dependent_services = true
  disable_on_destroy         = false
}

# Create a service account for the Dialogflow agent
resource "google_service_account" "dialogflow_sa" {
  account_id   = "dialogflow-agent-sa"
  display_name = "Dialogflow Agent Service Account"
  description  = "Service account for Dialogflow CX agent operations"
  
  depends_on = [google_project_service.dialogflow_api]
}

# Grant necessary roles to the service account
resource "google_project_iam_member" "dialogflow_sa_client" {
  project = var.project_id
  role    = "roles/dialogflow.client"
  member  = "serviceAccount:${google_service_account.dialogflow_sa.email}"
}

resource "google_project_iam_member" "dialogflow_sa_admin" {
  project = var.project_id
  role    = "roles/dialogflow.admin"
  member  = "serviceAccount:${google_service_account.dialogflow_sa.email}"
}

# Create the Dialogflow CX Agent
resource "google_dialogflow_cx_agent" "agent" {
  display_name               = var.agent_display_name
  location                  = var.region
  default_language_code     = var.default_language_code
  description               = var.agent_description
  time_zone                 = var.time_zone
  
  speech_to_text_settings {
    enable_speech_adaptation = true
  }
  
  depends_on = [
    google_project_service.dialogflow_api,
    google_service_account.dialogflow_sa
  ]
}

# Create a default flow (Start Page)
resource "google_dialogflow_cx_flow" "default_flow" {
  parent       = google_dialogflow_cx_agent.agent.id
  display_name = "Default Start Flow 2"
  description  = "Default flow for the conversational agent"
  
  nlu_settings {
    classification_threshold = 0.3
    model_type              = "MODEL_TYPE_STANDARD"
  }
}

# Create an intent for greeting
resource "google_dialogflow_cx_intent" "greeting_intent" {
  parent       = google_dialogflow_cx_agent.agent.id
  display_name = "greeting"
  priority     = 500000
  
  training_phrases {
    parts {
      text = "hello"
    }
    repeat_count = 1
  }
  
  training_phrases {
    parts {
      text = "hi"
    }
    repeat_count = 1
  }
  
  training_phrases {
    parts {
      text = "good morning"
    }
    repeat_count = 1
  }
  
  training_phrases {
    parts {
      text = "hey"
    }
    repeat_count = 1
  }
}

# Create a page with fulfillment for greeting
resource "google_dialogflow_cx_page" "greeting_page" {
  parent       = google_dialogflow_cx_flow.default_flow.id
  display_name = "Greeting Page"
  
  entry_fulfillment {
    messages {
      text {
        text = ["Hello! How can I help you today?", "Hi there! What can I do for you?"]
      }
    }
  }
  
  transition_routes {
    intent = google_dialogflow_cx_intent.greeting_intent.id
    trigger_fulfillment {
      messages {
        text {
          text = ["Hello! Nice to meet you. How can I assist you today?"]
        }
      }
    }
  }
}

# Create an entity type (optional - for more complex conversations)
resource "google_dialogflow_cx_entity_type" "product_entity" {
  parent       = google_dialogflow_cx_agent.agent.id
  display_name = "product"
  kind         = "KIND_MAP"
  
  entities {
    value = "laptop"
    synonyms = ["laptop", "computer", "notebook"]
  }
  
  entities {
    value = "phone"
    synonyms = ["phone", "smartphone", "mobile"]
  }
}

# Create a version
resource "google_dialogflow_cx_version" "version_1" {
  parent       = google_dialogflow_cx_flow.default_flow.id
  display_name = "Version 1.0"
  description  = "Initial version of the conversational agent"
}

# Create environment for testing
resource "google_dialogflow_cx_environment" "development" {
  parent       = google_dialogflow_cx_agent.agent.id
  display_name = "Development"
  description  = "Development environment for testing"
  
  version_configs {
    version = google_dialogflow_cx_version.version_1.id
  }
}
