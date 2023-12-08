package main

import (
	"example.com/modlib/pb"
	"github.com/golang/protobuf/proto"
	"github.com/mitchellh/go-homedir"
	"io/ioutil"
	"log"
)

func main() {
	userInfo := &pb.UserInfo{
		Message: "12345",
		Id:      *proto.Int(1),
		Type:    pb.FOO_Type1,
	}

	filename, err := homedir.Expand("/tmp/bindata")
	if err != nil {
		log.Fatal("Failed to expand homedir: %v\n", err)
	}

	if binData, err := proto.Marshal(userInfo); err == nil {
		if err := ioutil.WriteFile(filename, binData, 0644); err != nil {
			log.Printf("Failed to write bindata: %v\n", err)
		} else {
			log.Printf("Saved to %s\n", filename)
		}
	} else {
		log.Printf("Failed to marshal data: %v\n", err)
	}
}
