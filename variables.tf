# ---------------------------------------------------------------------------------------------------------------------
# Identity
# ---------------------------------------------------------------------------------------------------------------------

variable "create_identity" {
  type        = bool
  description = "Controls if SES Email Identity should be created"
  default     = true
}

variable "email_identity" {
  type        = string
  description = "The email address or domain to verify"
  default     = null
}

variable "configuration_set_name" {
  type        = string
  description = "The configuration set to use by default when sending from the identity"
  default     = null
}

variable "dkim_signing_attributes" {
  type        = any
  description = "The configuration of the DKIM authentication settings for an email domain identity"
  default     = {}
}

variable "email_identity_tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = null
}

# ---------------------------------------------------------------------------------------------------------------------
# Identity Feedback Attributes
# ---------------------------------------------------------------------------------------------------------------------

variable "create_email_identity_feedback_attributes" {
  type        = bool
  description = "Controls if SES Email Identity Feedback Attributes should be created"
  default     = false
}

variable "email_forwarding_enabled" {
  type        = bool
  description = "Sets the feedback forwarding configuration for the identity"
  default     = false
}

# ---------------------------------------------------------------------------------------------------------------------
# Verify domain indentity in Route53 (Easy DKIM)
# ---------------------------------------------------------------------------------------------------------------------

variable "verify_easy_dkim_in_route53" {
  type        = bool
  description = "Controls if domain identity should be verified (only for Easy DKIM)"
  default     = false
}

variable "zone_id" {
  type        = string
  default     = null
  description = "Route53 host zone ID to enable SES."
}

# ---------------------------------------------------------------------------------------------------------------------
# Configuration Set
# ---------------------------------------------------------------------------------------------------------------------

variable "create_configuration_set" {
  type        = bool
  description = "Controls if default SES Configuration Set should be created"
  default     = false
}

variable "delivery_options" {
  type        = any
  description = "An object that defines the dedicated IP pool that is used to send emails that you send using the configuration set"
  default     = {}
}

variable "tracking_options" {
  type        = any
  description = "An object that defines the open and click tracking options for emails that you send using the configuration set."
  default     = {}
}

variable "reputation_options" {
  type        = any
  description = "An object that defines whether or not Amazon SES collects reputation metrics for the emails that you send that use the configuration set."
  default     = {}
}

variable "sending_options" {
  type        = any
  description = "An object that defines whether or not Amazon SES can send email that you send using the configuration set."
  default     = {}
}

variable "suppression_options" {
  type        = any
  description = "An object that contains information about the suppression list preferences for your account."
  default     = {}
}

variable "vdm_options" {
  type        = any
  description = "An object that defines the VDM settings that apply to emails that you send using the configuration set."
  default     = {}
}

variable "configuration_set_tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = null
}

# ---------------------------------------------------------------------------------------------------------------------
# Configuration Set IAM Role
# ---------------------------------------------------------------------------------------------------------------------

variable "create_role" {
  type        = bool
  description = "Whether to create IAM Role for the Configuration set."
  default     = false
}

variable "role_name" {
  type        = string
  description = "Name of the IAM Role for the Configuration set."
  default     = null
}

variable "role_description" {
  type        = string
  description = "Description of the IAM Role for the Configuration set."
  default     = null
}

variable "force_detach_policies" {
  type        = bool
  description = "Whether to force detaching any policies the role has before destroying it."
  default     = false
}

variable "max_session_duration" {
  type        = number
  description = "Maximum session duration (in seconds) that you want to set for the specified role."
  default     = 3600
}

variable "assume_role_policy" {
  type        = any
  description = "Policy that grants an entity permission to assume the role."
  default     = null
}

variable "role_path" {
  type        = string
  description = "Path to the role."
  default     = "/"
}

variable "role_permissions_boundary" {
  type        = string
  description = "ARN of the policy that is used to set the permissions boundary for the role."
  default     = null
}

variable "iam_role_tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = null
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM policy to allow message publishing into Kinesis Data Firehose
# ---------------------------------------------------------------------------------------------------------------------

variable "create_kinesis_data_firehose_policy" {
  type        = bool
  description = "Whether to create IAM policy to allow message publishing into Kinesis Data Firehose"
  default     = false
}

variable "kinesis_data_firehose_delivery_stream_arn" {
  type        = string
  description = "Kinesis Data Firehose delivery stream ARN"
  default     = null
}

variable "kinesis_data_firehose_policy_name" {
  type        = string
  description = "Kinesis Data Firehose policy name"
  default     = null
}

variable "kinesis_data_firehose_policy_description" {
  type        = string
  description = "Kinesis Data Firehose policy description"
  default     = null
}

variable "kinesis_data_firehose_policy_path" {
  type        = string
  description = "Kinesis Data Firehose policy path"
  default     = "/"
}

variable "kinesis_data_firehose_policy_tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = null
}

# ---------------------------------------------------------------------------------------------------------------------
# Configuration Set Event Destination
# ---------------------------------------------------------------------------------------------------------------------

variable "create_event_destination" {
  type        = bool
  description = "Whether to create Event Destiantion"
  default     = false
}

variable "event_destination_name" {
  type        = string
  description = "A name that identifies the event destination within the configuration set"
  default     = null
}

variable "event_destination" {
  type        = any
  description = "An object that defines the event destination"
  default     = {}
}
