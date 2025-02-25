+++
date = '2025-02-25T10:16:26+08:00'
draft = false
title = 'Go Event'
description = ""
summary = "Go事件总线系统设计"
tags = ["Golang"]
+++

## Event 接口定义

```go
// EventType 事件类型
type EventType int

// 实现 Event 接口
func (t EventType) Type() EventType {
    return t
}

// Event 接口
type Event interface {
    Type() EventType
}

// EventHandler 事件处理函数
type EventHandler func(event Event)

// EventBus 事件总线接口
type EventBus interface {
    Publish(event Event)
    Subscribe(etype EventType, handler EventHandler)
    Unsubscribe(etype EventType, handler EventHandler)
    UnsubscribeAll(etype EventType)
}
```

## EventBus 实现

```go
type eventbus struct {
    lock     *sync.RWMutex
    // 事件类型 -> 处理函数指针 -> []处理函数 (支持多次订阅)
    handlers map[EventType]map[uintptr][]EventHandler
}

func NewEventBus() EventBus {
    return &eventbus{
        lock:     &sync.RWMutex{},
        handlers: map[EventType]map[uintptr][]EventHandler{},
    }
}

// Publish 发布事件
func (eb *eventbus) Publish(event Event) {
    eb.lock.RLock()
    defer eb.lock.RUnlock()

    handlers := eb.handlers[event.Type()]
    for _, handler := range handlers {
        for _, fn := range handler {
            fn(event)
        }
    }
}

// Subscribe 订阅事件
func (eb *eventbus) Subscribe(etype EventType, handler EventHandler) {
    eb.lock.Lock()
    defer eb.lock.Unlock()

    if _, ok := eb.handlers[etype]; !ok {
        eb.handlers[etype] = map[uintptr][]EventHandler{}
    }

    ptr := reflect.ValueOf(handler).Pointer()
    eb.handlers[etype][ptr] = append(eb.handlers[etype][ptr], handler)
}

// Unsubscribe 取消订阅事件
func (eb *eventbus) Unsubscribe(etype EventType, handler EventHandler) {
    eb.lock.Lock()
    defer eb.lock.Unlock()

    if _, ok := eb.handlers[etype]; !ok {
        return
    }

    ptr := reflect.ValueOf(handler).Pointer()
    if _, ok := eb.handlers[etype][ptr]; !ok {
        return
    }

    l := len(eb.handlers[etype][ptr])
    if l > 0 {
        eb.handlers[etype][ptr] = eb.handlers[etype][ptr][:l-1]
    }

    if len(eb.handlers[etype][ptr]) == 0 {
        delete(eb.handlers[etype], ptr)
    }
}

// UnsubscribeAll 取消事件的所有订阅
func (eb *eventbus) UnsubscribeAll(etype EventType) {
    eb.lock.Lock()
    defer eb.lock.Unlock()

    if _, ok := eb.handlers[etype]; !ok {
        return
    }

    for ptr := range eb.handlers[etype] {
        delete(eb.handlers[etype], ptr)
    }
}
```

## Examples

```go
type MyEvent struct {
	Name string
	Age  int
}

func (MyEvent) Type() eventbus.EventType {
	return eventbus.EventType(1)
}

func main() {
	bus := eventbus.NewEventBus()
	// subscribe EventType(0) with anonymous handler
	bus.Subscribe(0, func(event eventbus.Event) {
		fmt.Println("anonymous handler received: ", event.Type())
	})
	bus.Publish(eventbus.EventType(0)) // anonymous handler will receive this event
	bus.UnsubscribeAll(0)              // unsubscribe all handlers of EventType(0)
	bus.Publish(eventbus.EventType(0)) // no handler will receive this event

	handler1 := func(event eventbus.Event) {
		myEvent := event.(MyEvent)
		println("handler1 received: ", myEvent.Name, myEvent.Age)
	}
	handler2 := func(event eventbus.Event) {
		myEvent := event.(MyEvent)
		println("handler2 received: ", myEvent.Name, myEvent.Age)
	}
	bus.Subscribe(MyEvent{}.Type(), handler1)   // subscribe event type 1 with handler1
	bus.Subscribe(MyEvent{}.Type(), handler1)   // subscribing twice will work as well
	bus.Subscribe(MyEvent{}.Type(), handler2)   // subscribe event type 1 with handler2
	bus.Publish(MyEvent{Name: "John", Age: 30}) // all handlers will receive this event

	bus.Unsubscribe(MyEvent{}.Type(), handler1)
	bus.Unsubscribe(MyEvent{}.Type(), handler2)
	bus.Publish(MyEvent{Name: "Jane", Age: 25}) // only one handler1 will receive this event

	bus.UnsubscribeAll(MyEvent{}.Type())
	bus.Publish(MyEvent{Name: "Bob", Age: 40}) // no handler will receive this event
}
```

## Run Example

```bash
go run .
```