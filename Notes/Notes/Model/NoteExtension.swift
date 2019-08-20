//
//  NoteExtension.swift
//  Notes
//
//  Created by Babette Alvyn sharp on 23/06/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//
import Foundation
import UIKit

extension Note {
	
	static func parse(json:[String: Any]) -> Note? {
		guard let title = json["title"] as? String,
		let content = json["content"] as? String,
		let uid = json["uid"] as? String
		else {
			return nil
		}
		
		let selfDestructDate: Date?
		if let unixtime = json["selfDestructDate"] as? Double {
			selfDestructDate = Date.init(timeIntervalSince1970: unixtime)
		} else {
			selfDestructDate = nil
		}
		
		let importance: ImportancyType
		if let rawStr = json["importance"] as? String, let tmpImportance = ImportancyType(rawValue: rawStr) {
			importance = tmpImportance
		} else {
			importance = .normal
		}
		
		//check color
		let color: UIColor
		if let colorDict = json["color"] as? [String: Double] {
			if let r = colorDict["r"], let g = colorDict["g"], let b = colorDict["b"], let a = colorDict["a"],
				r >= 0 && r <= 1, g >= 0 && g <= 1, b >= 0 && b <= 1, a >= 0 && a <= 1
			{
				color = UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
			} else {
				return nil
			}
		} else {
			color = UIColor.white
		}
		
		return Note(uid: uid, title: title, content: content, color: color, importance: importance, destructDate: selfDestructDate)
	}
	
	
	var json:[String: Any] {
		var result = [String: Any]()
		result["title"] = self.title
		result["content"] = self.content
		result["uid"] = self.uid
		
		if let delDate = self.selfDestructDate {
			result["selfDestructDate"] = delDate.timeIntervalSince1970
		}
		
        if let parsedColor = color.noteColorParse() {
            result["color"] = parsedColor
        }
		
		if self.importance != .normal {
			result["importance"] = self.importance.rawValue
		}
		return result
	}
	
}

extension UIColor {
    
    func noteColorParse() -> [String: Any]? {
        var colorDict: [String:Double]?
        if self != UIColor.white {
            colorDict = [:]
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            self.getRed(&r, green: &g, blue: &b, alpha: &a);
            colorDict!["r"] = Double(r)
            colorDict!["g"] = Double(g)
            colorDict!["b"] = Double(b)
            colorDict!["a"] = Double(a)
        }
        return colorDict
    }
}
