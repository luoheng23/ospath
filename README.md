# ospath
![ospath](https://github.com/luoheng23/ospath/workflows/Swift/badge.svg)

This package aims to provide same functions as os.path module in python.

## Example
```swift
PosixPath.isabs("/home")  // true
PosixPath.join("/home", "hello", "good")  // /home/hello/good
PosixPath.dirname("/home/hello")  // /home
PosixPath.basename("/home/hello") // hello
```

## Installation
Put the following string in the dependencies of your `Package.swift`
```swift
.package(url: "https://github.com/luoheng23/ospath", from: "1.0.0")
```

## TODO
This work is not finished yet. More functions need to be implemented.