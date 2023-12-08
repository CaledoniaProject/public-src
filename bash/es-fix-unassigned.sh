#!/bin/bash

exit

curl http://xxxx:8200/_cat/shards | grep UNASSIGNED | while read index shard _
do
  echo $index
  curl http://xxxx:8200/_cluster/reroute -H 'Content-Type: application/json' -d '{
    "commands": [
      {
         "allocate_empty_primary": {
            "index": "'$index'",
            "shard": "'$shard'",
            "node":  "xxxx",
            "accept_data_loss" : true
         }
      }
    ]
  }' &> /dev/null
  echo
done

