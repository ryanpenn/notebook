+++
date = '2025-02-05T21:27:18+08:00'
draft = false
title = '[Ebitengine] (一) 简介'
description = ""
tags = ["Ebitengine", "Golang"]
# categories = [""]
# menu = "main"
+++

## 引擎简介

[Ebitengine](https://ebitengine.org/) 是一款[开源](https://github.com/hajimehoshi/ebiten)的游戏引擎，基于 Go 语言开发，支持 Windows、Mac、Linux 等平台。

ebiten 的 API 设计比较简单，使用也很方便，即使对于新手也可以在 1-2 个小时内掌握，并开发出一款简单的游戏。更妙的是，Go 语言让 ebitengine 实现了跨平台！

## 安装

ebitengine 要求 Go 版本 >= 1.15。使用 go module 下载这个包：

```bash
go get -u github.com/hajimehoshi/ebiten/v2
```

## 生成游戏窗口

```go
package main

import (
  "log"

  "github.com/hajimehoshi/ebiten/v2"
  "github.com/hajimehoshi/ebiten/v2/ebitenutil"
)

type Game struct{}

func (g *Game) Update() error {
  return nil
}

func (g *Game) Draw(screen *ebiten.Image) {
  ebitenutil.DebugPrint(screen, "Hello, World")
}

func (g *Game) Layout(outsideWidth, outsideHeight int) (screenWidth, screenHeight int) {
  return 200, 200
}

func main() {
  ebiten.SetWindowSize(200, 200)
  ebiten.SetWindowTitle("游戏窗口")
  if err := ebiten.RunGame(&Game{}); err != nil {
    log.Fatal(err)
  }
}
```

运行这个程序，会弹出一个窗口，标题为“生成游戏窗口”，窗口大小为 200x200，并显示“Hello, World”字样。

## 核心接口

首先，ebiten 引擎运行时要求传入一个游戏对象，该对象的必须实现`ebiten.Game`这个接口：

```go
// Game defines necessary functions for a game.
type Game interface {
  // 在 Update 函数里填写数据更新的逻辑
  Update() error

  // 在 Draw 函数里填写图像渲染的逻辑
  Draw(screen *Image)

  // 在 Layout 函数里填写窗口布局的逻辑
  Layout(outsideWidth, outsideHeight int) (screenWidth, screenHeight int)
}
```

`Update` 函数在每一帧都会被调用，用来更新游戏数据。`Draw` 函数在每一帧都会被调用，用来渲染图像。`Layout` 函数在窗口大小改变时会被调用，用来调整窗口的布局。

## 响应键盘输入

```go
func (g *Game) Update() error {
    if inpututil.IsKeyJustPressed(ebiten.KeyArrowLeft) || inpututil.IsKeyJustPressed(ebiten.KeyA) {
        fmt.Println("左键 ⬅️")
    } else if inpututil.IsKeyJustPressed(ebiten.KeyArrowRight) || inpututil.IsKeyJustPressed(ebiten.KeyD) {
        fmt.Println("右键 ➡️️")
    } else if inpututil.IsKeyJustPressed(ebiten.KeyArrowDown) || inpututil.IsKeyJustPressed(ebiten.KeyS) {
        fmt.Println("下键 ⬇️️")
    } else if inpututil.IsKeyJustPressed(ebiten.KeyArrowUp) || inpututil.IsKeyJustPressed(ebiten.KeyW) {
        fmt.Println("上键 ⬆️️")
    } else {
        fmt.Println("无效输入")
    }
    return nil
}
```
`inpututil.IsKeyJustPressed` 函数用来检测某个键是否刚刚被按下，如果是，则返回 `true`，否则返回 `false`。

## 设置背景

```go
func (g *Game) Draw(screen *ebiten.Image) {
  screen.Fill(color.RGBA{R: 200, G: 200, B: 200, A: 255})
}
```

`ebiten.Image` 是一个图像对象，可以通过 `Fill` 方法设置背景颜色。

## 绘制精灵

```go
type Sprite struct {
  x, y          float64
  width, height float64
  img  *ebiten.Image
}

func (s *Sprite) Update() error {
  return nil
}

func (s *Sprite) Draw(screen *ebiten.Image) {
  op := &ebiten.DrawImageOptions{}
  op.GeoM.Translate(s.x, s.y)
  screen.DrawImage(s.img, op)
}

func NewSprite() *Sprite {
  img, _, err := ebitenutil.NewImageFromFile("../images/sprite.png")
  if err != nil {
    log.Fatal(err)
  }

  width, height := img.Size()
  ship := &Ship{
    image:  img,
    width:  width,
    height: height,
  }

  return ship
}
```

ebiten 引擎提供了 `ebiten.Image` 对象，可以用来绘制图像。`ebiten.DrawImageOptions` 用来设置图像的位置、旋转、缩放等属性。

```go
func (g *Game) Draw(screen *ebiten.Image) {
  // 绘制背景
  screen.Fill(color.RGBA{R: 200, G: 200, B: 200, A: 255})
  // 绘制精灵
  op := &ebiten.DrawImageOptions{}
  op.GeoM.Translate(float64(200-g.sprite.width)/2, float64(200-g.sprite.height))
  screen.DrawImage(g.sprite.image, op)
}
```

## 移动精灵

```go
func (g *Game) Update() error {
  if inpututil.IsKeyJustPressed(ebiten.KeyArrowLeft) || inpututil.IsKeyJustPressed(ebiten.KeyA) {
    g.sprite.x -= 10
  } else if inpututil.IsKeyJustPressed(ebiten.KeyArrowRight) || inpututil.IsKeyJustPressed(ebiten.KeyD) {
    g.sprite.x += 10
  } else if inpututil.IsKeyJustPressed(ebiten.KeyArrowDown) || inpututil.IsKeyJustPressed(ebiten.KeyS) {
    g.sprite.y += 10
  } else if inpututil.IsKeyJustPressed(ebiten.KeyArrowUp) || inpututil.IsKeyJustPressed(ebiten.KeyW) {
    g.sprite.y -= 10
  }
  return nil
}
```

`g.sprite.x` 和 `g.sprite.y` 用来记录精灵的位置。

## 碰撞检测

```go
func (g *Game) Update() error {
  if inpututil.IsKeyJustPressed(ebiten.KeyArrowLeft) || inpututil.IsKeyJustPressed(ebiten.KeyA) {
    g.sprite.x -= 10
  } else if inpututil.IsKeyJustPressed(ebiten.KeyArrowRight) || inpututil.IsKeyJustPressed(ebiten.KeyD) {
    g.sprite.x += 10
  } else if inpututil.IsKeyJustPressed(ebiten.KeyArrowDown) || inpututil.IsKeyJustPressed(ebiten.KeyS) {
    g.sprite.y += 10
  } else if inpututil.IsKeyJustPressed(ebiten.KeyArrowUp) || inpututil.IsKeyJustPressed(ebiten.KeyW) {
    g.sprite.y -= 10
  }

  // 碰撞检测
  for _, other := range g.sprites {
    if g.sprite != other && g.sprite.x < other.x+other.width && g.sprite.x+g.sprite.width > other.x && g.sprite.y < other.y+other.height && g.sprite.y+g.sprite.height > other.y {
      fmt.Println("碰撞了！")
    }
  }
  return nil
}
```
