# DEVOPS-21: Дипломное задание по профессии «DevOps-инженер»

### Автор: Желобанов Е.Ю.

#### 07 октября 2023 г.

---

## Содержание:
1. [Создание облачной инфраструктуры](#cloud_infrastructure)









## <a name="cloud_infrastructure">1. Создание облачной инфраструктуры</a>
Задание я буду выполнять в Ubuntu server 20.04.4 TLS, которая находится на виртуальной машине VirtualBox хостовой машины с Windows 11.  
Облачную инфраструктуру я подготовлю с помощью Terraform.  
Для начала проверил и обновил terraform до актуальной версии 1.6.0:
```shell
egor@netology-2004:~/diplom$ terraform version
Terraform v1.6.0
on linux_amd64
egor@netology-2004:~/diplom$
```
Поскольку в YC я уже имею аккаунт и каталог `default`, я создам новый каталог `netology-folder` для выполнения дипломной работы. 
Условно, выполнение первого задания можно разделить на следующие пункты:  
* Создание нового каталога в Яндекс.Облаке
* Создание бэкенда в Object Storage Яндекс.Облака
* Создание облачной инфраструктуры (сети и виртуальные машины)

Итак, приступим. Для выполнения первого пункта, я подготовил следующие файлы terraform, и разместил их в каталоге `terraform/01`:
* [01_provider_folder.tf](terraform/01/01_provider_folder.tf)
* [02_service_accounts.tf](terraform/01/02_service_accounts.tf)
* [03_backend_bucket.tf](terraform/01/03_backend_bucket.tf)
* [outputs.tf](terraform/01/outputs.tf)
* [variables.tf](terraform/01/variables.tf)

Переходим в каталог, и выполняем `terraform init`:  
![](/diplom/images/01-tf-init.jpg)  
Далее, подготовил workspaces. Использую альтернативный вариант: использую один workspace, назвав его `stage`:  
![](/diplom/images/02-tf-create-workspace.jpg)  
Видим, что инициализация прошла успешно, выполняю `export TF_VAR_yc_token=$(yc iam create-token)`, чтобы не указывать OAuth-токен в файлах конфигурации, и запускаем команду `terraform apply`:  
