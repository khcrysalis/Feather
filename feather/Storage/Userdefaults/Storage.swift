//
//  Storage.swift
//  feather
//
//  Created by samara on 5/17/24.
//

import Foundation

@propertyWrapper
public struct Storage<Value> {
	public typealias Callback = (Value) -> Void
	let key: String
	let defaultValue: Value
	let callback: Callback?
	
	public init(key: String, defaultValue: Value, callback: Callback? = nil) {
		self.key = key
		self.defaultValue = defaultValue
		self.callback = callback
	}
	
	public var wrappedValue: Value {
		get {
			return UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue
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
				print("Decoding \(Value.self) failed. \(error)")
			}
			return defaultValue
		}
		
		set {
			do {
				let newData = try encoder.encode(newValue)
				UserDefaults.standard.set(newData, forKey: key)
				handler?(key, newValue)
			} catch {
				print(error)
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
