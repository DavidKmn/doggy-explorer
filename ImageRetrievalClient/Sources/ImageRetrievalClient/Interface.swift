//
//  Interface.swift
//  doggy-explorer
//
//  Created by David Kaufman on 12/05/2021.
//

import Foundation
import Combine

//#if os(macOS)
//import AppKit
//public typealias CrossPlatformImage = NSImage
//#else
import UIKit
public typealias CrossPlatformImage = UIImage
//#endif

public struct ImageRetrievalClient {
    public init(
        getImage: @escaping (URL) -> AnyPublisher<CrossPlatformImage, Error>
    ) {
        self.getImage = getImage
    }
    
    public var getImage: (URL) -> AnyPublisher<CrossPlatformImage, Error>
    
    public struct Error: Swift.Error {
        public let underliying: Swift.Error
        public init(_ underliying: Swift.Error) {
            self.underliying = underliying
        }
    }
}
