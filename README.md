# ospath
![ospath](https://github.com/luoheng23/ospath/workflows/Swift/badge.svg)

This package aims to provide same functions as os.path module in python.

## Example
```swift
// path operation
PosixPath.isabs("/home")  // true
PosixPath.join("/home", "hello", "good")  // "/home/hello/good"
PosixPath.dirname("/home/hello")  // "/home"
PosixPath.basename("/home/hello") // "hello"
PosixPath.split("/home/hello")   // ("/home", "hello")
PosixPath.splitext("foo.bar")   // ("foo", "bar")

// file operation
PosixPath.islink("filename")  // Return true if filename is a symbolic link
PosixPath.lexists("filename") // Return true if filename is a symbolic link, and its target is valid
PosixPath.isfile("filename")  // Return true if filename is a file
PosixPath.isdir("filename")  // Return true if filename is a directory
PosixPath.exists("filename") // Return true if filename exists

// metadata of file
PosixPath.getsize("filename") // Return the size of filename
PosixPath.getmtime("filename") // Return the mtime of filename
PosixPath.getctime("filename") // Return the ctime of filename
PosixPath.getatime("filename") // Return the atime of filename, this function doesn't work correctly
PosixPath.isReadable("filename") // Return true if filename is readable
PosixPath.isWritable("filename") // Return true if filename is writable
PosixPath.isExecutable("filename") // Return true if filename is executable
PosixPath.isDeletable("filename") // Return true if filename is deletable
```

## Installation
Put the following string in the dependencies of your `Package.swift`
```swift
.package(url: "https://github.com/luoheng23/ospath", from: "1.1.0")
```

## TODO
This work is not finished yet. More functions need to be implemented.