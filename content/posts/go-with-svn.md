+++
date = '2025-06-04T19:05:48+08:00'
draft = false
title = 'Go With Svn'
summary = "Go with Svn sample"
tags = ["Golang"]
+++

## Crate a go project and add it to svn

- `go.mod`

```
module server/utils-go

go 1.24.1
```

- `utils.go`

```go
package utilsgo

import "github.com/bwmarrin/snowflake"

const nodeID = 1

func Add(a, b int) int {
	return a + b
}

```

- submit to svn

```bash
svn add .
svn commit -m "add go project"

# 127.0.0.1:3690/svn/repos/server/utils-go
# revision 1194
```

## Use the go project in another project

- `go.mod`

```
module go-with-svn

go 1.24.1

require server/utils-go v0.0.0

replace server/utils-go v0.0.0 => 127.0.0.1:3690/svn/repos/server/utils-go.svn 1194

```

- `main.go`

```go
package main

import (
	"fmt"

	utilsgo "server/utils-go"
)

func main() {
	result := utilsgo.Add(1, 2)
	fmt.Printf("Result: %d\n", result)
}

```

- compile and run

```bash
# 1. Allow use SVN
go env -w GOVCS==*:all
# 2. Set GOPRIVATE
go env -w GOPRIVATE=127.0.0.1:3690/svn/repos
# 3. tidy
go mod tidy
# 4. run
go run main.go
# Result: 3

```

```bash
# or use go add mod
go get 127.0.0.1:3690/svn/repos/server/utils-go.svn@1194
```

- final `go.mod`

```
module go-with-svn

go 1.24.1

require server/utils-go v0.0.0

replace server/utils-go v0.0.0 => 127.0.0.1:3690/svn/repos/server/utils-go.svn v0.0.0-20250604103236-00000001194
```
