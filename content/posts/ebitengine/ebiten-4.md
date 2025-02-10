+++
date = '2025-02-10T09:34:21+08:00'
draft = false
title = '[Ebitengine] (四) 动画类animation'
description = ""
summary = "封装简单动画类animation，并通过示例来展示如何使用animation类来实现动画效果。"
tags = ["Ebitengine", "Golang"]
# categories = [""]
# menu = "main"
+++

## 动画示例

```go
package main

import (
	"bytes"
	"image"
	_ "image/png"
	"log"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/examples/resources/images"
)

const (
	screenWidth  = 320
	screenHeight = 240

	frameOX     = 0
	frameOY     = 32
	frameWidth  = 32
	frameHeight = 32
	frameCount  = 8
)

var (
	runnerImage *ebiten.Image
)

type Game struct {
	count int
}

func (g *Game) Update() error {
	g.count++
	return nil
}

func (g *Game) Draw(screen *ebiten.Image) {
	op := &ebiten.DrawImageOptions{}
	op.GeoM.Translate(-float64(frameWidth)/2, -float64(frameHeight)/2)
	op.GeoM.Translate(screenWidth/2, screenHeight/2)
	i := (g.count / 5) % frameCount
	sx, sy := frameOX+i*frameWidth, frameOY
	screen.DrawImage(runnerImage.SubImage(image.Rect(sx, sy, sx+frameWidth, sy+frameHeight)).(*ebiten.Image), op)
}

func (g *Game) Layout(outsideWidth, outsideHeight int) (int, int) {
	return screenWidth, screenHeight
}

func main() {
	// Decode an image from the image file's byte slice.
	img, _, err := image.Decode(bytes.NewReader(images.Runner_png))
	if err != nil {
		log.Fatal(err)
	}
	runnerImage = ebiten.NewImageFromImage(img)

	ebiten.SetWindowSize(screenWidth*2, screenHeight*2)
	ebiten.SetWindowTitle("Animation (Ebitengine Demo)")
	if err := ebiten.RunGame(&Game{}); err != nil {
		log.Fatal(err)
	}
}
```

```bash
go run main.go
```

## 动画类animation

animation类是用来管理动画的类，它包含了多个帧的图片，可以控制播放速度，循环播放，以及动画的暂停等。

- 定义

```go
// FrameAnimation 帧动画类
type FrameAnimation struct {
	image         *ebiten.Image // 精灵图
	frameOX       int           // 帧的X偏移
	frameOY       int           // 帧的Y偏移
	frameWidth    int           // 每帧的宽度
	frameHeight   int           // 每帧的高度
	frameCount    int           // 总帧数
	currentFrame  int           // 当前帧
	loop          bool          // 是否循环播放
	elapsedTime   float64       // 已过去的时间
	frameDuration float64       // 每帧持续时间
	scale         float64       // 缩放比例
}
```

- 更新动画帧

```go
// Update 更新帧动画
func (fa *FrameAnimation) Update(elapsed float64) {
	fa.elapsedTime += elapsed
	if fa.elapsedTime >= fa.frameDuration {
		fa.elapsedTime -= fa.frameDuration
		fa.currentFrame++
		if fa.currentFrame >= fa.frameCount {
			if fa.loop {
				fa.currentFrame = 0
			} else {
				fa.currentFrame = fa.frameCount - 1
			}
		}
	}
}
```

- 绘制动画帧

```go
// Draw 绘制当前帧
func (fa *FrameAnimation) Draw(screen *ebiten.Image, x, y float64) {
	op := &ebiten.DrawImageOptions{}
	op.GeoM.Scale(fa.scale, fa.scale)
	op.GeoM.Translate(-float64(fa.frameWidth)/2, -float64(fa.frameHeight)/2)
	op.GeoM.Translate(x, y)
	sx, sy := fa.frameOX+fa.currentFrame*fa.frameWidth, fa.frameOY
	screen.DrawImage(fa.image.SubImage(image.Rect(sx, sy, sx+fa.frameWidth, sy+fa.frameHeight)).(*ebiten.Image), op)
	op.GeoM.Reset()
}
```

## 完整示例

```go
package animate

import (
	"image"

	"github.com/hajimehoshi/ebiten/v2"
)

// FrameAnimation 帧动画类
type FrameAnimation struct {
	image         *ebiten.Image // 精灵图
	frameOX       int           // 帧的X偏移
	frameOY       int           // 帧的Y偏移
	frameWidth    int           // 每帧的宽度
	frameHeight   int           // 每帧的高度
	frameCount    int           // 总帧数
	currentFrame  int           // 当前帧
	loop          bool          // 是否循环播放
	elapsedTime   float64       // 已过去的时间
	frameDuration float64       // 每帧持续时间
	scale         float64       // 缩放比例
}

// NewFrameAnimation 创建一个新的帧动画
func NewFrameAnimation(image *ebiten.Image, frameOX, frameOY, frameWidth, frameHeight, frameCount int, loop bool, frameDuration float64) *FrameAnimation {
	return &FrameAnimation{
		image:         image,
		frameOX:       frameOX,
		frameOY:       frameOY,
		frameWidth:    frameWidth,
		frameHeight:   frameHeight,
		frameCount:    frameCount,
		currentFrame:  0,
		loop:          loop,
		elapsedTime:   0,
		frameDuration: frameDuration,
		scale:         1,
	}
}

// Update 更新帧动画
func (fa *FrameAnimation) Update(elapsed float64) {
	fa.elapsedTime += elapsed
	if fa.elapsedTime >= fa.frameDuration {
		fa.elapsedTime -= fa.frameDuration
		fa.currentFrame++
		if fa.currentFrame >= fa.frameCount {
			if fa.loop {
				fa.currentFrame = 0
			} else {
				fa.currentFrame = fa.frameCount - 1
			}
		}
	}
}

// Draw 绘制当前帧
func (fa *FrameAnimation) Draw(screen *ebiten.Image, x, y float64) {
	op := &ebiten.DrawImageOptions{}
	op.GeoM.Scale(fa.scale, fa.scale)
	op.GeoM.Translate(-float64(fa.frameWidth)/2, -float64(fa.frameHeight)/2)
	op.GeoM.Translate(x, y)
	sx, sy := fa.frameOX+fa.currentFrame*fa.frameWidth, fa.frameOY
	screen.DrawImage(fa.image.SubImage(image.Rect(sx, sy, sx+fa.frameWidth, sy+fa.frameHeight)).(*ebiten.Image), op)
	op.GeoM.Reset()
}

// SetScale 设置缩放比例
func (fa *FrameAnimation) SetScale(scale float64) {
	fa.scale = scale
}
```

```go
package main

import (
	"bytes"
	"fmt"
	"image"
	"image/color"
	_ "image/png"
	"log"
	"math/rand"
	"time"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/ebitenutil"
	"github.com/hajimehoshi/ebiten/v2/examples/resources/images"
	"github.com/hajimehoshi/ebiten/v2/vector"
)

const (
	screenWidth  = 640
	screenHeight = 480
)

type player struct {
	x, y float64
	ani  *animate.FrameAnimation
}

type game struct {
	players    []*player
	lastUpdate time.Time
}

func newGame() *game {
	// 加载精灵图
	img, _, err := image.Decode(bytes.NewReader(images.Runner_png))
	if err != nil {
		log.Fatal(err)
	}
	playerImage := ebiten.NewImageFromImage(img)

	game := &game{
		players:    make([]*player, 10),
		lastUpdate: time.Now(),
	}

	var p *player
	for i := 0; i < 10; i++ {
		if i < 3 {
			p = &player{
				x:   float64(rand.Intn(screenWidth - 32)),
				y:   float64(rand.Intn(screenHeight - 32)),
				ani: animate.NewFrameAnimation(playerImage, 0, 0, 32, 32, 5, true, float64(rand.Intn(5)+1)*0.1),
			}
		} else if i > 7 {
			p = &player{
				x:   float64(rand.Intn(screenWidth - 32)),
				y:   float64(rand.Intn(screenHeight - 32)),
				ani: animate.NewFrameAnimation(playerImage, 0, 32*2, 32, 32, 4, true, float64(rand.Intn(5)+1)*0.1),
			}
		} else {
			p = &player{
				x:   float64(rand.Intn(screenWidth - 32)),
				y:   float64(rand.Intn(screenHeight - 32)),
				ani: animate.NewFrameAnimation(playerImage, 0, 32, 32, 32, 8, true, float64(rand.Intn(5)+1)*0.1),
			}
		}
		p.ani.SetScale(1 + float64(i)*0.1)
		game.players[i] = p
	}

	return game
}

func (g *game) Update() error {
	// 更新帧动画
	for _, player := range g.players {
		player.ani.Update(float64(time.Since(g.lastUpdate).Seconds()))
	}
	g.lastUpdate = time.Now()
	return nil
}

func (g *game) Draw(screen *ebiten.Image) {
	// 绘制背景
	vector.DrawFilledRect(screen, 0, 0, screenWidth, screenHeight, color.NRGBA{R: 100, G: 100, B: 100, A: 255}, true)

	// 绘制帧动画
	for _, player := range g.players {
		player.ani.Draw(screen, player.x, player.y)
	}

	// 绘制调试信息
	ebitenutil.DebugPrint(screen, fmt.Sprintf("FPS: %0.2f", ebiten.ActualFPS()))
}

func (g *game) Layout(outsideWidth, outsideHeight int) (int, int) {
	return screenWidth, screenHeight
}

func main() {
	game := newGame()
	ebiten.SetWindowSize(screenWidth, screenHeight)
	ebiten.SetWindowTitle("Frame Animation Example")
	if err := ebiten.RunGame(game); err != nil {
		log.Fatal(err)
	}
}
```

```bash
go run main.go
```
