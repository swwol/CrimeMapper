//
//  AddressTests.swift
//  StopAndSearch
//
//  Created by edit on 23/01/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import XCTest
@testable import StopAndSearch

class AddressTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
  
  func testAddressIsCorrectlyFormatted() {
    
  let address = Address()
    address.street = nil
    address.city = "London"
    address.postcode = nil
  
    XCTAssertTrue(address.addressFormattedForLabel() == "London")
    
    
  }
    
  
}
    
