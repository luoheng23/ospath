// Copyright (c) 2017 Hèctor Marquès Ranea
//
// This software contains code derived from:
// http://stackoverflow.com/a/24648951/870560
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

/// It reads from a file in chunks and converts complete lines to strings.
@available(macOS 10.15, *)
public class FileReader {
    let encoding: String.Encoding
    let chunkSize: Int
    let delimiterData: Data

    private(set) var fileHandle: FileHandle?
    private(set) var buffer: Data
    private(set) var atEof: Bool
    
    public var isClosed: Bool {
        return fileHandle == nil
    }
    
    public convenience init?(_ path: Int32, delimiter: String = "\n", encoding: String.Encoding = .utf8, chunkSize: Int = 4096) {
        let fileHandle = FileHandle(fileDescriptor: path)
        guard let delimiterData = delimiter.data(using: encoding) else { return nil }
        self.init(
            fileHandle: fileHandle,
            delimiterData: delimiterData,
            encoding: encoding,
            chunkSize: chunkSize
        )
    }

    public convenience init?(_ path: PathLike, delimiter: String = "\n", encoding: String.Encoding = .utf8, chunkSize: Int = 4096) {
        guard let fileHandle = FileHandle(forReadingAtPath: path.path) else { return nil }
        guard let delimiterData = delimiter.data(using: encoding) else { return nil }
        self.init(
            fileHandle: fileHandle,
            delimiterData: delimiterData,
            encoding: encoding,
            chunkSize: chunkSize
        )
    }
    
    init(fileHandle: FileHandle, delimiterData: Data, encoding: String.Encoding, chunkSize: Int) {
        self.encoding = encoding
        self.chunkSize = chunkSize
        self.fileHandle = fileHandle
        self.delimiterData = delimiterData
        self.buffer = Data(capacity: chunkSize)
        self.atEof = false
    }
    
    deinit {
        close()
    }

    /// Returns next line, or nil on EOF.
    public func readline() -> String? {
        precondition(fileHandle != nil, "Attempt to read from closed file")

        // Reads data chunks from file until a line delimiter is found:
        while !atEof {
            if let range = buffer.range(of: delimiterData) {
                // Convert complete line (excluding the delimiter) to a string:
                let line = String(data: buffer.subdata(in: 0..<range.lowerBound), encoding: encoding)
                // Remove line (and the delimiter) from the buffer:
                buffer.removeSubrange(0..<range.upperBound)
                return line
            }
            if let tmpData = try? fileHandle!.read(upToCount: chunkSize), tmpData.count > 0 {
                buffer.append(tmpData)
            } else {
                // EOF or read error.
                atEof = true
                if buffer.count > 0 {
                    // Buffer contains last line in file (not terminated by delimiter).
                    let line = String(data: buffer as Data, encoding: encoding)
                    buffer.count = 0
                    return line
                }
            }
        }
        return nil
    }

    public func readlines() -> [String] {
        var lines: [String] = []
        for line in self {
            lines.append(line)
        }
        return lines
    }

    public func read() -> String? {
        if let tmpData = try? fileHandle?.readToEnd(), tmpData.count > 0 {
            buffer.append(tmpData)
        }
        atEof = true
        if buffer.count > 0 {
            let string = String(data: buffer as Data, encoding: encoding)
            buffer.count = 0
            return string
        }
        return nil
    }

    /// Starts reading from the beginning of file.
    public func rewind() -> Void {
        fileHandle!.seek(toFileOffset: 0)
        buffer.count = 0
        atEof = false
    }
    
    /// Closes the underlying file. No reading must be done after calling this method.
    public func close() -> Void {
        fileHandle?.closeFile()
        fileHandle = nil
    }
}


extension FileReader: Sequence {
    open func makeIterator() -> AnyIterator<String> {
        return AnyIterator {
            return self.readline()
        }
    }
}


/// It reads from a file in chunks and converts complete lines to strings.
@available(macOS 10.15, *)
public class FileWriter {
    let encoding: String.Encoding
    let delimiterData: String
    var isAppend: Bool

    private(set) var fileHandle: FileHandle?
    
    public var isClosed: Bool {
        return fileHandle == nil
    }

    public convenience init?(_ path: PathLike, delimiter: String = "\n", encoding: String.Encoding = .utf8, isAppend: Bool = false) {
        guard let fileHandle = FileHandle(forWritingAtPath: path.path) else { return nil }
        self.init(
            fileHandle: fileHandle,
            delimiterData: delimiter,
            encoding: encoding,
            isAppend: isAppend
        )
        if isAppend {
            // append
            guard let _ = try? fileHandle.seekToEnd() else {
                // the file has been opened, so needs to close it
                try? close()
                return nil
            }
        }
    }
    
    init(fileHandle: FileHandle, delimiterData: String, encoding: String.Encoding, isAppend: Bool) {
        self.encoding = encoding
        self.isAppend = isAppend
        self.delimiterData = delimiterData
    }
    
    deinit {
        _ = try? close()
    }

    public func writeline(_ line: String) throws {
        precondition(fileHandle != nil, "Attempt to write to closed file")

        if let data = (line + delimiterData).data(using: encoding) {
            try fileHandle!.write(contentsOf: data)
        }
    }

    public func writelines(_ lines: [String]) throws {
        for line in lines {
            try writeline(line)
        }
    }

    public func write(_ line: String) throws {
        precondition(fileHandle != nil, "Attempt to write to closed file")

        if let data = line.data(using: encoding) {
            try fileHandle!.write(contentsOf: data)
        }
    }

    /// Closes the underlying file. No reading must be done after calling this method.
    public func close() throws {
        try fileHandle?.close()
        fileHandle = nil
    }
}
