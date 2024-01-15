# ---------------------------------------------------------------------------------------------------------------------
# Identity
# ---------------------------------------------------------------------------------------------------------------------

output "identity_arn" {
  description = "ARN of the Email Identity"
  value       = try(aws_sesv2_email_identity.this[0].arn, "")
}

output "identity_id" {
  description = "ID of the Email Identity"
  value       = try(aws_sesv2_email_identity.this[0].id, "")
}

output "identity_type" {
  description = "Type of the Email Identity"
  value       = try(aws_sesv2_email_identity.this[0].identity_type, "")
}

# ---------------------------------------------------------------------------------------------------------------------
# Configuration Set
# ---------------------------------------------------------------------------------------------------------------------

output "configuration_set_id" {
  description = "Name of the Configuration Set."
  value       = try(aws_sesv2_configuration_set.this[0].id, "")
}

output "configuration_set_arn" {
  description = "ARN of the Configuration Set."
  value       = try(aws_sesv2_configuration_set.this[0].arn, "")
}

# ---------------------------------------------------------------------------------------------------------------------
# Configuration Set IAM Role
# ---------------------------------------------------------------------------------------------------------------------

output "iam_role_id" {
  description = "Name of the IAM Role."
  value       = try(aws_iam_role.this[0].id, "")
}

output "iam_role_arn" {
  description = "ARN of the IAM Role."
  value       = try(aws_iam_role.this[0].arn, "")
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM policy to allow message publishing into Kinesis Data Firehose
# ---------------------------------------------------------------------------------------------------------------------

output "kinesis_data_firehose_policy_arn" {
  description = "ARN of the IAM policy to allow message publishing into Kinesis Data Firehose."
  value       = try(aws_iam_policy.this_kinesis_data_firehose[0].arn, "")
}

# ---------------------------------------------------------------------------------------------------------------------
# Configuration Set Event  Destination
# ---------------------------------------------------------------------------------------------------------------------

output "event_destination_id" {
  description = "Name of the Event Destination."
  value       = try(aws_sesv2_configuration_set_event_destination.this[0].id, "")
}
