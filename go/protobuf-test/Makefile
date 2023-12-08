default:
	export GO111MODULE=auto
	protoc --proto_path=pb --go_out=. test.proto
	go run cmd/client/main.go
