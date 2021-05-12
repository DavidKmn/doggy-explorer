//
//  MediaFilesClient.swift
//  doggy-explorer
//
//  Created by David Kaufman on 12/05/2021.
//

import Foundation
import Combine

public extension ImageRetrievalClient {
    static let mock = Self(
        getImage: { url in
            Just(CrossPlatformImage.init())
                .setFailureType(to: ImageRetrievalClient.Error.self)
                .eraseToAnyPublisher()
        }
    )
}
