# ---------------------------------------------------------------------------------------------------------------------
# Data Sources
# ---------------------------------------------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

# ---------------------------------------------------------------------------------------------------------------------
# Identity
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_sesv2_email_identity" "this" {
  count = var.create_identity ? 1 : 0

  email_identity         = var.email_identity
  configuration_set_name = try(aws_sesv2_configuration_set.this[0].id, null)

  dynamic "dkim_signing_attributes" {
    for_each = length(keys(var.dkim_signing_attributes)) == 0 ? [] : [var.dkim_signing_attributes]

    content {
      domain_signing_private_key = lookup(dkim_signing_attributes.value, "domain_signing_private_key", null)
      domain_signing_selector    = lookup(dkim_signing_attributes.value, "domain_signing_selector", null)
      next_signing_key_length    = lookup(dkim_signing_attributes.value, "next_signing_key_length", null)

    }
  }

  tags = var.email_identity_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Identity Feedback Attributes
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_sesv2_email_identity_feedback_attributes" "this" {
  count = var.create_email_identity_feedback_attributes ? 1 : 0

  email_identity           = aws_sesv2_email_identity.this[0].email_identity
  email_forwarding_enabled = var.email_forwarding_enabled
}

# -------------------------------------------------------------------------------------------------------------------------------------------------
# Verify domain indentity in Route53 (only works for the 'DOMAIN' identity type & Easy DKIM). For other DNS providers perform verification manually
# -------------------------------------------------------------------------------------------------------------------------------------------------

resource "aws_route53_record" "this" {
  count = var.verify_easy_dkim_in_route53 ? 3 : 0

  zone_id = var.zone_id
  name    = format("%s._domainkey.%s", element(aws_sesv2_email_identity.this[0].dkim_signing_attributes[0].tokens, count.index), var.email_identity)
  type    = "CNAME"
  ttl     = 1800
  records = [format("%s.dkim.amazonses.com", element(aws_sesv2_email_identity.this[0].dkim_signing_attributes[0].tokens, count.index))]

}

# ---------------------------------------------------------------------------------------------------------------------
# Configuration Set
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_sesv2_configuration_set" "this" {
  count = var.create_configuration_set ? 1 : 0

  configuration_set_name = var.configuration_set_name

  dynamic "delivery_options" {
    for_each = length(keys(var.delivery_options)) == 0 ? [] : [var.delivery_options]

    content {
      sending_pool_name = lookup(delivery_options.value, "sending_pool_name", null)
      tls_policy        = lookup(delivery_options.value, "tls_policy", null)
    }
  }

  dynamic "tracking_options" {
    for_each = length(keys(var.tracking_options)) == 0 ? [] : [var.tracking_options]

    content {
      custom_redirect_domain = tracking_options.value["custom_redirect_domain"]
    }
  }

  dynamic "reputation_options" {
    for_each = length(keys(var.reputation_options)) == 0 ? [] : [var.reputation_options]

    content {
      reputation_metrics_enabled = lookup(reputation_options.value, "reputation_metrics_enabled", false)
    }
  }

  dynamic "sending_options" {
    for_each = length(keys(var.sending_options)) == 0 ? [] : [var.sending_options]

    content {
      sending_enabled = lookup(sending_options.value, "sending_enabled", true)
    }
  }

  dynamic "suppression_options" {
    for_each = length(keys(var.suppression_options)) == 0 ? [] : [var.suppression_options]

    content {
      suppressed_reasons = lookup(suppression_options.value, "suppressed_reasons", null)
    }
  }

  dynamic "vdm_options" {
    for_each = length(keys(var.vdm_options)) == 0 ? [] : [var.vdm_options]

    content {
      dynamic "dashboard_options" {
        for_each = length(keys(lookup(vdm_options.value, "dashboard_options", {}))) == 0 ? [] : [lookup(vdm_options.value, "dashboard_options", {})]

        content {
          engagement_metrics = lookup(dashboard_options.value, "engagement_metrics", null)
        }
      }

      dynamic "guardian_options" {
        for_each = length(keys(lookup(vdm_options.value, "guardian_options", {}))) == 0 ? [] : [lookup(vdm_options.value, "guardian_options", {})]

        content {
          optimized_shared_delivery = lookup(guardian_options.value, "optimized_shared_delivery", null)
        }
      }
    }
  }

  tags = var.configuration_set_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Configuration Set Event Destination IAM Role (currently, the module supports only KDF destination)
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "this" {
  count = var.create_role ? 1 : 0

  name                  = var.role_name
  description           = var.role_description
  force_detach_policies = var.force_detach_policies
  max_session_duration  = var.max_session_duration
  assume_role_policy    = data.aws_iam_policy_document.this_ses_assume_kinesis_data_firehose[0].json
  path                  = var.role_path
  permissions_boundary  = var.role_permissions_boundary
  tags                  = var.iam_role_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM policy to allow message publishing into Kinesis Data Firehose
# ---------------------------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "this_kinesis_data_firehose" {
  count = var.create_kinesis_data_firehose_policy ? 1 : 0

  version = "2012-10-17"
  statement {
    sid    = "PublishToKinesisDataFirehose"
    effect = "Allow"
    actions = [
      "firehose:PutRecordBatch",
    ]
    resources = [
      var.kinesis_data_firehose_delivery_stream_arn,
    ]
  }
}

data "aws_iam_policy_document" "this_ses_assume_kinesis_data_firehose" {
  count = var.create_kinesis_data_firehose_policy ? 1 : 0

  version = "2012-10-17"
  statement {
    sid    = "AllowAmazonSESToAssumeTheRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "ses.amazonaws.com",
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values = [
        aws_sesv2_configuration_set.this[0].arn,
      ]
    }
  }
}

resource "aws_iam_policy" "this_kinesis_data_firehose" {
  count = var.create_kinesis_data_firehose_policy ? 1 : 0

  name        = var.kinesis_data_firehose_policy_name
  description = var.kinesis_data_firehose_policy_description
  path        = var.kinesis_data_firehose_policy_path
  policy      = data.aws_iam_policy_document.this_kinesis_data_firehose[0].json
  tags        = var.kinesis_data_firehose_policy_tags
}

resource "aws_iam_role_policy_attachment" "this_kinesis_data_firehose" {
  count = var.create_kinesis_data_firehose_policy ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this_kinesis_data_firehose[0].arn
}

# ---------------------------------------------------------------------------------------------------------------------
# Configuration Set Event Destination (currently, the module supports only KDF destination)
# ---------------------------------------------------------------------------------------------------------------------

# `time_sleep` is used due to unresolved bug - https://github.com/hashicorp/terraform-provider-aws/issues/33367
resource "time_sleep" "wait_120_seconds" {
  depends_on = [aws_iam_role_policy_attachment.this_kinesis_data_firehose]

  create_duration = "120s"
}

resource "aws_sesv2_configuration_set_event_destination" "this" {
  count = var.create_event_destination ? 1 : 0

  configuration_set_name = aws_sesv2_configuration_set.this[0].id
  event_destination_name = var.event_destination_name
  dynamic "event_destination" {
    for_each = [var.event_destination]

    content {
      enabled              = lookup(event_destination.value, "enabled", false)
      matching_event_types = event_destination.value["matching_event_types"]

      dynamic "kinesis_firehose_destination" {
        for_each = length(keys(lookup(event_destination.value, "kinesis_firehose_destination", {}))) == 0 ? [] : [lookup(event_destination.value, "kinesis_firehose_destination", {})]
        content {
          delivery_stream_arn = kinesis_firehose_destination.value["delivery_stream_arn"]
          iam_role_arn        = lookup(kinesis_firehose_destination.value, "iam_role_arn", aws_iam_role.this[0].arn)
        }
      }
    }
  }

  depends_on = [time_sleep.wait_120_seconds]
}
