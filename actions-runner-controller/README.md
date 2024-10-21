Install Microk8s

Follow Microk8s guide
https://microk8s.io/#install-microk8s

Enable hostpath-storage Microk8s addon

```bash
microk8s enable hostpath-storage
```
    
Install Helm

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash 
```

Save config to use kubectl without microk8s (as an alias)
    
```bash
cd $HOME
mkdir .kube
cd .kube
microk8s config > config
```
    
Clone Magma repository

```bash
git clone https://github.com/langtech-bsc/magma.git
cd magma
```

Install actions-runner-controller from official helm chart

```bash
NAMESPACE="arc-systems"
helm upgrade --install arc \
--namespace "${NAMESPACE}" \
--create-namespace \
--set metrics.controllerManagerAddr=':8080' \
--set metrics.listenerAddr=':8080' \
--set metrics.listenerEndpoint='/metrics' \
--set-string podAnnotations."prometheus\.io/scrape"=true \
--set-string podAnnotations."prometheus\.io/path"=/metrics \
--set-string podAnnotations."prometheus\.io/port"=8080 \
oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller
```

Create new GitHub app at [Github Apps Settings](https://github.com/organizations/langtech-bsc/settings/apps/new)

Fill the required fields as GitHub App name, Homepage URL

![Register New App, fill the fields](https://github.com/user-attachments/assets/36cf9906-4d86-48a2-b2a0-f38c6d1531f7)


Disable webhooks; Uncheck Active checkbox

![Disable webhooks](https://github.com/user-attachments/assets/f4dd0e78-8701-4913-8c5a-8e8ed88f5b9f)


At **permissions** → **Repository permissions** → Set **Actions** to **Access: Read and write**

At **permissions** → **Organization permissions** → Set **Self-hosted runners**  to **Access: Read and write**

Install the app in your organization  
**Organization → Settings → Developer Settings → GitHub App → Edit your app → Select Install App → Install in your organization**    

On private key section click on **Generate a private key.** (Store it safely for later use).

Create the runners namespace

```bash
NAMESPACE="arc-runners"
kubectl create namespace "${NAMESPACE}"
```

Create a secret that contains the following fields:

**github_app_id:** you could find this value at **About** section on Developer Settings

**github_app_installation_id:** you could find this value at installation app section, look at the the browser nativegation URL.

**github_app_private.key:** use the previous one

```bash
kubectl create secret generic magma-github-app \
--namespace "${NAMESPACE}" \
--from-literal=github_app_id=xxxxxx \
--from-literal=github_app_installation_id=xxxxxxxx \
--from-literal=github_app_private_key="$(cat /path/to/private/key)"
```

Check secret size; **github_app_id**, **github_app_installation_id** and **github_app_private_key** **must correspond** with following sizes (**6 bytes, 9 bytes and 1678 bytes**):
```bash
kubectl describe secret magma-github-app -n "${NAMESPACE}"
```

Output 

```bash
# Data
====
github_app_id:               6 bytes
github_app_installation_id:  9 bytes
github_app_private_key:      1678 bytes
```

Install Helm chart

```bash
GITHUB_CONFIG_URL="https://github.com/langtech-bsc"
NAMESPACE="arc-runners"

helm upgrade --install arc-runner-set \
	--namespace "${NAMESPACE}" \
	--create-namespace \
	--set githubConfigUrl="${GITHUB_CONFIG_URL}" \
	--set-string "listenerTemplate.spec.containers[0].name=listener" \
        --set-string listenerTemplate.metadata.annotations."prometheus\.io/scrape"=true \
	--set-string listenerTemplate.metadata.annotations."prometheus\.io/path"=/metrics \
	--set-string listenerTemplate.metadata.annotations."prometheus\.io/port"=8080 \
	-f actions-runner-controller/charts/runner-scale-set/values.yaml \
	oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set
```
