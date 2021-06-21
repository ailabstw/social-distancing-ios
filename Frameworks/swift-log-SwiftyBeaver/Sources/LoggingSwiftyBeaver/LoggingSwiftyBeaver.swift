//
//  LoggingSwiftyBeaver.swift
//  swift-log-SwiftyBeaver
//
//  Created by Shiva Huang on 2020/6/8.
//  Copyright © 2020 AI Labs. All rights reserved.
//

import Logging
@_exported import SwiftyBeaver

extension SwiftyBeaver {
    public struct LogHandler: Logging.LogHandler {
        public let label: String
        public var metadata: Logger.Metadata
        public var logLevel: Logger.Level
        
        public init(_ label: String, destinations: [BaseDestination], level: Logger.Level = .trace, metadata: Logger.Metadata = [:]) {
            self.label = label
            self.metadata = metadata
            self.logLevel = level
            destinations.forEach { SwiftyBeaver.addDestination($0) }
        }
        
        public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
            get { self.metadata[key] }
            set(newValue) { self.metadata[key] = newValue }
        }
        
        public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
            let formattedMessage = "\(source.isEmpty ? "" : "[\(source)] ")\(message)"

            switch level {
            case .trace:
                SwiftyBeaver.verbose(formattedMessage, file, function, line: Int(line), context: metadata)
                
            case .debug:
                SwiftyBeaver.debug(formattedMessage, file, function, line: Int(line), context: metadata)
                
            case .info:
                SwiftyBeaver.info(formattedMessage, file, function, line: Int(line), context: metadata)
                
            case .notice, .warning:
                SwiftyBeaver.warning(formattedMessage, file, function, line: Int(line), context: metadata)
                
            case .error, .critical:
                SwiftyBeaver.error(formattedMessage, file, function, line: Int(line), context: metadata)
            }
        }
    }
}

