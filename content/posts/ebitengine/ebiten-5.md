+++
date = '2025-02-11T10:40:42+08:00'
draft = true
title = '[Ebitengine] (五) 动画状态机Animator'
description = ""
summary = "封装简单动画状态机Animator，实现不同动画间的切换。"
tags = ["Ebitengine", "Golang"]
# categories = [""]
# menu = "main"
+++

## 动画状态机Animator

```go
package animate

import "github.com/hajimehoshi/ebiten/v2"

// Animator 动画状态机，用于控制多个动画之间相互切换
type Animator struct {
	currentState string
	animations   map[string]*FrameAnimation
}

func NewAnimator(initState string, initFa *FrameAnimation) *Animator {
	a := &Animator{
		currentState: initState,
		animations:   make(map[string]*FrameAnimation),
	}
	a.animations[a.currentState] = initFa
	return a
}

func (a *Animator) Update(elapsed float64) {
	if fa, ok := a.animations[a.currentState]; ok {
		fa.Update(elapsed)
	}
}

func (a *Animator) Draw(screen *ebiten.Image, x, y float64) {
	if fa, ok := a.animations[a.currentState]; ok {
		fa.Draw(screen, x, y)
	}
}

func (a *Animator) SetState(state string) {
	if state != a.currentState {
		a.currentState = state
	}
}

func (a *Animator) AddStateAnimation(state string, fa *FrameAnimation) {
	a.animations[state] = fa
}
```

## 示例

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

type enemy struct {
	x, y float64
	ani  *animate.Animator
}

type game struct {
	lastUpdate time.Time
	enemy      *enemy
}

func newGame() *game {
	// 加载精灵图
	img, _, err := image.Decode(bytes.NewReader(images.Runner_png))
	if err != nil {
		log.Fatal(err)
	}
	playerImage := ebiten.NewImageFromImage(img)

	en := &enemy{
		x:   10,
		y:   30,
		ani: animate.NewAnimator("idle", animate.NewFrameAnimation(playerImage, 0, 0, 32, 32, 5, true, 0.3)),
	}
	en.ani.AddStateAnimation("attack", animate.NewFrameAnimation(playerImage, 0, 32*2, 32, 32, 4, true, 0.5))
	en.ani.AddStateAnimation("run", animate.NewFrameAnimation(playerImage, 0, 32, 32, 32, 8, true, 0.1))
	en.ani.SetState("idle")

	game := &game{
		lastUpdate: time.Now(),
		enemy:      en,
	}
	return game
}

func (g *game) Update() error {
	elapsed := float64(time.Since(g.lastUpdate).Seconds())
	if ebiten.IsMouseButtonPressed(ebiten.MouseButtonLeft) {
		switch g.lastUpdate.Second() % 3 {
		case 0:
			g.enemy.ani.SetState("attack")
		case 1:
			g.enemy.ani.SetState("run")
		case 2:
			g.enemy.ani.SetState("idle")
		}
	}
    // 更新帧动画
	g.enemy.ani.Update(elapsed)
	g.lastUpdate = time.Now()
	return nil
}

func (g *game) Draw(screen *ebiten.Image) {
	// 绘制背景
	vector.DrawFilledRect(screen, 0, 0, screenWidth, screenHeight, color.NRGBA{R: 100, G: 100, B: 100, A: 255}, true)

	// 绘制帧动画
	g.enemy.ani.Draw(screen, g.enemy.x, g.enemy.y)

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
