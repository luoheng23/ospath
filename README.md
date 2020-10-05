# ospath
![ospath](https://github.com/luoheng23/ospath/workflows/Swift/badge.svg)

This package aims to provide same functions as `os.path` module in `python`.

## Introduction
There are 3 classes:
* `PosixPath` is for UNIX-like path.
* `NTPath` is for Windows path.
* `OS` is to create file, folder, symlink, etc.

There is an `OSPath`, it's a `typealias` to `NTPath` on Windows, or a `typealias` to `PosixPath` on UNIX-like os.

## Example
```swift
// path operation
PosixPath.isabs("/home")  // true
PosixPath.join("/home", "hello", "good")  // "/home/hello/good"
PosixPath.split("/home/hello")   // ("/home", "hello") 
PosixPath.dirname("/home/hello")  // "/home"
PosixPath.basename("/home/hello") // "hello"
PosixPath.splitext("foo.bar")   // ("foo", "bar")
PosixPath.normpath("/foo/../baz")  // "/baz"
PosixPath.realpath(".")   // current directory
PosixPath.abspath("~")    // home directory for current user
PosixPath.commonpath(["/usr/lib64", "/usr/lib"])  // "/usr"
PosixPath.commonprefix(["/usr/lib64", "/usr/lib"])  // "/usr/lib"
PosixPath.expanduser("~user") // home directory for user
NTPath.splitdrive("C:\\Program Files") // ("C:", "\\Program Files")

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

// OS operation
// These methods can accept String or URL
OS.symlink(file, link) // create a symlink
OS.link(file, link)   // create a hard link
OS.readlink(link)   // return the path of that link
OS.remove(file)    // remove file
OS.copy(file, dst) // copy file to dst
OS.move(file, dst) // move file to dst
OS.open(file)      // create a file
OS.mkdir(dir)   // create a directory
OS.makedirs()   // create a directory recursively

// others
OS.stat(file)   // get file metadata
OS.getcwd()     // get current directory
OS.home(user)   // get home directory of user 
```

## Installation
Put the following code in the dependencies of your `Package.swift`.
```swift
.package(url: "https://github.com/luoheng23/ospath", from: "1.2.0")
```
