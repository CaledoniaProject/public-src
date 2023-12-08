#!/bin/bash
# 当脚本出错，自动上传日志

exec &> error.log

# 采集错误，如果出错
trap '[[ $? -ne 0 ]] && (cp error.log new.log; curl 127.0.0.1/error -F hostname=$(hostname) -F file=@error.log); rm -f error.log new.log' EXIT
set -ex -o pipefail

# 模拟出错
ls qweqwe

