//  CacheTests.swift
//
//  Copyright (c) 2020, ShouDong Zheng
//  All rights reserved.

//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:

//  * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.

//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.

//  * Neither the name of the copyright holder nor the names of its
//    contributors may be used to endorse or promote products derived from
//    this software without specific prior written permission.

//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import XCTest
import SwiftCache

class CacheTests: XCTestCase {
    private var _cahce = SwiftCache<UserInfo>(ttlInSeconds: 5.0)
    private let _key = "TestKey"
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSet() {
        let userInfo = UserInfo(name: "ZHENG_ZHENG", age: 23)
        _cahce.set(key: _key, value: userInfo)
        
        if let value = _cahce.get(key: _key) {
            if value.age != userInfo.age || value.name != userInfo.name {
                XCTFail("Set failed!")
            }
        }
    }
    
    func testGet() {
        let userInfo = UserInfo(name: "ZHENG_ZHENG", age: 23)
        _cahce.set(key: _key, value: userInfo)
        
        if let value = _cahce.get(key: _key) {
            if value.age != userInfo.age || value.name != userInfo.name {
                XCTFail("Set failed!")
            }
        }
        
        Thread.sleep(forTimeInterval: 5)
        
        if let _ = _cahce.get(key: _key) {
            XCTFail("Set failed!")
        }
    }
    
    func testDelete() {
        let userInfo = UserInfo(name: "ZHENG_ZHENG", age: 23)
        _cahce.set(key: _key, value: userInfo)
        
        if !_cahce.exists(key: _key){
            XCTFail("Data not found!")
        }
        
        _cahce.delete(key: _key)
        
        if _cahce.exists(key: _key) {
            XCTFail("Data was not deleted successfully")
        }
    }
    
    func testPerformance() {
        let count = 10_0000
        for i in 1 ..< count {
            let key = "\(_key)_\(i)"
            let userInfo = UserInfo(name: "ZHENG_ZHENG", age: i)
            _cahce.set(key: key, value: userInfo)
        }
        
        for i in 1 ..< count {
            let key = "\(_key)_\(i)"
            if !_cahce.exists(key: key) {
                XCTFail("Data not found!")
            }
        }
        
        for i in 1 ..< count {
            let key = "\(_key)_\(i)"
            if let value = _cahce.get(key: key) {
                if value.name != "ZHENG_ZHENG" || value.age != i {
                    XCTFail("Incorrect data!")
                }
            }
        }
        
        for i in 1 ..< count {
            let key = "\(_key)_\(i)"
            _cahce.delete(key: key)
        }
        
        for i in 1 ..< count {
            let key = "\(_key)_\(i)"
            if _cahce.exists(key: key) {
                XCTFail("Data was not deleted successfully")
            }
        }
    }
}

internal class UserInfo {
    internal var name = ""
    internal var age = 0
    
    private init() {}
    public init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

