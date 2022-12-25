# Домашнее задание к занятию «6.6. Kubernetes. Часть 2» - `Елена Махота`


---

- [Ответ к Заданию 1](#1)
- [Ответ к Заданию 2](#2)
- [Ответ к Заданию 3*](#3)

---
### Задание 1

**Выполните действия:**

1. Создайте свой кластер с помощью kubeadm.
1. Установите любой понравившийся CNI плагин.
1. Добейтесь стабильной работы кластера.

В качестве ответа пришлите скриншот результата выполнения команды `kubectl get po -n kube-system`.

### *<a name="1">Ответ к Заданию 1</a>*

Создала 6 машин с помощью [terraform](terraform/main.tf)

Поставила [docker](docker.sh).

Поставила `kubeadm`

```bash

# Настраиваем репозиторий:
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Устанавливаем пакет:
sudo apt-get update
sudo apt-get install -y kubeadm

```

Установила kubernetes с использованием  ansible-playbook 
## `kubespray`

https://github.com/kubernetes-sigs/kubespray

```bash

git clone https://github.com/kubernetes-sigs/kubespray.git
cd ./kubespray
python3 -m pip install -r ./requirements.txt
cp -r ./inventory/sample/ ./inventory/myinv

```
В файле [/home/user/kubespray/inventory/myinv/inventory.ini](inventory.ini) указала свои машины:

```yaml
# ## Configure 'ip' variable to bind kubernetes services on a
# ## different ip than the default iface
# ## We should set etcd_member_name for etcd cluster. The node that is not a etcd member do not need to set the value, or can set the empty string value.
[all]
master-makhota1 ansible_host=10.128.0.103 ansible_ssh_private_key_file=/home/user/.ssh/id_rsa ansible_user=user ansible_python_interpreter=/usr/bin/python3
master-makhota2 ansible_host=10.128.0.10 ansible_ssh_private_key_file=/home/user/.ssh/id_rsa ansible_user=user ansible_python_interpreter=/usr/bin/python3
master-makhota3 ansible_host=10.128.0.11 ansible_ssh_private_key_file=/home/user/.ssh/id_rsa ansible_user=user ansible_python_interpreter=/usr/bin/python3
node-makhota1 ansible_host=10.128.0.200 ansible_ssh_private_key_file=/home/user/.ssh/id_rsa ansible_user=user ansible_python_interpreter=/usr/bin/python3
node-makhota2 ansible_host=10.128.0.201 ansible_ssh_private_key_file=/home/user/.ssh/id_rsa ansible_user=user ansible_python_interpreter=/usr/bin/python3
node-makhota3 ansible_host=10.128.0.202 ansible_ssh_private_key_file=/home/user/.ssh/id_rsa ansible_user=user ansible_python_interpreter=/usr/bin/python3

[kube_control_plane]
master-makhota1
master-makhota2
master-makhota3

[etcd]
master-makhota1
master-makhota2
master-makhota3

[kube_node]
node-makhota1
node-makhota2
node-makhota3
# node4
# node5
# node6

[calico_rr]

[k8s_cluster:children]
kube_control_plane
kube_node
calico_rr



```

Применила playbook 

```bash

ansible-playbook -i ./inventory/myinv/inventory.ini cluster.yml -b

```

В результате где-то за полчаса без моего участия кластер kubernetes установился

![ansible](img/img202212241.png)


На машине `master-makhota1` перешла под рута `sudo su`, проверила системные поды `kubectl get po -n kube-system`

![kubesystem](img/img202212242.png)


Плагин по умолчанию установился  calico.

```bash
kubectl get nodes
```
![nodes](img/img202212251.png)

---

### Задание 2

Есть файл с деплоем:

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
spec:
  selector:
    matchLabels:
      app: redis
  replicas: 1
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: master
        image: 
           env:
         - name: REDIS_PASSWORD
           value: password123
        ports:
        - containerPort: 6379
```
**Выполните действия:**

1. Создайте Helm Charts.
1. Добавьте в него сервис.
1. Вынесите все нужные, на ваш взгляд, параметры в `values.yaml`.
1. Запустите чарт в своём кластере и добейтесь его стабильной работы.

В качестве ответа пришлите вывод команды `helm get manifest <имя_релиза>`.

### *<a name="2">Ответ к Заданию 2</a>*

Установка `helm`

```bash

curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm version

```
Добавление `repo`

```bash

helm repo add stable https://charts.helm.sh/stable
helm repo list

```


Создание чарта

```bash
mkdir chart-redis-makhota
cd ./chart-redis-makhota
mkdir templates
touch ./templates/deployment.yaml
touch ./templates/service.yaml
touch values.yaml
touch Chart.yaml
```
Вносим данные в файлы

[chart-redis-makhota/Chart.yaml](chart-redis-makhota/Chart.yaml)

```yaml

apiVersion: v2
name: chart-redis-makhota
description: A Helm chart for Kubernetes redis
type: application
version: 0.1.0
appVersion: "1.16.0"

```

[chart-redis-makhota/values.yaml](chart-redis-makhota/values.yaml)

```yaml

nameApp: chart-redis-makhota

image: redis:6.0.13

containerPort: 6379

targetPort: 6379

replicaCount: 3

specType: ClusterIP

```

[chart-redis-makhota/templates/deployment.yaml](chart-redis-makhota/templates/deployment.yaml)


```yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.nameApp }}
spec:
  selector:
    matchLabels:
      app: {{ .Values.nameApp }}
  replicas: {{ .Values.replicaCount }}
  template:
    metadata:
      labels:
        app: {{ .Values.nameApp }}
    spec:
      containers:
      - name: {{ .Values.nameApp }}
        image: {{ .Values.image }}
        ports:
        - containerPort: {{ .Values.containerPort }}

```

[chart-redis-makhota/templates/service.yaml](chart-redis-makhota/templates/service.yaml)

```yaml

apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.nameApp }}
spec:
  type: {{ .Values.ClusterIP }}
  ports:
  - port: {{ .Values.containerPort }}
    targetPort: {{ .Values.targetPort }}
    name: {{ .Values.nameApp }}
  selector:
    app: {{ .Values.nameApp }}

```

Устанавливаем чат

```bash

helm install chart-redis-makhota ./chart-redis-makhota/

```

Проверяем список чатов и работу подов


![img202212252](img/img202212252.png)

![img202212253](img/img202212253.png)

![img202212254](img/img202212254.png)
![img202212255](img/img202212255.png)



---
## Дополнительные задания* (со звёздочкой)

Их выполнение необязательное и не влияет на получение зачёта по домашнему заданию. Можете их решить, если хотите лучше разобраться в материале.

---

### Задание 3*

1. Изучите [документацию](https://kubernetes.io/docs/concepts/storage/volumes/#hostpath) по подключению volume типа hostPath.
1. Дополните деплоймент в чарте подключением этого volume.
1. Запишите что-нибудь в файл на сервере, подключившись к поду с помощью `kubectl exec`, и проверьте правильность подключения volume.

В качестве ответа пришлите получившийся yaml-файл.


### *<a name="3">Ответ к Заданию 3*</a>*
