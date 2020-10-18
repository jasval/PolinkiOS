//
//  DataManager.swift
//  Polink
//
//  Created by Josh Valdivia on 13/07/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation

public class DataManager {
	
	public enum Dir: String {
		case room
		case history
		case user
	}
	
	
	// Get Document Directory
	static fileprivate func getDocumentDirectory () -> URL {
		if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
			return url
		} else {
			fatalError("Unable to access document directory")
		}
	}

	// Get specified document directory and subdirectory accordingly
	static fileprivate func getSubDocumentDirectory (directoryName: DataManager.Dir, subDirectoryName: String?) -> URL {
		
		if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
			createDir(rootDirectory: url, directoryName: directoryName.rawValue)
			if subDirectoryName != nil {
				let subURL = url.appendingPathComponent(directoryName.rawValue)
				createDir(rootDirectory: subURL, directoryName: subDirectoryName!)
				let leafURL = subURL.appendingPathComponent(subDirectoryName!)
				return leafURL
			} else {
				let subURL = url.appendingPathComponent(directoryName.rawValue)
				return subURL
			}
		} else {
			fatalError("Unable to access document directory")
		}
	}
	
	// Save any kind of codable objects
	static func save <T:Encodable> (_ object: T, with fileName: String) {
		// A url that points to that file in particular
		let url = getDocumentDirectory().appendingPathComponent(fileName, isDirectory: false)

		let encoder = JSONEncoder()
		
		do {
			let data = try encoder.encode(object)
			if FileManager.default.fileExists(atPath: url.path) {
				try FileManager.default.removeItem(at: url)
			}
			FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
		} catch {
			fatalError(error.localizedDescription)
		}
	}
	
	// Save Room
	static func saveRoom (_ room: Room, with fileName: String) {
		let url = getSubDocumentDirectory(directoryName: DataManager.Dir.room, subDirectoryName: room.id)
		
		let encoder = JSONEncoder()
		
		do {
			let data = try encoder.encode(room)
			if FileManager.default.fileExists(atPath: url.path) {
				try FileManager.default.removeItem(at: url)
			}
			FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
		} catch {
			fatalError(error.localizedDescription)
		}
	}
	
	//
	
	// Load any kind of codable object
	static func load <T: Decodable> (fileName: String, with type: T.Type) -> T {
		let url = getDocumentDirectory().appendingPathComponent(fileName, isDirectory: false)
		if !FileManager.default.fileExists(atPath: url.path) {
			fatalError("File not found at path \(url.path)")
		}
		
		if let data = FileManager.default.contents(atPath: url.path) {
			do {
				let model = try JSONDecoder().decode(type, from: data)
				return model
			} catch {
				fatalError(error.localizedDescription)
			}
		} else {
			fatalError("Data is unavailable at specified path: \(url.path)")
		}
	}
	
	// Load data from a file without converting it to a model
	static func loadData (fileName: String) -> Data? {
		let url = getDocumentDirectory().appendingPathComponent(fileName, isDirectory: false)
		if !FileManager.default.fileExists(atPath: url.path) {
			fatalError("File not found at path \(url.path)")
		}
		
		if let data = FileManager.default.contents(atPath: url.path) {
			return data
		} else {
			fatalError("Data is unavailable at specified path: \(url.path)")
		}
	}
	
	// Load all files from a directory
	static func loadAll <T:Decodable> (_ type: T.Type) -> [T] {
		do {
			let files = try FileManager.default.contentsOfDirectory(atPath: getDocumentDirectory().path)
			
			var modelObjects = [T]()
			
			for fileName in files {
				modelObjects.append(load(fileName: fileName, with: type))
			}
			
			return modelObjects
			
		} catch {
			fatalError("Could not load any files")
		}
	}
	
	// Delete a file
	static func delete (_ fileName: String) {
		let url = getDocumentDirectory().appendingPathComponent(fileName, isDirectory: false)
		
		if FileManager.default.fileExists(atPath: url.path) {
			do {
				try FileManager.default.removeItem(at: url)
			} catch {
				fatalError(error.localizedDescription)
			}
		}
	}
	
	// Check if directory exists if not --> create it
	static func createDir (rootDirectory: URL, directoryName: String) {
//		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//		let documentsDirectory = paths[0]
//		let docURL = URL(string: documentsDirectory)!
		let dataPath = rootDirectory.appendingPathComponent(directoryName)
		
		if !FileManager.default.fileExists(atPath: dataPath.absoluteString) {
			do {
				try FileManager.default.createDirectory(atPath: dataPath.absoluteString, withIntermediateDirectories: true, attributes: nil)
			} catch {
				print(error.localizedDescription);
			}
		}
	}
	
	
}
