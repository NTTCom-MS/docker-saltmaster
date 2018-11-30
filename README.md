# docker-saltmaster

saltmaster in a container

## build

```
git clone https://github.com/NTTCom-MS/docker-saltmaster
cd docker-saltmaster
docker build -t eyp/saltmaster .
```

## run

### volume holder

```
docker run -d --name VOLUME_HOLDER -t saltmaster /bin/true
```

### saltmaster

```
docker run -d --name DEMO_SALT_MASTER --volumes-from VOLUME_HOLDER -v /root/.ssh:/root/.ssh -p 4505:4505 -p 4506:4506 -p 8000:8000 -e INIT_SALT_REPOS="https://github.com/MediaMath/ts-sls-examples" -t saltmaster
```
