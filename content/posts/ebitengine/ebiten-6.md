+++
date = '2025-02-20T09:31:39+08:00'
draft = false
title = '[Ebitengine] (六) 使用Ebiten-UI'
description = ""
summary = "使用 [Ebiten-UI](https://ebitenui.github.io/) 可以轻松地实现游戏中的UI元素"
tags = ["Ebitengine", "Golang"]
+++

## 核心概念

`Ebiten UI` 是一款基于 Ebiten 引擎的复杂且灵活的用户界面引擎。本页介绍了其中使用的概念。

## 保留模式

Ebiten UI 采用 [保留模式(Retained Mode)](https://en.wikipedia.org/wiki/Retained_mode) 模型来处理用户界面。这意味着对 Ebiten UI API 的调用（例如构造按钮）不会导致实际渲染。构造 UI 小部件是相当声明性的：UI 被构造为包含许多容器、小部件和布局，并且 Ebiten UI 本身会在适当的时候引发实际渲染调用。

## 小部件(Widget)层次结构

整个用户界面在 Ebiten UI 中构建为层次结构：

- 顶层是**UI类型**。它主要包含对根容器的引用，以及对工具提示渲染器、拖放渲染器和任何浮动窗口的引用。UI 用于渲染整个用户界面。它还负责在整个用户界面中传递事件。
- **容器**是将事物组合在一起的主要类型，例如一行按钮。容器可以包含任意数量的小部件以及其他容器。它们负责布局其子小部件。
- 在最低级别，有诸如按钮或复选框之类的**小部件**。

## 小部件

Widget类型在 Ebiten UI 中很特殊：由于 Go 仅使用组合而不是继承，因此每个小部件实现（例如按钮）都“有”一个 Widget。Widget 类型负责处理基本的小部件任务，例如记住位置，或触发光标进入/退出和点击事件。如果需要，它还包含小部件的布局数据（见下文）。

## 布局

在 Ebiten UI 中，通常不会手动布局小部件。相反，它们会作为子小部件组合到容器中，然后由容器的布局器负责布局小部件。

Ebiten UI 中有几个 Layouter 实现：

- `AnchorLayout` 只能定位一个 widget，它会将其锚定到容器的一角或边缘。它可以选择性地沿任意方向拉伸 widget。
- `GridLayout` 可以在网格中布局任意数量的小部件。它可以为每个网格单元定位不同的小部件，也可以拉伸它们。
- `RowLayout` 可在一行或一列中布置任意数量的小部件。它还可以以不同方式定位小部件，并根据需要拉伸它们。

## 九宫格

虽然 Ebiten 使用基本图像类型将图像绘制到屏幕上，但这对于许多小部件来说还不够。例如，按钮的图像需要根据按钮的文本进行拉伸或收缩，而不会扭曲图像。为此，Ebiten UI 采用了九宫缩放技术。

`NineSlice` 基本上是一个 3x3 的图像块网格：角块按原样绘制，而边缘块和中心块则被拉伸：

![NineSlice](https://upload.wikimedia.org/wikipedia/commons/thumb/7/7a/Traditional_scaling_vs_9-slice_scaling.svg/320px-Traditional_scaling_vs_9-slice_scaling.svg.png)

> 上图：传统缩放，角落扭曲。下图：9 片缩放，角落未扭曲。（图片：维基百科）

## 选项

在构建小部件或布局器时，它们中的大多数都支持许多选项来配置其渲染或行为。例如，按钮具有用于配置用于渲染的实际图像、按钮的文本、字体、文本颜色、填充等的选项。

举个例子，一个按钮可以像这样构造：

```go
button := widget.NewButton(
  // specify the images to use
  widget.ButtonOpts.Image(buttonImage),

  // specify the button's text, the font face, and the color
  widget.ButtonOpts.Text("Hello, World!", face, &widget.ButtonTextColor{
    Idle: color.RGBA{0xdf, 0xf4, 0xff, 0xff},
  }),

  // specify that the button's text needs some padding for correct display
  widget.ButtonOpts.TextPadding(widget.Insets{
    Left:  30,
    Right: 30,
  }),

  // ... click handler, etc. ...
)
```

有些选项对于每个小部件实现都是相同的，例如指定布局数据。在这种情况下，这些选项允许指定小部件选项：

```go
button := widget.NewButton(
  // ... other button options ...

  // set general widget options
  widget.ButtonOpts.WidgetOpts(
    // instruct the container's anchor layout to center the button
    // both horizontally and vertically
    widget.WidgetOpts.LayoutData(widget.AnchorLayoutData{
      HorizontalPosition: widget.AnchorLayoutPositionCenter,
      VerticalPosition:   widget.AnchorLayoutPositionCenter,
    }),
  ),
)
```

根据小部件的实现，某些选项是必须指定的（例如按钮的图像），而其他选项则是可选的。选项的顺序通常无关紧要。某些选项可能会指定多次。
