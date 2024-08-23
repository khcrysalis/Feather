//
//  Storage.swift
//  feather
//
//  Created by samara on 5/17/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import Foundation

@propertyWrapper
struct Storage<Value> {
	typealias Callback = (Value) -> Void
	let key: String
	let defaultValue: Value
	let callback: Callback?
	
	init(key: String, defaultValue: Value, callback: Callback? = nil) {
		self.key = key
		self.defaultValue = defaultValue
		self.callback = callback
	}
	
	var wrappedValue: Value {
		get {
			if let storedValue = UserDefaults.standard.object(forKey: key) {
				if let castedValue = storedValue as? Value {
					return castedValue
				}
			}
			return defaultValue
		}
		set {
			UserDefaults.standard.set(newValue, forKey: key)
			callback?(newValue)
		}
	}

}


@propertyWrapper
public struct CodableStorage<Value: Codable> {
	public typealias Handler = (String, Value) -> Void
	
	var key: String
	var defaultValue: Value
	var handler: Handler? = nil
	
	public init(key: String, defaultValue: Value, handler: Handler? = nil) {
		self.key = key
		self.defaultValue = defaultValue
		self.handler = handler
	}
	
	public var wrappedValue: Value {
		get {
			guard let data = UserDefaults.standard.data(forKey: key) else {
				return defaultValue
			}
			do {
				let decoded = try decoder.decode(Value.self, from: data)
				return decoded
			} catch {
				Debug.shared.log(message: "Decoding \(Value.self) failed. \(error)")
			}
			return defaultValue
		}
		
		set {
			do {
				let newData = try encoder.encode(newValue)
				UserDefaults.standard.set(newData, forKey: key)
				handler?(key, newValue)
			} catch {
				Debug.shared.log(message: "\(error)")
			}
		}
	}
}

public let encoder: JSONEncoder = {
	let enc = JSONEncoder()
	enc.dateEncodingStrategy = .iso8601
	return enc
}()

public let decoder: JSONDecoder = {
	let dec = JSONDecoder()
	dec.dateDecodingStrategy = .iso8601
	return dec
}()
