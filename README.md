# MIKHMON CONTAINER
**MikroTik Hotspot Monitor V3** by [**laksa19**](https://github.com/laksa19) inside container.

## Description
This image is using latest [alpine](https://hub.docker.com/_/alpine) for the base, with PHP 7.4 as the runtime. The exposed port is `80/tcp` and the default volume is pointed at `/var/www/html` which is the [source code](https://github.com/laksa19/mikhmonv3) located inside container. Hopefully, this will comply with any container orchestration platform like [Kubernetes](https://kubernetes.io) for the best practice of scaling and high availability.

## Usages
### Docker
Use any container tool such as `docker` or `podman` with simple command.
```shell
docker pull trianwar/mikhmon
docker run --name mikhmon-app -d -p 80:80 trianwar/mikhmon
```
Force stop and remove.
```shell
docker rm --force mikhmon-app
```

### Kubernetes
The `YAML` file contains object definition of Kubernetes resources (deployments, service, expose). Tested on GKE (Google Kubernetes Engine).
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

## Testing
Feel free to modify and build the `Dockerfile` to fit with your needs.
```shell
docker build --no-cache -t mikhmon .
```

---

## References
- [Exposing Service on GKE](https://cloud.google.com/blog/products/containers-kubernetes/exposing-services-on-gke)
- [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress)
- [MIKHMON](https://laksa19.github.io/?mikhmon/v3)
- [Docker Hub](https://hub.docker.com/r/trianwar/mikhmon)
