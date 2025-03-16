# template_s3

Terraform module which creates S3 bucket on AWS with all (or almost all) features provided by Terraform AWS provider.

Parent Repo Link:  https://github.com/cloudeq-EMU-ORG/ceq_tf_module_aws_war_lambda_function_sample.git

These features of S3 bucket configurations are supported:

- static web-site hosting
- access logging
- versioning
- CORS
- lifecycle rules
- server-side encryption
- object locking
- Cross-Region Replication (CRR)
- ELB log delivery bucket policy
- ALB/NLB log delivery bucket policy


## Resources

| Name | Type |
|------|------|
| aws_s3_bucket.this                                                | resource |
| aws_s3_bucket_accelerate_configuration.thiss3_bucket_accelerate_configuration  | resource |
| aws_s3_bucket_acl.this                          | resource |
| aws_s3_bucket_analytics_configuration.this       | resource |
| aws_s3_bucket_cors_configuration.this              | resource |
| aws_s3_bucket_intelligent_tiering_configuration.this          | resource |
| aws_s3_bucket_inventory.this              | resource |
| aws_s3_bucket_lifecycle_configuration.this     | resource |
| aws_s3_bucket_logging.this  | resource |
| aws_s3_bucket_metric.this       | resource |
| aws_s3_bucket_object_lock_configuration.this  | resource |
| aws_s3_bucket_ownership_controls.this  | resource |
| aws_s3_bucket_policy.this  | resource |
| aws_s3_bucket_public_access_block.this  | resource |
| aws_s3_bucket_replication_configuration.this  | resource |
| aws_s3_bucket_request_payment_configuration.this   | resource |
| aws_s3_bucket_server_side_encryption_configuration.this        | resource |
| aws_s3_bucket_versioning.this            | resource |
| aws_s3_bucket_website_configuration.this | resource |

## Inputs

| Name | Description 
|------|-------------|
| acceleration_status       | (Optional) Sets the accelerate configuration of an existing bucket. Can be Enabled or Suspended. |
| access_log_delivery_policy_source_accounts | (Optional) List of AWS Account IDs should be allowed to deliver access logs to this bucket. | 
| access_log_delivery_policy_source_buckets | (Optional) List of S3 bucket ARNs which should be allowed to deliver access logs to this bucket. 
| acl               | (Optional) The canned ACL to apply. |
| input_allowed_kms_key_arn               | The ARN of KMS key which should be allowed in PutObject | 
analytics_configuration     | Map containing bucket analytics configuration. 
| analytics_self_source_destination | Whether or not the analytics source bucket is also the destination bucket. 
| analytics_source_account_id      | The analytics source account id. 
| analytics_source_bucket_arn          | The analytics source bucket ARN. 
| attach_access_log_delivery_policy | Controls if S3 bucket should have S3 access log delivery policy attached 
| attach_analytics_destination_policy | Controls if S3 bucket should have bucket analytics destination policy attached. | 
| attach_deny_incorrect_encryption_headers | Controls if S3 bucket should deny incorrect encryption headers policy attached. | 
| attach_deny_incorrect_kms_key_sse | Controls if S3 bucket policy should deny usage of incorrect KMS key SSE. | 
| attach_deny_insecure_transport_policy | Controls if S3 bucket should have deny non-SSL transport policy attached | 
| attach_deny_unencrypted_object_upload | Controls if S3 bucket should deny unencrypted object uploads policy attached. | 
| attach_elb_log_delivery_policy   | Controls if S3 bucket should have ELB log delivery policy attached | 
| attach_inventory_destination_policy | Controls if S3 bucket should have bucket inventory destination policy attached. |
| attach_lb_log_delivery_policy | Controls if S3 bucket should have ALB/NLB log delivery policy attached |
| attach_policy| Controls if S3 bucket should have bucket policy attached (set to `true` to use value of `policy` as bucket policy) | 
| attach_public_policy | Controls if a user defined public bucket policy will be attached (set to `false` to allow upstream to apply defaults to the bucket) | 
| attach_require_latest_tls_policy | Controls if S3 bucket should require the latest version of TLS 
| block_public_acls | Whether Amazon S3 should block public ACLs for this bucket.
| block_public_policy | Whether Amazon S3 should block public bucket policies for this bucket. | 
| bucket | (Optional, Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name.
| bucket_prefix | (Optional, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket. | 
| control_object_ownership | Whether to manage S3 Bucket Ownership Controls on this bucket. | `
| cors_rule| List of maps containing rules for Cross-Origin Resource Sharing. | 
| create_bucket| Controls if S3 bucket should be created | 
| expected_bucket_owner | The account ID of the expected bucket owner | 
| force_destroy | (Optional, Default:false ) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. |
| grant | An ACL policy grant. Conflicts with `acl` | 
| ignore_public_acls | Whether Amazon S3 should ignore public ACLs for this bucket. | 
| intelligent_tiering| Map containing intelligent tiering configuration. | 
| inventory_configuration | Map containing S3 inventory configuration. 
| inventory_self_source_destination| Whether or not the inventory source bucket is also the destination bucket. | 
| inventory_source_account_id"></a>  | The inventory source account id. 
| inventory_source_bucket_arn | The inventory source bucket ARN. | 
| lifecycle_rule | List of maps containing configuration of object lifecycle management. | 
| logging | Map containing access bucket logging configuration. | 
| object_lock_configuration | Map containing S3 object locking configuration. | 
| object_lock_enabled | Whether S3 bucket should have an Object Lock configuration enabled.
| object_ownership | Object ownership. Valid values: BucketOwnerEnforced, BucketOwnerPreferred or ObjectWriter. 'BucketOwnerEnforced': ACLs are disabled, and the bucket owner automatically owns and has full control over every object in the bucket. 'BucketOwnerPreferred': Objects uploaded to the bucket change ownership to the bucket owner if the objects are uploaded with the bucket-owner-full-control canned ACL. 'ObjectWriter': The uploading account will own the object if the object is uploaded with the bucket-owner-full-control canned ACL. 
| owner                    | Bucket owner's display name and ID. Conflicts with acl |
| policy               | (Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide. |
| input_replication_configuration              | Map containing cross-region replication configuration. | 
| input_request_payer| (Optional) Specifies who should bear the cost of Amazon S3 data transfer. Can be either BucketOwner or Requester. By default, the owner of the S3 bucket would incur the costs of any data transfer. See Requester Pays Buckets developer guide for more information. 
| restrict_public_buckets | Whether Amazon S3 should restrict public bucket policies for this bucket. 
| server_side_encryption_configuration | Map containing server-side encryption configuration. | 
| tags | (Optional) A mapping of tags to assign to the bucket. |
| versioning | Map containing versioning configuration. 
| website | Map containing static web-site hosting or redirect configuration.

## Outputs

| Name | Description |
|------|-------------|
| output_s3_bucket_arn                                  | The ARN of the bucket. |
| output_s3_bucket_bucket_domain_name                   | The bucket domain name. Will be of format bucketname.s3.amazonaws.com. |
| output_s3_bucket_bucket_regional_domain_name          | The bucket region-specific domain name. The bucket domain name including the region name, please refer here for format. Note: The AWS CloudFront allows specifying S3 region-specific endpoint when creating S3 origin, it will prevent redirect issues from CloudFront to S3 Origin URL. |
| output_s3_bucket_hosted_zone_id                        | The Route 53 Hosted Zone ID for this bucket's region. |
| output_s3_bucket_id                              | The name of the bucket. |
| output_s3_bucket_lifecycle_configuration_rules    | The lifecycle rules of the bucket, if the bucket is configured with lifecycle rules. If not, this will be an empty string. |
| output_s3_bucket_policy          | The policy of the bucket, if the bucket is configured with a policy. If not, this will be an empty string. |
| output_s3_bucket_region  | The AWS region this bucket resides in. |
| output_s3_bucket_website_domain | The domain of the website endpoint, if the bucket is configured with a website. If not, this will be an empty string. This is used to create Route 53 alias records. |
| output_s3_bucket_website_endpoint  | The website endpoint, if the bucket is configured with a website. If not, this will be an empty string. |
