//
//  StringProtocol+Base64Encode.swift
//  
//
//  Created by Higashihara Yoki on 2021/12/05.
//

import Foundation

extension StringProtocol {
    var data: Data { Data(utf8) }
    var base64Encoded: Data { data.base64EncodedData() }
    var base64EncodedString: String { data.base64EncodedString() }
}
