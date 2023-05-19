resource "genesyscloud_integration_action" "action" {
    name           = var.action_name
    category       = var.action_category
    integration_id = var.integration_id
    secure         = var.secure_data_action
    
    contract_input  = jsonencode({
        "$schema" = "http://json-schema.org/draft-04/schema#",
        "description" = "Fields needed in the body of the POST to create a query.",
        "properties" = {
            "Interval" = {
                "type" = "string"
            },
            "userId" = {
                "type" = "string"
            }
        },
        "required" = [
            "Interval",
            "userId"
        ],
        "title" = "Query for Active voice conversations.",
        "type" = "object"
    })
    contract_output = jsonencode({
        "$schema" = "http://json-schema.org/draft-04/schema#",
        "description" = "The full response from the analyitics query.",
        "properties" = {
            "conversationId" = {
                "type" = "string"
            }
        },
        "title" = "Analyitics Query Response",
        "type" = "object"
    })
    
    config_request {
        request_template     = "{\n \"interval\": \"$${input.Interval}\",\n \"order\": \"desc\",\n \"orderBy\": \"conversationStart\",\n \"segmentFilters\": [\n  {\n   \"type\": \"and\",\n   \"predicates\": [\n    {\n     \"type\": \"dimension\",\n     \"dimension\": \"userId\",\n     \"operator\": \"matches\",\n     \"value\": \"$${input.userId}\"\n    },\n    {\n     \"type\": \"dimension\",\n     \"dimension\": \"segmentEnd\",\n     \"operator\": \"notExists\",\n     \"value\": null\n    },\n    {\n     \"type\": \"dimension\",\n     \"dimension\": \"mediaType\",\n     \"operator\": \"matches\",\n     \"value\": \"voice\"\n    }\n   ]\n  }\n ]\n}"
        request_type         = "POST"
        request_url_template = "/api/v2/analytics/conversations/details/query"
        headers = {
			Content-Type = "application/json"
		}
    }

    config_response {
        success_template = "{\n   \"conversationId\": $${conversationId}\n}"
        translation_map = { 
			conversationId = "$.conversations[0].conversationId"
		}
        translation_map_defaults = {       
			conversationId = "\"Not Found\""
		}
    }
}