//
//  GiftCardUtilTests.swift
//  PIALibraryTests-iOS
//
//  Created by Jose Antonio Blaya Garcia on 20/8/18.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import XCTest
@testable import PIALibrary

class GiftCardUtilTests: XCTestCase {
    
    func testGiftCardUtilFormattedCode() {
        let giftCode = "1234567812345678"
        XCTAssertEqual(GiftCardUtil.friendlyRedeemCode(giftCode),
                       "1234-5678-1234-5678")
    }
    
    func testGiftCardUtilStrippedRedeemCode() {
        let giftCode = "1234-5678-1234-5678"
        XCTAssertEqual(GiftCardUtil.strippedRedeemCode(giftCode),
                       "1234567812345678")
    }
    
    func testFormatGiftCardCode() {
        var giftCode = "1234-5678-1234-5678"
        XCTAssertEqual(GiftCardUtil.plainRedeemCode(giftCode),
                       "1234567812345678")
        giftCode = "1234#5678-1234#5678"
        XCTAssertEqual(GiftCardUtil.plainRedeemCode(giftCode),
                       "1234567812345678")
        giftCode = "1234 5678 1234 5678"
        XCTAssertEqual(GiftCardUtil.plainRedeemCode(giftCode),
                       "1234567812345678")
    }

}
