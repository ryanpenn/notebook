+++
date = '2025-02-08T11:12:57+08:00'
draft = false
title = '[Ebitengine] (三) 绘制网格Grid'
# summary = ""
description = ""
tags = [""]
# categories = [""]
# menu = "main"
+++

## 定义网格单元格

- Cell的定义

```go
type Cell struct {
	X, Y  int               // 网格坐标
	Size  int               // 网格大小
	Color color.Color       // 网格颜色
    BorderColor color.Color // 网格边框颜色
}
```

- Cell的方法

```go
// SetColor 设置网格颜色
func (c *Cell) SetColor(color color.Color) {
	c.Color = color
}

func (c *Cell) SetBorderColor(color color.Color) {
	c.BorderColor = color
}

// Draw 绘制单元格
func (c *Cell) Draw(screen *ebiten.Image) {
	vector.DrawFilledRect(screen, float32(c.X), float32(c.Y), float32(c.Size), float32(c.Size), c.Color, true)
	vector.StrokeRect(screen, float32(c.X), float32(c.Y), float32(c.Size), float32(c.Size), 1, c.BorderColor, true)
}
```

## 定义网格

- Grid的定义

```go
type Grid struct {
	Width, Height int       // 网格大小(CellSize的倍数)
	Cells         []Cell
	CellSize      int
}
```

- Grid的方法

```go
// Update 更新网格
func (g *Grid) Update() error {
	if ebiten.IsMouseButtonPressed(ebiten.MouseButtonLeft) {
		x, y := ebiten.CursorPosition()
		count := len(g.Cells)
		for i := 0; i < count; i++ {
			cell := &g.Cells[i]
			if x >= cell.X && x <= cell.X+cell.Size && y >= cell.Y && y <= cell.Y+cell.Size {
                // Highlight selected cell in red
				cell.SetColor(color.NRGBA{R: 200, G: 0, B: 0, A: 255})
			} else {
                // Normal cell in white
				cell.SetColor(color.NRGBA{R: 255, G: 255, B: 255, A: 255})
			}
		}
	}
	return nil
}

// Draw 绘制网格
func (g *Grid) Draw(screen *ebiten.Image) {
	for _, cell := range g.Cells {
		cell.Draw(screen)
	}

	// 显示FPS
	ebitenutil.DebugPrint(screen, fmt.Sprintf("FPS: %0.2f", ebiten.ActualFPS()))
}

func (g *Grid) Layout(outsideWidth, outsideHeight int) (int, int) {
	return g.Width, g.Height
}
```

- 创建网格

```go
func NewGrid(width, height int, cellSize int) *Grid {
	cells := make([]Cell, 0)
	for y := 0; y < height; y += cellSize {
		for x := 0; x < width; x += cellSize {
			cell := Cell{
                X: x, 
                Y: y, 
                Size: cellSize, 
                Color: color.NRGBA{R: 255, G: 255, B: 255, A: 255},
                BorderColor: color.NRGBA{R: 0, G: 0, B: 0, A: 255}
            }
			cells = append(cells, cell)
		}
	}

	return &Grid{
		Width:     width,
		Height:    height,
		Cells:     cells,
		CellSize:  cellSize,
	}
}
```

## 运行

```go
func main() {
	ebiten.SetWindowSize(640, 640)
	ebiten.SetWindowTitle("Grid")

	grid := NewGrid(640, 640, 64)
	if err := ebiten.RunGame(grid); err != nil {
		panic(err)
	}
}
```

```bash
go run main.go
```
