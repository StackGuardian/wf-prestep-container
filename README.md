# wf-prestep-container
Docker container as pre Step workflow inf StackGuardian.io

## 1. Checkout

```shell
git clone <repo URL>
```

## 2. Add script to the /scripts folder

## 3. Build docker image

```shell 
docker build .
```

## 4. Push Image to a registry

```shell
docker push <imagename>
```

## 5. Create Workflow Step Template

[Create a Workflow Step](https://docs.stackguardian.io/docs/develop/library/workflow_step/)