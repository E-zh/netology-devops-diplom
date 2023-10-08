# KMS symmetric key for Storage Bucket.
resource "yandex_kms_symmetric_key" "key-a" {
  folder_id         = yandex_resourcemanager_folder.netology-folder.id
  name              = "symmetric-key"
  description       = "Simmetric key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h"
  lifecycle {
    prevent_destroy = false
  }
}

# Create Storage Bucket.
resource "yandex_storage_bucket" "backend-encrypted" {
  bucket     = var.backend_bucket_id
  access_key = yandex_iam_service_account_static_access_key.bucket-static_access_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.bucket-static_access_key.secret_key

  anonymous_access_flags {
    read = false
    list = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.key-a.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}
