//
//  Live.swift
//  doggy-explorer
//
//  Created by David Kaufman on 12/05/2021.
//

import Foundation
import Kingfisher
import Combine
import ImageRetrievalClient

public extension ImageRetrievalClient {
    static var live: Self {
        .init(getImage: { url in
            Deferred {
                Future { result in
                    KingfisherManager.shared.retrieveImage(with: url, options: [
                        .processor(DownsamplingImageProcessor(size: .init(width: 600, height: 600)))
                    ]) { (kfResult) in
                        switch kfResult {
                        case .success(let value):
                            result(.success(value.image))
                        case .failure(let error):
                            result(.failure(Error(error)))
                        }
                    }
                }
            }
            .eraseToAnyPublisher()
        })
    }
}
