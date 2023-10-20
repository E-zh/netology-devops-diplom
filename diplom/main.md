# DEVOPS-21: Дипломное задание по профессии «DevOps-инженер»

### Автор: Желобанов Е.Ю.

#### 07 октября 2023 г.

---

## Содержание:
### 1. [Создание облачной инфраструктуры](#cloud_infrastructure)
### 2. [Создание Kubernetes кластера](#create_kubernetes_cluster)
### 3. [Создание тестового приложения](#create_test_application)
### 4. [Подготовка системы мониторинга и деплой приложения](#monitoring_deploy_apps)
### 5. [Установка и настройка CI/CD](#ci_cd)
### 6. [Проверка работоспособности](#test_run)
### 7. [Заключение. Ссылки на репозитории и сервисы](#completed)


## <a name="cloud_infrastructure">1. Создание облачной инфраструктуры</a>

---
Задание я буду выполнять в Ubuntu server 20.04.4 TLS, которая находится на виртуальной машине VirtualBox хостовой машины с Windows 11.  
Облачную инфраструктуру я подготовлю с помощью Terraform.  
Для начала проверил и обновил terraform до актуальной версии 1.5.5:
```shell
egor@netology-2004:~/diplom$ terraform version
Terraform v1.5.5
on linux_amd64

Your version of Terraform is out of date! The latest version
is 1.6.1. You can update by downloading from https://www.terraform.io/downloads.html
egor@netology-2004:~/diplom$
```
P.S. Перейти на версию 1.5.5 пришлось по причине появления ошибки на версии 1.6.0, которую я так и не смог победить:
```shell
Initializing the backend...
╷
│ Warning: Deprecated Parameter
│
│   on main.tf line 11, in terraform:
│   11:     endpoint                    = "storage.yandexcloud.net"
│
│ The parameter "endpoint" is deprecated. Use parameter "endpoints.s3" instead.
╵

╷
│ Error: Invalid Value
│
│   on main.tf line 11, in terraform:
│   11:     endpoint                    = "storage.yandexcloud.net"
│
│ The value must be a valid URL containing at least a scheme and hostname. Had "storage.yandexcloud.net"
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

[Git-репозиторий конфигурации развертывания инфраструктуры с помощью Terraform](https://github.com/E-zh/netology-yc-infrastructure.git)


## <a name="create_kubernetes_cluster">2. Создание Kubernetes кластера</a>

---

Создание кластера Kubernetes было решено выполнять с помощью Ansible и Kubespray.  
[Файлы конфигурации находятся здесь](/diplom/ansible), поскольку их получилось много, выводить список я не буду.  

Выполнил команду `ansible-playbook -i inventory/hosts.yaml site.yaml`, процесс начался, но упал с ошибкой о неподходящей версии Ansible на сервере master.  
Выяснил что нужна более свежая версия python. Также возникли проблемы с kubernetes. Было решено при развертывании инфраструктуры в YC использовать `Ubuntu 22.04-LTS`.  

После повторного запуска `ansible-playbook -i inventory/hosts.yaml site.yaml` кластер был создан, на машине с которой я работаю, установлен kubectl, проверяем доступность кластера командой `kubectl get nodes`  
![](/diplom/images/02/01-cluster-installed.jpg)  
Результат выполнения команды `kubectl get pods --all-namespaces`:  
![](/diplom/images/02/02-cluster-get-all-pods.jpg)  

Как результат, на 3-х виртуальных машинах Yandex.Cloud был развернут кластер Kubernetes и получен доступ к нему с помощью kubectl, что позволяет управлять кластером и выполнять команды из локального окружения.
Конфигурация для доступа к кластеру хранится в файле `.kube/config` в пользовательском профиле.  

[Git-репозиторий создания Kubernetes кластера с помощью Ansible](https://github.com/E-zh/netology-yc-kubernetes-cluster.git)

## <a name="create_test_application">3. Создание тестового приложения</a>

---

Подготовил простейшее web приложение, состоящее из одной страницы.  
Данное приложение будет контейнезировано с помощью Docker.  
В результате получено два файла:
* [Dockerfile](/diplom/web-application/Dockerfile)
* [index.html](/diplom/web-application/index.html)

Теперь необходимо собрать образ, для чего выполняем команду `docker build -t egorz/netology-diploma-web-app:1.0 .`:  
![](/diplom/images/03/01-docker-build.jpg)  
Образ собран, выполняем команду `docker image ls` и видим что образ присутствует в репозитории:  
![](/diplom/images/03/02-docker-image-ls.jpg)  
Для проверки запустил образ локально командой `docker run --network host egorz/netology-diploma-web-app:1.0`:  
![](/diplom/images/03/03-docker-run-local.jpg)  
И перешел в хостовой машине в браузере по адресу `192.168.1.50`:  
![](/diplom/images/03/04-nginx-local.jpg)    

Как видно из скриншотов, nginx работает и отображается наша веб-страница.

Далее сохраним образ в репозитории [DockerHub](https://hub.docker.com/). Я не буду описывать весь процесс, учетная запись у меня имеется, авторизовался в консоли и выполнил команду `docker push egorz/netology-diploma-web-app:1.0`:  
![](/diplom/images/03/05-docker-push.jpg)  
Переходим в профиль на DockerHub и видим наш запушеный образ тестового приложения:  
![](/diplom/images/03/06-dockerhub-image.jpg)


Образ приложения `egorz/netology-diploma-web-app:1.0` [доступен по ссылке на DockerHub](https://hub.docker.com/r/egorz/netology-diploma-web-app).

[Git-репозиторий приложения](https://github.com/E-zh/netology-yc-web-app.git)

В этом задании я создал простое web-приложение, собрал образ docker и разместил его в DockerHub.


## <a name="monitoring_deploy_apps">4. Подготовка системы мониторинга и деплой приложения</a>

---

Разворачивать систему мониторинга в кластере я буду с помощью пакета [Kube-Prometheus](https://github.com/prometheus-operator/kube-prometheus).  
Для начала потребовалось установить Golang - `sudo apt install golang`. Установленная версия `go` - go1.13.8  
Далее создал каталог `kube-prometheus`, перешел в него и выполнил ` go install -a github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb` для установки пакета `jsonnet-bundler`:  
![](/diplom/images/04/01-install-jsonnet-bundler.jpg)  
Далее выполнил `jb init`, и `jb install github.com/prometheus-operator/kube-prometheus/jsonnet/kube-prometheus@main`:  
![](/diplom/images/04/02-jb-installkube-prometheus.jpg)  
Далее скачал файлы `example.jsonnet` и `build.sh`:  
![](/diplom/images/04/03-download-jsonnet-example.jpg)  
Файл `build.sh` сделал исполняемым выполнив `chmod u+x build.sh`, и обновил зависимости для kube-prometheus, выполнив `jb update`:  
![](/diplom/images/04/04-jb-update.jpg)  
Перед компиляцией дополнительно установил пакеты `gojsontoyaml` и `jsonnet`:  
![](/diplom/images/04/05-install-packages.jpg)  
И выполнил команду `./build.sh sys-monitoring.jsonnet`:  
![](/diplom/images/04/06-run-build-sh.jpg)  

В результате в папке [manifests](/diplom/kube-prometheus/manifests) получаем набор манифестов для разворачивания системы мониторинга.

Теперь переходим в папку `kube-prometheus` и создадим пространство имен и CRD (Custom Resource Definition), выполнив команду `kubectl apply --server-side -f manifests/setup`:  
![](/diplom/images/04/07-kubectl-server-side.jpg)  
И далее запускаем непосредственно развертывание системы мониторинга командой `kubectl apply -f manifests`, лог получился большой, и к сожалению сделать скриншот не получится:  
```shell
egor@netology-2004:~/diploma/kube-prometheus$ kubectl apply -f manifests
alertmanager.monitoring.coreos.com/main created
networkpolicy.networking.k8s.io/alertmanager-main created
poddisruptionbudget.policy/alertmanager-main created
prometheusrule.monitoring.coreos.com/alertmanager-main-rules created
secret/alertmanager-main created
service/alertmanager-main created
serviceaccount/alertmanager-main created
servicemonitor.monitoring.coreos.com/alertmanager-main created
clusterrole.rbac.authorization.k8s.io/blackbox-exporter created
clusterrolebinding.rbac.authorization.k8s.io/blackbox-exporter created
configmap/blackbox-exporter-configuration created
deployment.apps/blackbox-exporter created
networkpolicy.networking.k8s.io/blackbox-exporter created
service/blackbox-exporter created
serviceaccount/blackbox-exporter created
servicemonitor.monitoring.coreos.com/blackbox-exporter created
secret/grafana-config created
secret/grafana-datasources created
configmap/grafana-dashboard-alertmanager-overview created
configmap/grafana-dashboard-apiserver created
configmap/grafana-dashboard-cluster-total created
configmap/grafana-dashboard-controller-manager created
configmap/grafana-dashboard-grafana-overview created
configmap/grafana-dashboard-k8s-resources-cluster created
configmap/grafana-dashboard-k8s-resources-multicluster created
configmap/grafana-dashboard-k8s-resources-namespace created
configmap/grafana-dashboard-k8s-resources-node created
configmap/grafana-dashboard-k8s-resources-pod created
configmap/grafana-dashboard-k8s-resources-workload created
configmap/grafana-dashboard-k8s-resources-workloads-namespace created
configmap/grafana-dashboard-kubelet created
configmap/grafana-dashboard-namespace-by-pod created
configmap/grafana-dashboard-namespace-by-workload created
configmap/grafana-dashboard-node-cluster-rsrc-use created
configmap/grafana-dashboard-node-rsrc-use created
configmap/grafana-dashboard-nodes-darwin created
configmap/grafana-dashboard-nodes created
configmap/grafana-dashboard-persistentvolumesusage created
configmap/grafana-dashboard-pod-total created
configmap/grafana-dashboard-prometheus-remote-write created
configmap/grafana-dashboard-prometheus created
configmap/grafana-dashboard-proxy created
configmap/grafana-dashboard-scheduler created
configmap/grafana-dashboard-workload-total created
configmap/grafana-dashboards created
deployment.apps/grafana created
networkpolicy.networking.k8s.io/grafana created
prometheusrule.monitoring.coreos.com/grafana-rules created
service/grafana created
serviceaccount/grafana created
servicemonitor.monitoring.coreos.com/grafana created
prometheusrule.monitoring.coreos.com/kube-prometheus-rules created
clusterrole.rbac.authorization.k8s.io/kube-state-metrics created
clusterrolebinding.rbac.authorization.k8s.io/kube-state-metrics created
deployment.apps/kube-state-metrics created
networkpolicy.networking.k8s.io/kube-state-metrics created
prometheusrule.monitoring.coreos.com/kube-state-metrics-rules created
service/kube-state-metrics created
serviceaccount/kube-state-metrics created
servicemonitor.monitoring.coreos.com/kube-state-metrics created
prometheusrule.monitoring.coreos.com/kubernetes-monitoring-rules created
servicemonitor.monitoring.coreos.com/kube-apiserver created
servicemonitor.monitoring.coreos.com/coredns created
servicemonitor.monitoring.coreos.com/kube-controller-manager created
servicemonitor.monitoring.coreos.com/kube-scheduler created
servicemonitor.monitoring.coreos.com/kubelet created
clusterrole.rbac.authorization.k8s.io/node-exporter created
clusterrolebinding.rbac.authorization.k8s.io/node-exporter created
daemonset.apps/node-exporter created
networkpolicy.networking.k8s.io/node-exporter created
prometheusrule.monitoring.coreos.com/node-exporter-rules created
service/node-exporter created
serviceaccount/node-exporter created
servicemonitor.monitoring.coreos.com/node-exporter created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created
clusterrole.rbac.authorization.k8s.io/prometheus-adapter created
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrolebinding.rbac.authorization.k8s.io/prometheus-adapter created
clusterrolebinding.rbac.authorization.k8s.io/resource-metrics:system:auth-delegator created
clusterrole.rbac.authorization.k8s.io/resource-metrics-server-resources created
configmap/adapter-config created
deployment.apps/prometheus-adapter created
networkpolicy.networking.k8s.io/prometheus-adapter created
poddisruptionbudget.policy/prometheus-adapter created
rolebinding.rbac.authorization.k8s.io/resource-metrics-auth-reader created
service/prometheus-adapter created
serviceaccount/prometheus-adapter created
servicemonitor.monitoring.coreos.com/prometheus-adapter created
clusterrole.rbac.authorization.k8s.io/prometheus-k8s created
clusterrolebinding.rbac.authorization.k8s.io/prometheus-k8s created
networkpolicy.networking.k8s.io/prometheus-k8s created
prometheusrule.monitoring.coreos.com/prometheus-operator-rules created
servicemonitor.monitoring.coreos.com/prometheus-operator created
poddisruptionbudget.policy/prometheus-k8s created
prometheus.monitoring.coreos.com/k8s created
prometheusrule.monitoring.coreos.com/prometheus-k8s-prometheus-rules created
rolebinding.rbac.authorization.k8s.io/prometheus-k8s-config created
rolebinding.rbac.authorization.k8s.io/prometheus-k8s created
rolebinding.rbac.authorization.k8s.io/prometheus-k8s created
rolebinding.rbac.authorization.k8s.io/prometheus-k8s created
role.rbac.authorization.k8s.io/prometheus-k8s-config created
role.rbac.authorization.k8s.io/prometheus-k8s created
role.rbac.authorization.k8s.io/prometheus-k8s created
role.rbac.authorization.k8s.io/prometheus-k8s created
service/prometheus-k8s created
serviceaccount/prometheus-k8s created
servicemonitor.monitoring.coreos.com/prometheus-k8s created
```  
Проверяем систему следующими командами:  
![](/diplom/images/04/08-kubectl-get-alls.jpg)  
Теперь нужно предоставить доступ к Grafana снаружи, через интернет. Для этого я использую NodePort.  
В созданном каталоге [kube-prometheus-node-port](/diplom/kube-prometheus-node-port) я подготовил следующие файлы:  
* [grafana-network-policy.yaml](/diplom/kube-prometheus-node-port/grafana-network-policy.yaml)
* [node-port-grafana.yaml](/diplom/kube-prometheus-node-port/node-port-grafana.yaml)

И применяем их. Смотрим и видим что у нас появился сервис `nodeport-grafana` с типом `NodePort`:  
![](/diplom/images/04/09-nodeport-running.jpg)  
Т.к. я прописал `nodePort: 30300`, пробуем перейти по адресам нод + порт 30300, соответственно `84.201.160.70:30300` и `51.250.38.95:30300`:  
![](/diplom/images/04/10-grafana-web-access.jpg)  
Как видно, Grafana доступна по адресам обеих нод на порту `30300`, привожу также адреса нод, т.к. я уже выключал ВМ и адреса изменились:  
![](/diplom/images/04/11-nodes-address.jpg)  


Далее я разверну наше простое приложение в кластере Kubernetes.  
Для этого я буду использовать Helm, чтобы в дальнейшем иметь возможность шаблонизировать манифесты и организовать установку приложений из репозитория.  
Командой `helm create web-application` создал заготовку и удалил из нее все лишние папки и файлы.  
Конечный вариант после необходимых настроек расположен в папке [helm/web-application](/diplom/helm/web-application).  

Выполняю установку приложения командой `helm install web-application web-application`:  
![](/diplom/images/04/12-helm-install-web-app.jpg)  
Приложение развернуто в нашем кластере и с помощью NodePort доступно по адресу любой ноды кластера на порту 30100:  
![](/diplom/images/04/13-running-app-in-cluster.jpg)  
Также привожу скрин запроса списка приложений установленных Helm, и список deployments, pods и svc через kubectl:  
![](/diplom/images/04/14-installed-apps.jpg)  

Далее я разместил приложение в репозитории Helm, чтобы иметь возможность доступа к нему в любой момент.  

Сборка архива `helm package web-application -d charts` и генерация индексного файла `helm repo index charts`:  
![](/diplom/images/04/15-create-helm-chart.jpg)  

Содержимое папки [helm](/diplom/helm) залил в [отдельный репозиторий на github](https://github.com/E-zh/netology-yc-helm).
Создал [специальную страницу чарта(https://e-zh.github.io/netology-yc-helm/)] на github, и создал репозиторий на [ArtifactHUB](https://artifacthub.io/)

Для получения статуса `Verified Publisher` в репозитории ArtifactHUB, необходимо создать файл [artifacthub-repo.yml](/diplom/helm/charts/artifacthub-repo.yml),
и выполнить обновление версии образа Docker на `2.0`, пересобрать образ и отправить в репозиторий, а также обновить номера версии в файлах чарта Helm и сгенерировать новый индексный файл и сам чарт:  
![](/diplom/images/04/16-update-version-package.jpg)  
И пушим все изменения в репозиторий github:  
![](/diplom/images/04/17-push-to-github.jpg)  
Теперь, когда наше веб-приложение добавлено в репозиторий, мы получаем возможность устанавливать его в кластер автоматизированным способом еще на этапе сборки кластера.
Для этого в папку [ansible/playbooks](/diplom/ansible/playbooks) добавим файл [deploy-web-application.yaml](/diplom/ansible/playbooks/deploy-web-application.yaml) и укажем
в файле [site.yaml](/diplom/ansible/site.yaml) - `- import_playbook: playbooks/deploy-web-application.yaml`.  

Через какое-то время репозиторий в ArtifactHUB приобретает статус `Verified Publisher`:  
![](/diplom/images/04/19-verified-publisher-status.jpg)  

Проверяем, выполнив команду в папке Ansible - `ansible-playbook -i inventory/hosts.yaml playbooks/deploy-web-application.yaml`, после чего переходим в браузере по любому адресу ноды, и видим что наше приложение обновлено - версия 2.0:  
![](/diplom/images/04/18-update-web-app.jpg)  

Таким образом, на этом шаге я развернул систему мониторинга, предоставив доступ снаружи к Grafana, а также развернул тестовое приложение с помощью Helm, и создал репозиторий, для того чтобы иметь к нему доступ в любое время. 


## <a name="ci_cd">5. Установка и настройка CI/CD</a>

Ранее, прочитав задание я уже определился, что буду использовать TeamCity, поэтому при развертывании инфраструктуры с помощью Terraform у меня уже есть 2 ВМ для `teamcity-server` и `teamcity-agent`.  
Использование образов, оптимизированных для использования Docker, обусловлено тем, что для работы агентов Teamcity необходим демон Docker для сборки образов на основе Dockerfile и отправки их в регистр. В образах, оптимизированных для запуска Docker-контейнеров демон Docker уже установлен.  
Установка TeamCity будет выполнена с помощью Ansible, для чего был создан еще один файл [deploy-teamcity.yaml](/diplom/ansible/playbooks/deploy-teamcity.yaml).  
Также в качестве базы данных я установлю PostgreSQL, для чего создан файл [deploy-postgresql.yaml](/diplom/ansible/playbooks/deploy-postgresql.yaml).  

Выполнив команды установки:  
* `ansible-playbook -i inventory/hosts.yaml playbooks/deploy-postgresql.yaml`
* `ansible-playbook -i inventory/hosts.yaml playbooks/deploy-teamcity.yaml`

Логи видим достаточно большие, поэтому приводить здесь их не буду. Проверяем сервер TeamCity, пройдя по адресу [158.160.118.247:8111](http://158.160.118.247:8111), видим веб интерфейс:  
![](/diplom/images/05/01-teamcity-installed.jpg)  
Далее я зашел в настройки БД и указал параметры подключения, указанные в файле [deploy-postgresql.yaml](/diplom/ansible/playbooks/deploy-postgresql.yaml), также скачав драйвер JDBC, нажав соответствующую кнопку.
Запустился процесс инициализации и создания базы данных. Далее появилось окно с лицензией, и в следующем окне создаем аккаунт администратора:  
![](/diplom/images/05/02-teamcity-account.jpg)  
Когда аккаунт администратора создан, мы попадаем на страницу приветствия, где уже можно создать проект:  
![](/diplom/images/05/03-admin-is-created.jpg)  
Но пока я этого делать не буду, т.к. нужно авторизовать агент. Поэтому переходим на соответствующую вкладку:  
![](/diplom/images/05/04-agent-unautorized.jpg)  
И авторизовываем агента:  
![](/diplom/images/05/05-agent-autorized.jpg)  

Теперь можно приступить к созданию проекта. Создал проект, указал наш [репозиторий Git](https://github.com/E-zh/netology-yc-web-app.git) для отследивания.
TeamCity определил что это Docker проект. Далее добавил connection с DockerHub:  
![](/diplom/images/05/06-created-project-docker-connection.jpg)  
Далее добавил поддержку Docker в разделе Build Features, и добавил Docker support, указав ранее созданный Docker connection:  
![](/diplom/images/05/07-added-docker-support.jpg)  

Далее, приступим к сборке проекта. Так как при сборке мы хотим использовать тег, назначенный коммиту в качестве тега нашего Docker-образа. 
Для этого создадим отдельный этап, позволяющий выполнять произвольный код командной строки. Для этого на закладке Build Step выбираем тип шага Command Line:  
![](/diplom/images/05/08-added-build-step.jpg)  
Далее добавим второй шаг с типом Docker, указываем действие build, и задаём параметры создаваемого образа:  
![](/diplom/images/05/09-added-docker-build-step.jpg)  
Далее создадим следующий шаг по отправке созданного образа в репозиторий DockerHub:  
![](/diplom/images/05/10-created-send-image-step.jpg)  
Следующим шагом добавим действие по получению содержимого Git-репозитория, связанного с Helm-артефакторием, с типом Command Line:  
![](/diplom/images/05/11-clone-helm-repo.jpg)  
И наконец добавим последний шаг - модификация файлов Git-репозитория, связанного с Helm-артефакторием, так же с типом с типом Command Line:  
![](/diplom/images/05/12-modify-helm-files-step.jpg)  
[Полный текст скрипта выложил здесь](/diplom/helm-modify/modify.sh)  

На этом настройка закончена, и в итоге состав наших шагов будет выглядеть следующим образом:  
![](/diplom/images/05/13-all-steps-build.jpg)  


## <a name="test_run">6. Проверка работоспособности</a>

Итак, проверяем работу нашей системы.  
На данный момент наше приложение имеет версию 2.0:  
![](/diplom/images/06/01-web-app.jpg)  
Исправим в файле версию, и обновим репозиторий:  
![](/diplom/images/06/02-update-tag.jpg)  
Также я добавил и выполнил Ansible playbook для добавления запуска периодического обновления приложения с помощью Helm:
* [deploy-cron.yaml](/diplom/ansible/playbooks/deploy-cron.yaml)  

Далее, заходим в TeamCity, и видим, что он уже увидел появление нового тега `3.0` и запустил процесс сборки:  
![](/diplom/images/06/03-build.jpg)  
Видим что сборка отработала, смотрим в наш репозиторий DockerHub:  
![](/diplom/images/06/04-docker-hub.jpg)  

Как видим и там версия обновлена. На данный момент я несколько раз коммитил, поэтому версия приложения уже 4.0, в версии 3.0 была ошибка запуска агента.

Далее смотрим в репозиторий Helm:  
![](/diplom/images/06/05-helm-yc-repo.jpg)  
Ну и соответственно в течение получаса ожидаем когда отработает cron, видим что версия нашего тестового веб-приложения также обновилась:  
![](/diplom/images/06/06-web-app.jpg)  

На данном этапе я закончу тестирование, т.к. поставленные цели были достигнуты.  
В данной работе мы автоматически развернули инфраструктуру системы в Yandex.Cloud с помощью Terraform.  
С помощью Ansible был развернут кластер Kubernetes. Автоматизация и сборка приложения реализована с помощью Helm, сервера TeamCity, и запуска установки приложения через cron.


## <a name="completed">7. Заключение. Ссылки на репозитории и сервисы</a>

* [Репозиторий конфигурации инфраструктуры, Terraform](https://github.com/E-zh/netology-yc-infrastructure)
* [Репозиторий с конфигурацией ansible, kubernetes](https://github.com/E-zh/netology-yc-kubernetes-cluster)
* [Репозиторий с Dockerfile тестового приложения](https://github.com/E-zh/netology-yc-web-app)
* [Ссылка на образ Docker тестового приложения](https://hub.docker.com/r/egorz/netology-diploma-web-app/tags)
* Тестовое приложение доступно по адресам нод на порту 30100:
    - [51.250.38.95:30100](http://51.250.38.95:30100/)
    - [84.201.160.70:30100](http://84.201.160.70:30100/)
* Web интерфейс Grafana доступен по адресам нод на порту 30300 (логин/пароль написал в сопроводительном письме):
    - [84.201.160.70:30300](http://84.201.160.70:30300)
    - [51.250.38.95:30300](http://51.250.38.95:30300/)

