CHART_REPO := http://chartmuseum.cd.thunder.fabric8.io
CHART := jenkins-x-platform
CHART_VERSION := 0.0.21
OS := $(shell uname)
HELM := $(shell command -v helm 2> /dev/null)
WATCH := $(shell command -v watch --help 2> /dev/null)
RELEASE := jenkins-x
INGRESS_RUNNING := $(shell minikube addons list | grep "ingress: enabled" 2> /dev/null)
TILLER_RUNNING := $(shell kubectl get pod -l app=helm -l name=tiller -n kube-system | grep '1/1       Running' 2> /dev/null)

setup:
# setup is always called from the `clean` target, remove it not required to run each time
# this will check dependencies are installed, services are running and local repos configured correctly
ifndef HELM
ifeq ($(OS),Darwin)
	brew install kubernetes-helm
else
	echo "Please install helm first https://github.com/kubernetes/helm/blob/master/docs/install.md"
endif
endif

ifndef WATCH
ifeq ($(OS),Darwin)
	brew install watch
else
	echo "Please install watch first"
endif
endif

ifndef TILLER_RUNNING
	helm init
	echo 'Waiting for tiller to become available in the namespace kube-system'
	(kubectl get pod -l app=helm -l name=tiller -n kube-system -w &) | grep -q  '1/1       Running'
endif

ifndef INGRESS_RUNNING
	minikube addons enable ingress
	echo 'Waiting for the ingress controller to become available in the namespace kube-system'
	(kubectl get pod -l app=nginx-ingress-controller -l name=nginx-ingress-controller -n kube-system -w &) | grep -q  '1/1       Running'
endif
	helm repo add jenkins-x $(CHART_REPO)

delete:
	helm delete --purge $(RELEASE)
	kubectl delete cm --all

clean: setup
	rm -rf secrets.yaml.dec
