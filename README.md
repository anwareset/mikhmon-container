# MIKHMON CONTAINER
**MikroTik Hotspot Monitor V3** by [**laksa19**](https://github.com/laksa19) inside container.

## Description
This image is using latest [alpine](https://hub.docker.com/_/alpine) for the base with PHP 7.4 as the runtime, executed by user `www-data`. The exposed port is `8080/tcp` and the default volume is pointed at `/var/www/html` which is the [source code](https://github.com/laksa19/mikhmonv3) located inside container. Hopefully, this will comply with any container orchestration platform like [Kubernetes](https://kubernetes.io) for the best practice of scaling and high availability.

## Usages
### Docker
Use any container tool such as `docker` or `podman` with simple command. Most easy way, since it's not using any web server to run.
```shell
docker pull trianwar/mikhmon
docker run --name mikhmon-app -d -p 80:8080 -v mikhmon-volume trianwar/mikhmon
```
If you want to access source code files inside the container storage, check the mounted volume on host at `/var/lib/docker/volumes`. You can backup or modify those files.

To force stop and remove container.
```shell
docker rm --force mikhmon-app
```

### Kubernetes
The YAML file contains object definition of Kubernetes resources (deployments, services, and ingress). Tested on GKE (Google Kubernetes Engine).
```shell
kubectl create namespace mikhmon-app
kubectl apply -f deployments.yml
kubectl apply -f services.yml
kubectl apply -f ingress.yml
```

Scale the application manually with `--replicas` option. Adjust the **`N`** number.
```shell
kubectl scale deployments mikhmon-app --replicas=N
```

Delete the resources from cluster.
```shell
kubectl delete all
kubectl delete namespace mikhmon-app
```

### Docker Compose
Enter the `docker-compose` directory, and you will found two options to of using it.
1. **Caddy**. Cool web server that automatically provision SSL (Let's Encrypt) for your site, port `80/tcp` will redirected to `443/tcp`.
2. **Nginx**. Run `80/tcp` without SSL by default. But you can modify `nginx.conf` to use certificates and open another port as you wish.

Change the owner to `uid=82(www-data) gid=82(www-data)`, this is because the [`php:7.4-fpm-alpine`](https://hub.docker.com/_/php?tab=tags&page=1&name=7.4-fpm-alpine) seemly [use that user by default](https://hub.docker.com/layers/php/library/php/7.4.0-fpm-alpine/images/sha256-35565c5edd4dd676a7ea7d7b566eab08b2ee6474263f6cd384d4d29d4590a199?context=explore), and I don't find other way to alter it yet. Also, don't forget to change the domain name of your server in `Caddyfile`.

```shell
cd docker-compose
sudo chown -R 82:82 mikhmonv3
```

For `caddy` you may append Public IP of the VPS and FQDN to `/etc/hosts` configuration file. Bellow are example from my AWS EC2 server.

```shell
echo '108.136.227.206 mikhmon.init.web.id' | sudo tee -a /etc/hosts
```

Then let's build and turn it up. Append `-d` to detach and keep it running in background.
```shell
docker-compose up --build --remove-orphans -d
docker ps
```
![Container Running List](https://github.com/anwareset/mikhmon-container/raw/main/docker-compose/Screenshot_11.png)

![Add Router](https://github.com/anwareset/mikhmon-container/raw/main/docker-compose/Screenshot_63.png)
As you can see the MikroTik Router is added successfully to MIKHMON, and we got one year valid SSL from Let's Encrypt.

To stop the container, you can turn it down.
```shell
docker-compose down --remove-orphans
```

## Testing
### Dockerfile
Feel free to modify and build the `Dockerfile` to fit with your needs.
```shell
docker build --no-cache -t mikhmon .
```

## Shortage
Please check this [#issue](https://github.com/laksa19/mikhmonv3/issues/41) from the application side. Persistent Volume on Kubernetes unable to use due to Unspesific Location of Stateful files.

---

## References
- [Exposing Service on GKE](https://cloud.google.com/blog/products/containers-kubernetes/exposing-services-on-gke)
- [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress)
- [MIKHMON](https://laksa19.github.io/?mikhmon/v3)
- [Docker Hub](https://hub.docker.com/r/trianwar/mikhmon)
