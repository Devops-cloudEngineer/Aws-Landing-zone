#Region
region = "us-east-1"

# Tags
tags = {
  START_DATE      = "23-09-2024"
  END_DATE        = "04-10-2024"
  PROJECT_NAME     = "AWS LANDING ZONE"
  DEPARTMENT_NAME  = "AWS DEVOPS"
  APPLICATION_NAME = "AWS-Org"
  CLIENT_NAME       = "CEQ-INTERNAL"
  OWNER_NAME       = "suraj.kaul@cloudeq.com"
}
# Organizational Units
#Creates OU under Parent OU.
organizational_units = {
  WORKLOAD = {
    parent_name = ""  ### Parent OU ###
    tags = {
      "Department" = "Test"
    }
  }

  SDLC = {
    parent_name = "WORKLOAD"  ### Child OU  ###
    tags = {
      "Department" = "sdlc"
    }
  }
  PROD = {
    parent_name = "WORKLOAD"  ### Child OU ###
    tags = {
      "Department" = "prod"
    }
  }
 SERUCITY = {
    parent_name = "" ### Parent OU  ###
    tags = {
      "Department" = "Security"
    }
  }
  INFRASTRUCTURE = {
    parent_name = "SERUCITY" ### Parent OU ###
    tags = {
      "Department" = "Infrastructure"
    }
  }
 SANDBOX = {
    parent_name = "" ### Parent OU ###
    tags = {
      "Department" = "sandbox"
    }
  }
}

#--------Creates Sub-OU under OU ----------#

  

aws_service_access_principals = [
  "backup.amazonaws.com",
  #"member.org.stacksets.cloudformation.amazonaws.com",
  #"cloudtrail.amazonaws.com",
  #"compute-optimizer.amazonaws.com",
  #"config.amazonaws.com"
]

# AWS Accounts
# whether to create delegated config account or not 
delegated_config  = true   # whether to create delegated config account or not 
delegated_config_account   = "154292417400"
service_principal_config = "config.amazonaws.com"  



#-------------------------SCP POLICIES------------------------------#
## Here we can create multiple SCP policies and attach policiy to required target
 scp_policies = [{
      name        = "Denyec21"
      description = "Deny access to S3 service"
      content     = {
        "Version" : "2012-10-17",
        "Statement" : [{
          "Effect" : "Deny",
          "Action" : "ec2:*",
          "Resource" : "*"
        }]
      }
      target_ids = "864981756572"
    }
  ]
 #----------------------SSP PERMISSION SETS--------------------------------#
 #Here we are creating sso permission sets and attaching inline , AWS Managed policy and Customer managed policy
 # For Inline Policy we have to pass JSON
 # For Policy attachement we have to pass arns of AWS Managed policy or Customer Managed Policy
 # For customer_managed_policy_attachments, If we are creating policy from Terraform module then we have to pass name of policy and refrence
 permission_sets = [
    {
      name               = "AdministratorAccess1",
      description        = "Allow Full Access to the account",
      relay_state        = "",
      session_duration   = "",
      inline_policy      = "",
      policy_attachments = ["arn:aws:iam::aws:policy/AdministratorAccess"]
      customer_managed_policy_attachments = []
    }
  ]

#------------------------ CloudTrail Variables------------------------------#
# Create Cloudtrail on organization to monitor all the activity and event for all Accounts  

name = "Root-account-wafr"
#email                             = "suraj.kaul@cloudeq.com"
s3_key_prefix                     = null
enable_cloudwatch_logs            = true
cloudwatch_logs_retention_in_days = 365
enable_logging                    = true
enable_log_file_validation        = true
include_global_service_events     = true
is_multi_region_trail             = true
is_organization_trail             = true
event_selectors                   = []
insight_selectors                 = []


######## Alert root account ####
alarm_namespace = "CISBenchmark"
alarm_prefix = ""
root_usage = true
alarm_description = "Monitoring for root account logins will provide visibility into the use of a fully privileged account and an opportunity to reduce the use of it."
threshold = 1
statistic = "Sum"
period  = 300
comparison_operator =  "GreaterThanOrEqualToThreshold"
evaluation_periods  = 1
metric_name = "RootUsage"

#-------------S3 Inputs----------------#

s3_variable = {
  "cloudtrail" = {
    bucket_name = "wafr-cloudtrail-bucket1"
    force_destroy = true
     }

  #  "guard_duty" = {
  #     bucket_name = "wafr-guardduty-bucket"
  #     force_destroy = true
        
  #   }
    "config" = {
      bucket_name = "wafr-config-bucket"
      force_destroy = true
        
    }
  
}
#-------------------SNS  Inputs-------------#

sns_variable ={
 "cloudtrail"= {
     sns_topic_name = "wafr_cloudtrail_sns_topic"
     subscriptions = {
      "0" ={
        protocol = "email"
        endpoint  = "suraj.kaul@cloudeq.com" 
          }
           }
    }
  "billing_alarm"= {
     sns_topic_name = "wafr_billing_alarm_sns_topic"
     subscriptions = {
      "0" ={
        protocol = "email"
        endpoint  = "suraj.kaul@cloudeq.com" 
          }
           }
    }
 "config"= {
     sns_topic_name = "wafr_config_sns_topic"
     subscriptions = {
      "0" ={
        protocol = "email"
        endpoint  = "suraj.kaul@cloudeq.com" 
          }
           }
    }

 
}


#------------------ Guard Duty Inputse--------------------------------#

#Creating Guard duty for organization to monitor all Accounts, Adding additional features to guard from a main admin account#

guardduty_enable                 = true
admin_account_id                 = "154292417400"
auto_enable_organization_members = "NEW"
create_additional_feature        = true
additional_feature_name          = ["RUNTIME_MONITORING", "RDS_LOGIN_EVENTS", "LAMBDA_NETWORK_LOGS"]
management_acc = "864981756572"
management_acc_email = "ceq-wafr@cloudeq.com"
member_accounts = {
  "529088275969" = { email = "Mohammad.khan+dev3@cloudeq.com" }
}


#---------------Billing Inputs------------------------#
#creating billing alarms in new accounts to closely monitor the bills which are getting generated and check the usage accordingly.
alarm_name                  = "wafr-billing-alarm"
billing_comparison_operator = "GreaterThanOrEqualToThreshold"
currency                    = "USD"
#email_addresses             = ["suraj.kaul@cloudeq.com"]
billing_evaluation_periods  = "1"
billing_metric_name         = "EstimatedCharges"
namespace                   = "AWS/Billing"
protocol                    = "email"
sns_topic_name               = "wafr_billing_alarm_sns_topic"
billing_statistic           = "Maximum"
monthly_billing_threshold   =  0.01

#----------------Security Hub Input----------------#
#Input Delegated Account ID and Member accounts on which we want securitiy hub to be enabled.
delegated_admin_id = "154292417400"  # Replace with your delegated admin account ID
member_account_ids = [
    "529088275969",
   # "154292417400"
]
#Provide optional Arguments during enabling securiy hub .
enable_default_standards  = true
auto_enable_controls        = true
auto_enable_security_hub    = true




# #----------------------Config Inputs---------------------------#
 create_iam_role = true
 confi_name = "wafr-config"
 global_resource_collector_region = "us-east-1"
 central_resource_collector_account = "154292417400"
 account_aggregation_source = {
   account_ids = []
   regions     = ["us-east-1"]
 }
 delivery_bucket_name = "wafr-config-bucket"
 #account_id =  "529088275969"
 #child_resource_collector_accounts = ["154292417400"]
 create_organization_aggregator_iam_role = true
 #is_organization_aggregator = true
 #member_account_id = "154292417400"



