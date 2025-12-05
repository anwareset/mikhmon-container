# MIKHMON CONTAINER
**MikroTik Hotspot Monitor V3** by [**laksa19**](https://github.com/laksa19) inside container.

## Description
This image is using latest [alpine](https://hub.docker.com/_/alpine) for the base with PHP 7.4 FPM as the runtime. The exposed port is `8080/tcp` and the default volume is pointed at `/var/www/mikhmon` which is the [source code](https://github.com/laksa19/mikhmonv3) located inside container. Nginx and PHP-FPM are managed by supervisord inside the container. Hopefully, this will comply with any container orchestration platform like [Kubernetes](https://kubernetes.io) for the best practice of scaling and high availability.

## Usages
### Docker
Use any container tool such as `docker` or `podman` with simple command.
```shell
docker pull trianwar/mikhmon
docker run --name mikhmon-app -d -p 8080:8080 -v ./mikhmon-data:/var/www/mikhmon trianwar/mikhmon
```
If you want to access source code files inside the container storage, check the mounted volume on host at `mikhmon-data`. You can backup or modify those files.

To force stop and remove container.
```shell
docker rm --force --volumes mikhmon-app
```

### Kubernetes
The YAML files contain object definitions of Kubernetes resources (namespace, deployments, services, ingress, and persistent volume claims). Tested on GKE (Google Kubernetes Engine).

First, apply the namespace and persistent volume claims:
```shell
cd mikhmon-container/k8s-manifests
kubectl apply -f namespace.yml
kubectl apply -f pvc.yml
```

Then, apply the deployment, service, and ingress:
```shell
kubectl apply -f deployments.yml
kubectl apply -f services.yml
kubectl apply -f ingress.yml
```

Scale the application manually with `--replicas` option. Adjust the **`N`** number.
```shell
kubectl scale deployments mikhmon-app -n mikhmon-app --replicas=N
```

Check the deployment status:
```shell
kubectl get deployments -n mikhmon-app
kubectl get pods -n mikhmon-app
```

Delete the resources from cluster:
```shell
kubectl delete -f ingress.yml
kubectl delete -f services.yml
kubectl delete -f deployments.yml
kubectl delete -f pvc.yml
kubectl delete -f namespace.yml
```

### Docker Compose
Enter the `docker-compose` directory. The application uses a pre-built image `trianwar/mikhmon:latest` with Caddy as a reverse proxy to handle SSL termination automatically via Let's Encrypt. Environment variable `MODE=caddy` will disable `nginx` and only run `php-fpm` that will be use with `caddy`.

Update the domain name in `Caddyfile` to match your server's FQDN, and optionally add it to `/etc/hosts` for local testing:

```shell
echo '108.136.227.206 mikhmon.deployer.dpdns.org' | sudo tee -a /etc/hosts
```

Then, create the network and start the services:
```shell
cd mikhmon-container/docker-compose
docker network create net1 --driver bridge
docker compose -p mikhmon up -d
docker compose ls
docker ps
```
![Container Running List](https://github.com/anwareset/mikhmon-container/raw/main/Screenshot_11.png)

![Add Router](https://github.com/anwareset/mikhmon-container/raw/main/Screenshot_63.png)
As you can see the MikroTik Router is added successfully to MIKHMON, and we got one year valid SSL from Let's Encrypt.

To stop the services:
```shell
docker compose -p mikhmon down
```

## Testing
### Dockerfile
Feel free to modify and build the `Dockerfile` to fit with your needs. Make sure to have `nginx.conf` and `supervisord.conf` in the same directory.
```shell
docker build --no-cache -t trianwar/mikhmon:latest .
```

You can also tag it with a version:
```shell
docker build --no-cache -t trianwar/mikhmon:v1.0 .
```

## Notes
- The application stores stateful data (like router configurations and user passwords) in the `/var/www/mikhmon` container directory.
- For Kubernetes deployments, ensure that your cluster has a StorageClass configured for dynamic persistent volume provisioning, or manually create PersistentVolumes.
- The `nginx.conf` and `supervisord.conf` files must be present in the root directory when building the Docker image.
- When using Caddy in Docker Compose, remember to update the domain name in the `Caddyfile` to your actual server's FQDN.
- For more information on the MIKHMON application, visit [laksa19's GitHub](https://laksa19.github.io/?mikhmon/v3).

---

## References
- [Exposing Service on GKE](https://cloud.google.com/blog/products/containers-kubernetes/exposing-services-on-gke)
- [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress)
- [MIKHMON](https://laksa19.github.io/?mikhmon/v3)
- [Docker Hub](https://hub.docker.com/r/trianwar/mikhmon)
