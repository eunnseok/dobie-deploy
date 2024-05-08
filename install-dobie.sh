#!/bin/bash

# 스크립트 실행 시 발생할 수 있는 모든 에러를 처리합니다.
set -e

# 1. Docker 설치
# Docker가 이미 설치되어 있지 않은 경우 설치합니다.

for pkg in docker.io docker-doc docker-compose docker-compose-v2 containerd runc; do sudo apt-get remove $pkg; done

sudo apt-get update -y
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Docker의 공식 APT repository를 시스템에 추가합니다.
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Docker 관련 패키지를 설치합니다.
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


# 2. nginx config 폴더 생성
# /var/dobie/nginx 폴더가 없으면 생성합니다.
if [ ! -d "/var/dobie/nginx" ]; then
    echo "nginx 폴더가 없어서 새로 생성합니다..."
    sudo mkdir -p /var/dobie/nginx
else
    echo "nginx 폴더가 이미 존재합니다."
fi

# cd /var/dobie/nginx
# sudo wget https://raw.githubusercontent.com/ko2sist/dobie-deploy/main/default.conf
# cd ~

# 3. data(json) 폴더 생성
# /var/dobie/data 폴더가 없으면 생성합니다.
if [ ! -d "/var/dobie/data" ]; then
    echo "data 폴더가 없어서 새로 생성합니다..."
    sudo mkdir -p /var/dobie/data
else
    echo "data 폴더가 이미 존재합니다."
fi

cd /var/dobie/data
sudo wget https://raw.githubusercontent.com/eunnseok/dobie-deploy/main/data/user.json
sudo wget https://raw.githubusercontent.com/eunnseok/dobie-deploy/main/data/project.json
sudo wget https://raw.githubusercontent.com/eunnseok/dobie-deploy/main/data/refreshToken.json
cd ~

# Docker network 생성
# 'dobie' 네트워크가 이미 존재하는지 확인합니다.
if ! sudo docker network ls | grep -qw dobie; then
    echo "dobie 네트워크가 없어서 새로 생성합니다..."
    sudo docker network create dobie
else
    echo "dobie 네트워크가 이미 존재합니다."
fi

# 4. docker-compose.yaml 가져온 후 실행
echo "Dobie의 docker-compose.yaml 을 가져옵니다."
wget https://raw.githubusercontent.com/eunnseok/dobie-deploy/main/docker-compose.yaml
sudo docker compose -f docker-compose.yaml up -d

echo "스크립트 실행이 완료되었습니다."
