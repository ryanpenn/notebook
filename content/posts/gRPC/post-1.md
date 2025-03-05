+++
date = '2025-03-05T20:29:10+08:00'
draft = false
title = '【gRPC系列一】开发环境'
summary = "在Go项目中使用gRPC进行通信"
tags = ["gRPC", "Golang"]
+++

## 安装 `protobuf`

- 下载 [protobuf-v3.20.3](https://github.com/protocolbuffers/protobuf/releases/tag/v3.20.3)
- 解压到指定目录
- 配置环境变量 `export PATH=$PATH:/path/to/protobuf/bin`
- 检查是否安装成功 `protoc --version`，输出版本号则安装成功

## 安装 `protoc-gen-go` 和 `protoc-gen-go-grpc`

```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
protoc-gen-go --version
# v1.36.5

go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
protoc-gen-go-grpc --version
# v1.5.1
```

## 创建Go项目

```bash
mkdir grpc-example
cd grpc-example
go mod init example.com/grpc-example
```

## 安装依赖包

```bash
go get -u google.golang.org/grpc
go get -u google.golang.org/protobuf
```

## 创建proto文件

```bash
mkdir proto
```

```proto
syntax = "proto3";

package service;

option go_package = "./proto";

service Service {
    rpc HandleRequest (Request) returns (Response);
    rpc HandleServerStream (Request) returns (stream Response);
    rpc HandleClientStream (stream Request) returns (Response);
    rpc HandleBiStream (stream Request) returns (stream Response);
}

message Request {
    int32 id = 1;
    string type = 2;
    bytes payload = 3;
}

message Response {
    int32 id = 1;
    bytes payload = 2;
}
```

## 生成Go代码

```bash
protoc --go_out=. --go_opt=paths=source_relative --go-grpc_out=. --go-grpc_opt=paths=source_relative proto/service.proto

# 此时 proto 目录中将创建两个文件 service.pb.go 和 service_grpc.pb.go
```

## 完善项目代码

最终项目结构如下：

```bash
.
├── README.md
├── cmd
│   ├── client
│   │   └── main.go
│   └── server
│       └── main.go
├── go.mod
├── go.sum
├── internal
│   ├── client.go
│   ├── server.go
│   └── service.go
└── proto
    ├── service.pb.go
    ├── service.proto
    └── service_grpc.pb.go
```
