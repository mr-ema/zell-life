# Zig Conway's Game Of Life 
This is a simple implementation of Conway's Game of Life using the Zig
programming language and the Raylib library for graphics.

</br>
</br>

## Navigation
- [Demo](#demo)
- [Features](#features)
- [Default Bindings](#default-bindings)
- [How To Build](#how-to-build-and-run-it)

</br>
</br>

## Resources
- [My DockerFile For Raylib Projects](https://gist.github.com/mr-ema/d78ec7fefb8ea1ed8b2907eb2f0dc9da)
- [Zig](https://ziglang.org)
- [Awesome Zig](https://github.com/C-BJ/awesome-zig)
- [Raylib](https://www.raylib.com)
- [Zig Raylib Bindings](https://github.com/ryupold/raylib.zig)
- [Zig Showdown](https://github.com/zig-community/Zig-Showdown)

</br>
</br>

## Features
- [x] Pause the simulation (with <scape> key)
- [x] Zoom in and out
- [x] Configurable speed
- [ ] Custom patterns

</br>
</br>

## Demo
![Demo](https://github.com/mr-ema/zell-life/blob/main/docs/demo.gif)

</br>
</br>

## Default Bindings
| Action                            |  Binding                          |
| --------------------------------- | --------------------------------- |
| Pause Simulation                  | `<SPACE>`                         |
| Purge Life                        | `<K>`                             |
| Toggle Edit Mode                  | `<E>`                             |
| Zoom In                           | `<=>` or `<WHEEL>`                |
| Zoom Out                          | `<->` or `<WHEEL>`                |
| Move Cam Around                   | `<MOUSE RIGHT>`                   |
| Toggle Cell State  (Edit Mode)    | `<MOUSE LEFT>`                    |

</br>
</br>

## How To Build And Run It
Before you start, make sure you have the required dependencies for
raylib installed. Refer to the official [raylib - build and installation
guide](https://github.com/raysan5/raylib#build-and-installation) for
instructions on setting up the necessary environment.

</br>

```
git clone --recurse-submodules https://github.com/mr-ema/zell-life
```
```
cd ./zell-life
```
```
zig build run
```

</br>
</br>
