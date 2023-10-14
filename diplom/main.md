# DEVOPS-21: Дипломное задание по профессии «DevOps-инженер»

### Автор: Желобанов Е.Ю.

#### 07 октября 2023 г.

---

## Содержание:
1. [Создание облачной инфраструктуры](#cloud_infrastructure)
2. [Создание Kubernetes кластера](#create_kubernetes_cluster)









## <a name="cloud_infrastructure">1. Создание облачной инфраструктуры</a>

---
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

Переходим в каталог `terraform/01`, и выполняем `terraform init`:  
![](/diplom/images/01/01-tf-init.jpg)  
Далее, подготовил workspaces. Использую альтернативный вариант: использую один workspace, назвав его `stage`:  
![](/diplom/images/01/02-tf-create-workspace.jpg)  
Видим, что инициализация прошла успешно, выполняю `export TF_VAR_yc_token=$(yc iam create-token)`, чтобы не указывать OAuth-токен в файлах конфигурации, и запускаем команду `terraform apply`, весь лог приводить не буду, сделал скрин после запроса terraform и ввода `yes`:  
![](/diplom/images/01/03-tf-apply.jpg)  

Для выполнения следующего шага я подготовил файлы:
* [main.tf](/diplom/terraform/02/main.tf)
* [outputs.tf](/diplom/terraform/02/outputs.tf)
* [variables.tf](/diplom/terraform/02/variables.tf)

Далее переходим в каталог `terraform/02`. Перед началом инициализации, я сохранил в переменные SECRET_KEY и ACCESS_KEY ключи, полученные ранее (чтобы явно не показывать их в файлах конфигурации) и выполнил `export TF_VAR_yc_token=$(yc iam create-token)`.  
Выполняю инициализацию следующей командой: `terraform init -backend-config="access_key=$ACCESS_KEY" -backend-config="secret_key=$SECRET_KEY"`:  
![](/diplom/images/01/04-step-2-init.jpg)  
Выполнил `terraform apply -auto-approve`:  
![](/diplom/images/01/05-step-2-apply.jpg)  
Зашел в панель управления YC в Object Storage, и увидел файл состояний terraform:  
![](/diplom/images/01/06-yc-os-dashboard.jpg)  

Когда у нас готовы каталоги, сервисный аккаунт, Object Storage и хранилище состояний terraform, приступаю к развертыванию облачной инфраструктуры.  
Для этого шага я подготовил следующие файлы конфигурации:
* [main.tf](/diplom/terraform/03/instance/main.tf)
* [1-provider.tf](/diplom/terraform/03/1-provider.tf)
* [2_network.tf](/diplom/terraform/03/2_network.tf)
* [3_private_subnets.tf](/diplom/terraform/03/3_private_subnets.tf)
* [4_vms.tf](/diplom/terraform/03/4_vms.tf)
* [outputs.tf](/diplom/terraform/03/outputs.tf)
* [variables.tf](/diplom/terraform/03/variables.tf)
* [meta.txt](/diplom/terraform/03/meta.txt)

Как и в предыдущих шагах, переходим в каталог `terraform/03`, переменные SECRET_KEY и ACCESS_KEY у меня уже существуют, как и TF_VAR_yc_token. 
Для выполнения задания "Установка и настройка CI/CD" решено использовать TeamCity, поэтому в конфигурацию сразу добавлены две ВМ `teamcity-server` и `teamcity-agent`.
Поэтому сразу выполняю инициализацию командой: `terraform init -backend-config="access_key=$ACCESS_KEY" -backend-config="secret_key=$SECRET_KEY"`:  
![](/diplom/images/01/07-step-3-init.jpg)  
И выбираю нужный мне workspace:  
![](/diplom/images/01/08-step-3-workspace.jpg)  
Выполняю `terraform apply -auto-approve`, весь лог не вместится на скрине, привожу конец лога:  
![](/diplom/images/01/09-step-3-tf-apply.jpg)  
Все необходимые ресурсы созданы, это можно увидеть в дашборде Yandex.Cloud:  
![](/diplom/images/01/10-step-3-resources.jpg)  
И непосредственно 5 виртуальных машин (остановил их в целях уменьшения потребления ресурсов до завтра):  
![](/diplom/images/01/11-step-3-vms.jpg)  
Таким образом, с помощью terraform развернута облачная инфраструктура, которая легко может быть создана или удалена с помощью команд terraform `apply` и `destroy` без каких-либо дополнительных действий.  

P.S. возникла проблема, при которой я не мог подключиться на машины ubuntu с помощью id_rsa ключей по ssh. Решилось указанием ключа `id_ed25519`, небольшим изменением манифеста и добавлением файла [meta.txt](/diplom/terraform/03/meta.txt).  
Сейчас список машин тот-же, изменились IP. Но в процессе выполнения данной работы я планирую выключать ВМ в целях экономии баланса и ресурсов.
Также при выполнении следующего задания, возникли проблемы при развертывании кластера kubernetes с помощью ansible. Проблема решилась переходом на версию Ubuntu 22.04-LTS:  

![](/diplom/images/01/12-step-3-vms-after-recreate.jpg)  


## <a name="create_kubernetes_cluster">2. Создание Kubernetes кластера</a>

---

Создание кластера Kubernetes было решено выполнять с помощью Ansible и Kubespray.  
[Файлы конфигурации находятся здесь](/diplom/ansible), поскольку их получилось много, выводить список я не буду.  

Выполнил команду `ansible-playbook -i inventory/hosts.yaml site.yaml`, процесс начался, но упал с ошибкой о неподходящей версии Ansible на сервере master.  
Выяснил что нужна более свежая версия python. Также возникли проблемы с kubernetes. Было решено при развертывании инфраструктуры в YC использовать `Ubuntu 22.04-LTS`.  

После повторного запуска `ansible-playbook -i inventory/hosts.yaml site.yaml` кластер был создан, на машине с которой я работаю, установлен kubectl, проверяем доступность кластера командой `kubectl get nodes`  
![](/diplom/images/02/01-cluster-installed.jpg)  

Как результат, на 3-х виртуальных машинах Yandex.Cloud был развернут кластер Kubernetes и получен доступ к нему с помощью kubectl, что позволяет управлять кластером и выполнять команды из локального окружения.
Конфигурация для доступа к кластеру хранится в файле `.kube/config` в пользовательском профиле.  

