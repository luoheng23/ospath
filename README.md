# ospath

this package aims to provide same functions with os.path module in python.

## Example
```swift
PosixPath.isabs("/home")  // true
PosixPath.join("/home", "hello", "good")  // /home/hello/good
PosixPath.dirname("/home/hello")  // /home
PosixPath.basename("/home/hello") // hello
```

## Installation
Put the following string in the dependencies of your Package.swift
```swift
.package(url: "https://github.com/luoheng23/ospath", from: "0.1")
```

## TODO
This work is not finished yet. More functions need to be implemented.