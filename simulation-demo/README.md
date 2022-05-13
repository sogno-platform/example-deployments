# Simulation Demo

## Run

```bash
$ helm repo add sogno https://sogno-platform.github.io/helm-charts
```

```bash
$ ./start_demo.sh
```

This will call the deploy scripts in each subdirectory, which installs the component from helm chart or deployment file.

## Notes

 - kubernetes installation required:
   * easiest way to achieve this is [with minikube](https://minikube.sigs.k8s.io/docs/start/)

 - security issues (this is only a demo):
   * using HTTP instead of HTTPS
   * example passwords in yaml files


