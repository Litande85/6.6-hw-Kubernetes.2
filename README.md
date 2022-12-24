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

Установила kubernetes с использованием playbook ansible

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
master1 ansible_host=10.128.0.103 ansible_ssh_private_key_file=/home/user/.ssh/id_rsa ansible_user=user ansible_python_interpreter=/usr/bin/python3
master2 ansible_host=10.128.0.10 ansible_ssh_private_key_file=/home/user/.ssh/id_rsa ansible_user=user ansible_python_interpreter=/usr/bin/python3
master3 ansible_host=10.128.0.11 ansible_ssh_private_key_file=/home/user/.ssh/id_rsa ansible_user=user ansible_python_interpreter=/usr/bin/python3
node1 ansible_host=10.128.0.200 ansible_ssh_private_key_file=/home/user/.ssh/id_rsa ansible_user=user ansible_python_interpreter=/usr/bin/python3
node2 ansible_host=10.128.0.201 ansible_ssh_private_key_file=/home/user/.ssh/id_rsa ansible_user=user ansible_python_interpreter=/usr/bin/python3
node3 ansible_host=10.128.0.202 ansible_ssh_private_key_file=/home/user/.ssh/id_rsa ansible_user=user ansible_python_interpreter=/usr/bin/python3


[kube_control_plane]
master1
master2
master3

[etcd]
master1
master2
master3

[kube_node]
node1
node2
node3


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


На машине master1 перешла под рута `sudo su`, проверила системные поды `kubectl get po -n kube-system`

![kubesystem](img/img202212242.png)


Плагин по умолчанию установился  calico.

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
        image: bitnami/redis
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
