# Create Service Account
resource "yandex_iam_service_account" "terraform-sa" {
  folder_id   = yandex_resourcemanager_folder.netology-folder.id
  name        = "terraform-sa"
  description = "Service account"
}

# Create Role "editor"
resource "yandex_resourcemanager_folder_iam_binding" "editor" {
  folder_id = yandex_resourcemanager_folder.netology-folder.id
  role      = "editor"
  members   = [
    "serviceAccount:${yandex_iam_service_account.terraform-sa.id}"
  ]
}

# Create Role "storage-admin"
resource "yandex_resourcemanager_folder_iam_binding" "storage-admin" {
  folder_id = yandex_resourcemanager_folder.netology-folder.id
  role      = "storage.admin"
  members   = [
    "serviceAccount:${yandex_iam_service_account.terraform-sa.id}"
  ]
}

# Encription/decryption
resource "yandex_resourcemanager_folder_iam_binding" "encrypterDecrypter" {
  folder_id = yandex_resourcemanager_folder.netology-folder.id
  role      = "kms.keys.encrypterDecrypter"
  members   = [
    "serviceAccount:${yandex_iam_service_account.terraform-sa.id}"
  ]
}

# Create Static Access Key
resource "yandex_iam_service_account_static_access_key" "bucket-static_access_key" {
  service_account_id = yandex_iam_service_account.terraform-sa.id
  description        = "Static access key for Terraform Backend Bucket"
}
