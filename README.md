# docker-saltmaster

saltmaster in a container

## build

```
git clone https://github.com/NTTCom-MS/docker-saltmaster
cd docker-saltmaster
docker build -t eyp/saltmaster .
```

## configuration

### envs

* **INIT_SALT_REPOS**: space-separated list of sls repos

## run

### volume holder

```
docker run -d --name VOLUME_HOLDER -t nttcomms/saltmaster /bin/true
```

### saltmaster

```
docker run -d --name DEMO_SALT_MASTER --volumes-from VOLUME_HOLDER -v /root/.ssh:/root/.ssh -p 4505:4505 -p 4506:4506 -p 8000:8000 -e INIT_SALT_REPOS="https://github.com/tony/salt-states-configs" -t nttcomms/saltmaster
```

## healthcheck

There is a healthcheck on :17 checking that all supervisord processes are running:

```
[root@8782630c1ac3 /]# curl -I localhost:17
HTTP/1.0 200 OK
Server: BaseHTTP/0.3 Python/2.7.5
Date: Mon, 17 Dec 2018 16:32:48 GMT
Content-type: text/html

[root@8782630c1ac3 /]# supervisorctl stop crond
crond: stopped
[root@8782630c1ac3 /]# curl -I localhost:17
HTTP/1.0 503 Service Unavailable
Server: BaseHTTP/0.3 Python/2.7.5
Date: Mon, 17 Dec 2018 16:33:02 GMT
Content-type: text/html
```
