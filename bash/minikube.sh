minikube start --docker-env http_proxy=http://192.168.64.1:4562 --docker-env https_proxy=http://192.168.64.1:4562 --docker-env no_proxy=192.168.0.0/16 --vm-driver=xhyve -v=10 --alsologtostderr
kubectl run hello-minikube --image=k8s.gcr.io/echoserver:1.10 --port=8080

