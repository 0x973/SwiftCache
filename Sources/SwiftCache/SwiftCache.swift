//  SwiftCache.swift
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

import Foundation

public struct SwiftCache<T> {
    private var _logger = CacheLogger()
    private let _checkInterval = 10.minutes
    private var _cache = Dictionary<String, CacheItem<T>>()
    private var _autoClear = true
    private var _ttl: TimeInterval = 0.0
    private var lock = NSLock()
    
    private init() {}
    
    public init(ttlInSeconds: TimeInterval, autoClear: Bool = true, printLog: Bool = true) {
        _logger.printLog = printLog
        _autoClear = autoClear
        _ttl = ttlInSeconds
        startCheckExpiryData()
    }
    
    private mutating func startCheckExpiryData() {
        if (!_autoClear) {
            return
        }
        
        var _self = self
        Timer.every(_self._checkInterval) {
            _self._logger.xcodeManagerPrintLog("Started check expiry data in background.", type: .info)
            _self.check()
        }
    }
    
    private mutating func check() {
        if (_cache.isEmpty) {
            return
        }
        
        let timestamp = Date().timeIntervalSince1970
        for element in _cache {
            if timestamp - element.value._timestamp >= _ttl {
                delete(key: element.key)
            }
        }
    }
    
    public mutating func set(key: String, value: T) {
        lock.lock()
        defer {
            lock.unlock()
        }
        
        _cache[key] = CacheItem<T>(key: key, value: value)
    }
    
    public mutating func get(key: String) -> T? {
        lock.lock()
        defer {
            lock.unlock()
        }
        
        if let item = _cache[key] {
            if Date().timeIntervalSince1970 - item._timestamp >= _ttl {
                self._logger.xcodeManagerPrintLog("Removing expired data. Key: \(key)", type: .info)
                remove(key: key)
                return nil
            }
            
            return item._value
        }
        
        return nil
    }
    
    public mutating func delete(key: String) {
        lock.lock()
        defer {
            lock.unlock()
        }
        
        remove(key: key)
    }
    
    private mutating func remove(key: String) {
        _cache.removeValue(forKey: key)
    }
    
    public mutating func exists(key: String) -> Bool {
        lock.lock()
        defer {
            lock.unlock()
        }
        
        if let _ = _cache[key] {
            return true
        }
        
        return false
    }
}
