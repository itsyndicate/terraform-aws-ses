# ---------------------------------------------------------------------------------------------------------------------
# This is an example of how to create complete configuration using Terragrunt
# ---------------------------------------------------------------------------------------------------------------------
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/itsyndicate/terraform-aws-ses//."
}

# `dependency` block isn't mandatory; you can set `kinesis_firehose_arn` manually
dependency "delivery_stream" {
  config_path = "../delivery_stream"
}

inputs = {
  # Email Identity
  email_identity          = "domain.com"
  dkim_signing_attributes = {
    next_signing_key_length = "RSA_2048_BIT"
  }
  email_identity_tags       = {
    Name = "domain.com"
  }

  # Email Identity Feedback Attributes
  create_email_identity_feedback_attributes = true
  email_forwarding_enabled                  = true

  # Easy DKIM verification
  verify_easy_dkim_in_route53 = true
  zone_id                     = "ABCDABCDABCDAC"

  # Configuration Set
  create_configuration_set = true
  configuration_set_name   = "domain-com"
  reputation_options       = {
    reputation_metrics_enabled = false
  }
  sending_options          = {
    sending_enabled = true
  }
  configuration_set_tags   = {
    Name = "domain-com"
  }

  # Configuration Set Destination IAM Role
  create_role   = true
  role_name     = "domain-com-publish-to-kdf"
  description   = "Role for the Event Destination of the `domain-com` SES Configuration Set"
  iam_role_tags = {
    Name = "domain-com-publish-to-kdf"
  }

  # IAM policy to allow message publishing into Kinesis Data Firehose
  create_kinesis_data_firehose_policy       = true
  kinesis_data_firehose_policy_name         = "domain-com-publish-to-kdf"
  kinesis_data_firehose_policy_description  = "`domain-com-publish-to-kdf` Role Policy for the Event Destination of the `domain-com` SES Configuration Set"
  kinesis_data_firehose_delivery_stream_arn = "${dependency.delivery_stream.outputs.kinesis_firehose_arn}"
  kinesis_data_firehose_policy_tags         = {
    Name = "domain-com-publish-to-kdf"
  }

  # Configuration Set Destination
  create_event_destination = true
  event_destination_name   = "Kinesis-Data-Firehose"
  event_destination        = {
    enabled                      = true
    matching_event_types         = ["BOUNCE", "CLICK", "COMPLAINT", "DELIVERY", "DELIVERY_DELAY", "OPEN", "REJECT", "RENDERING_FAILURE", "SEND", "SUBSCRIPTION"]
    kinesis_firehose_destination = {
      delivery_stream_arn = "${dependency.delivery_stream.outputs.kinesis_firehose_arn}"
    }
  }

}
