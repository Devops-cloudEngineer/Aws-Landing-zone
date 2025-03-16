resource "aws_guardduty_detector" "MyDetector" {
  provider = aws.delegated_admin
  #   count = var.guradduty_enable ? 1 : 0
  enable                       = var.guardduty_enable
  finding_publishing_frequency = var.finding_publishing_frequency

  datasources {
    s3_logs {
      enable = var.enable_s3_logs
    }
    kubernetes {
      audit_logs {
        enable = var.enable_kubernetes_audit_logs
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = var.enable_ebs_volumes_scan
        }
      }
    }
  }
  tags = var.tags
}


#resource "aws_guardduty_detector" "Management_account" {
  #provider = aws
  #   count = var.guradduty_enable ? 1 : 0
  #enable                       = var.guardduty_enable
  #finding_publishing_frequency = var.finding_publishing_frequency

  #datasources {
    #s3_logs {
      #enable = var.enable_s3_logs
    #}
    #kubernetes {
      #audit_logs {
        #enable = var.enable_kubernetes_audit_logs
      #}
    #}
    #malware_protection {
      #scan_ec2_instance_with_findings {
        #ebs_volumes {
          #enable = var.enable_ebs_volumes_scan
        #}
      #}
    #}
  #}
  #tags = var.tags
#}





resource "aws_guardduty_organization_admin_account" "MyGDOrgDelegatedAdmin" {
  provider = aws

  depends_on = [aws_guardduty_detector.MyDetector]

  admin_account_id = var.admin_account_id
}


resource "aws_guardduty_organization_configuration" "example" {
  provider = aws.delegated_admin
  auto_enable_organization_members = var.auto_enable_organization_members

  detector_id = aws_guardduty_detector.MyDetector.id

  depends_on = [aws_guardduty_detector.MyDetector,aws_guardduty_organization_admin_account.MyGDOrgDelegatedAdmin]

  datasources {
    s3_logs {
      auto_enable = var.enable_s3_logs
    }
    kubernetes {
      audit_logs {
        enable = var.enable_kubernetes_audit_logs
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          auto_enable = var.enable_ebs_volumes_scan
        }
      }
    }
  }
}


resource "aws_guardduty_organization_configuration_feature" "eks_runtime_monitoring" {
  depends_on = [ aws_guardduty_detector.MyDetector, aws_guardduty_organization_configuration.example]
  provider = aws.delegated_admin
  count       = var.create_additional_feature ? length(var.additional_feature_name) : 0
  detector_id = aws_guardduty_detector.MyDetector.id
  name        = var.additional_feature_name[count.index]
  auto_enable = var.auto_enable_organization_members
  dynamic "additional_configuration" {
    for_each = (var.additional_feature_name == "EKS_RUNTIME_MONITORING" ||
    var.additional_feature_name == "RUNTIME_MONITORING") ? [1] : []

    content {
      name        = var.additional_configuration_name
      auto_enable = var.auto_enable_organization_members
    }
  }
}


# # Get the current account ID
data "aws_caller_identity" "current" {}
data "aws_organizations_organization" "org" {}

# Create member accounts and send invitations
resource "aws_guardduty_member" "members" {
  provider = aws.delegated_admin
  depends_on                 = [aws_guardduty_organization_admin_account.MyGDOrgDelegatedAdmin , aws_guardduty_detector.MyDetector]
  for_each = var.member_accounts
 #for_each = {
    #for account in data.aws_organizations_organization.org.accounts :
    #account.id => account
    #if account.status == "ACTIVE" && account.id != var.admin_account_id
  #}
  detector_id                = aws_guardduty_detector.MyDetector.id
  account_id                 = each.key
  email                      = each.value.email # Replace with actual email addresses or a dynamic method to set emails
  invite                     = var.invite
  disable_email_notification = var.disable_email_notification
  invitation_message         = var.invitation_message
   lifecycle {
    ignore_changes = [
    invite,
    email
]  # Ignore changes to the invite attribute
  }


}



# Management Account as a GuardDuty Member
resource "aws_guardduty_member" "management_account" {
  depends_on = [ aws_guardduty_detector.MyDetector ]
  provider = aws.delegated_admin
  detector_id                = aws_guardduty_detector.MyDetector.id
  account_id                 = var.management_acc
  email                      = var.management_acc_email
  invite                     = var.invite
  disable_email_notification = var.disable_email_notification
  invitation_message         = var.invitation_message
  lifecycle {
    ignore_changes = [
    invite,
    email
]  # Ignore changes to the invite attribute
  }

}


resource "aws_guardduty_publishing_destination" "pub_dest" {
  provider = aws.delegated_admin
  depends_on = [aws_guardduty_organization_admin_account.MyGDOrgDelegatedAdmin]

  detector_id     = aws_guardduty_detector.MyDetector.id
  destination_arn = var.gd_publishing_dest_bucket_arn
  kms_key_arn     = var.gd_kms_key_arn
}
