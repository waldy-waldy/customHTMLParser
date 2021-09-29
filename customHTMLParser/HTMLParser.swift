//
//  HTMLParser.swift
//  htmlParser
//
//  Created by neoviso on 9/29/21.
//

import Foundation
import UIKit

class tagsWithAttributes {
    var openTag: String = ""
    var closeTag: String = ""
    var attributes: [NSAttributedString.Key: Any]
    
    init(openTag: String, closeTag: String, attributes: [NSAttributedString.Key: Any]) {
        self.openTag = openTag
        self.closeTag = closeTag
        self.attributes = attributes
    }
}

class pStyles {
    var type: String = ""
    var value: String = ""
    
    init(type: String, value: String) {
        self.type = type
        self.value = value
    }
}

protocol HTMLParserProtocol {
    func htmlToString(_ html: String) -> NSAttributedString
}

class HTMLParser {
    
    func htmlToString(_ html: String) -> NSAttributedString {
        
        var attributesPArray = [pStyles]()
        var attributesArray = [NSAttributedString.Key: Any]()
        let pPattern = "<p([^<>]*)>"
        let tagsArray = [
            tagsWithAttributes(openTag: "<b>", closeTag: "</b>", attributes: [.font: UIFont.boldSystemFont(ofSize: 19)]),
            tagsWithAttributes(openTag: "<strong>", closeTag: "</strong>", attributes: [.font: UIFont.boldSystemFont(ofSize: 19)]),
            tagsWithAttributes(openTag: "<i>", closeTag: "</i>", attributes: [.font: UIFont.italicSystemFont(ofSize: 19)]),
            tagsWithAttributes(openTag: "<em>", closeTag: "</em>", attributes: [.font: UIFont.italicSystemFont(ofSize: 19)])
        ]
        
        let result = NSMutableAttributedString(string: html)
        for item in tagsArray {
            while true {
                let plStr = result.string as NSString
                let openTagRange = plStr.range(of: item.openTag)
                if openTagRange.length == 0 {
                    break
                }
    
                let affectedLocation = openTagRange.location + openTagRange.length
                let searchingRange = NSRange(location: affectedLocation, length: plStr.length - affectedLocation)
                let closeTagRange = plStr.range(of: item.closeTag, options: NSString.CompareOptions.init(rawValue: 0), range: searchingRange)
                result.setAttributes(item.attributes, range: NSRange(location: affectedLocation, length: closeTagRange.location - affectedLocation))
                result.deleteCharacters(in: closeTagRange)
                result.deleteCharacters(in: openTagRange)
            }
        }
        let regex = try? NSRegularExpression(pattern: pPattern, options: .caseInsensitive)
        while true {
            let tmpstr = result.string
            attributesArray.removeAll()
            attributesPArray.removeAll()
            let plStr = result.string as NSString
            if let match = regex?.firstMatch(in: tmpstr, options: [], range: NSRange(location: 0, length: tmpstr.utf16.count)) {
                if let tmp = Range(match.range(at: 1), in: html) {
                    let tmps = tmpstr[tmp]
                    let startIndex = tmps.index(tmps.firstIndex(of: "=")!, offsetBy: 2)
                    let endIndex = tmps.index(tmps.endIndex, offsetBy: -2)
                    let substr = tmps[startIndex...endIndex]
                    let tempArray = substr.split(separator: ";")
                    for i in tempArray {
                        let trimI = i.trimmingCharacters(in: .whitespacesAndNewlines)
                        let tmpar = trimI.split(separator: ":")
                        attributesPArray.append(pStyles(type: tmpar[0].trimmingCharacters(in: .whitespacesAndNewlines), value: tmpar[1].trimmingCharacters(in: .whitespacesAndNewlines)))
                    }
                    result.deleteCharacters(in: plStr.range(of: String(tmps)))
                    let plStr = result.string as NSString
                    let openTagRange = plStr.range(of: "<p>")
                    let affectedLocation = openTagRange.location + openTagRange.length
                    let searchingRange = NSRange(location: affectedLocation, length: plStr.length - affectedLocation)
                    let closeTagRange = plStr.range(of: "</p>", options: NSString.CompareOptions.init(rawValue: 0), range: searchingRange)
                    for it in attributesPArray {
                        let range = NSRange(location: affectedLocation, length: closeTagRange.location - affectedLocation)
                        switch it.type.lowercased() {
                        case "color":
                            result.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(name: it.value.lowercased()) as Any], range: range)
                        case "font-family":
                            result.addAttributes([NSAttributedString.Key.font: UIFont(name: it.value, size: 19) as Any], range: range)
                        case "background-color":
                            result.addAttributes([NSAttributedString.Key.backgroundColor: UIColor(name: it.value.lowercased()) as Any], range: range)
                        case "text-decoration":
                            result.addAttributes([NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: range)
                        case "direction":
                            if it.value.lowercased() == "rtl" {
                                result.addAttributes([NSAttributedString.Key.writingDirection: NSWritingDirection.rightToLeft], range: range)
                            }
                            else {
                                result.addAttributes([NSAttributedString.Key.writingDirection: NSWritingDirection.leftToRight], range: range)
                            }
                        case "text-align":
                            let paragraph = NSMutableParagraphStyle()
                            switch it.value.lowercased() {
                            case "center":
                                paragraph.alignment = .center
                            case "left":
                                paragraph.alignment = .left
                            case "right":
                                paragraph.alignment = .right
                            default:
                                print("empty")
                            }
                            result.addAttributes([NSAttributedString.Key.paragraphStyle: paragraph], range: range)
                        default:
                            print("empty")
                        }
                    }
                    result.replaceCharacters(in: closeTagRange, with: "\n")
                    result.deleteCharacters(in: openTagRange)
                }
            }
            else {
                break
            }
        }
        
        return result
    }
}

extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat

        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = hexString.substring(from: start)

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }

    public convenience init?(name: String) {
        let allColors = [
            "aliceblue": "#F0F8FFFF",
            "antiquewhite": "#FAEBD7FF",
            "aqua": "#00FFFFFF",
            "aquamarine": "#7FFFD4FF",
            "azure": "#F0FFFFFF",
            "beige": "#F5F5DCFF",
            "bisque": "#FFE4C4FF",
            "black": "#000000FF",
            "blanchedalmond": "#FFEBCDFF",
            "blue": "#0000FFFF",
            "blueviolet": "#8A2BE2FF",
            "brown": "#A52A2AFF",
            "burlywood": "#DEB887FF",
            "cadetblue": "#5F9EA0FF",
            "chartreuse": "#7FFF00FF",
            "chocolate": "#D2691EFF",
            "coral": "#FF7F50FF",
            "cornflowerblue": "#6495EDFF",
            "cornsilk": "#FFF8DCFF",
            "crimson": "#DC143CFF",
            "cyan": "#00FFFFFF",
            "darkblue": "#00008BFF",
            "darkcyan": "#008B8BFF",
            "darkgoldenrod": "#B8860BFF",
            "darkgray": "#A9A9A9FF",
            "darkgrey": "#A9A9A9FF",
            "darkgreen": "#006400FF",
            "darkkhaki": "#BDB76BFF",
            "darkmagenta": "#8B008BFF",
            "darkolivegreen": "#556B2FFF",
            "darkorange": "#FF8C00FF",
            "darkorchid": "#9932CCFF",
            "darkred": "#8B0000FF",
            "darksalmon": "#E9967AFF",
            "darkseagreen": "#8FBC8FFF",
            "darkslateblue": "#483D8BFF",
            "darkslategray": "#2F4F4FFF",
            "darkslategrey": "#2F4F4FFF",
            "darkturquoise": "#00CED1FF",
            "darkviolet": "#9400D3FF",
            "deeppink": "#FF1493FF",
            "deepskyblue": "#00BFFFFF",
            "dimgray": "#696969FF",
            "dimgrey": "#696969FF",
            "dodgerblue": "#1E90FFFF",
            "firebrick": "#B22222FF",
            "floralwhite": "#FFFAF0FF",
            "forestgreen": "#228B22FF",
            "fuchsia": "#FF00FFFF",
            "gainsboro": "#DCDCDCFF",
            "ghostwhite": "#F8F8FFFF",
            "gold": "#FFD700FF",
            "goldenrod": "#DAA520FF",
            "gray": "#808080FF",
            "grey": "#808080FF",
            "green": "#008000FF",
            "greenyellow": "#ADFF2FFF",
            "honeydew": "#F0FFF0FF",
            "hotpink": "#FF69B4FF",
            "indianred": "#CD5C5CFF",
            "indigo": "#4B0082FF",
            "ivory": "#FFFFF0FF",
            "khaki": "#F0E68CFF",
            "lavender": "#E6E6FAFF",
            "lavenderblush": "#FFF0F5FF",
            "lawngreen": "#7CFC00FF",
            "lemonchiffon": "#FFFACDFF",
            "lightblue": "#ADD8E6FF",
            "lightcoral": "#F08080FF",
            "lightcyan": "#E0FFFFFF",
            "lightgoldenrodyellow": "#FAFAD2FF",
            "lightgray": "#D3D3D3FF",
            "lightgrey": "#D3D3D3FF",
            "lightgreen": "#90EE90FF",
            "lightpink": "#FFB6C1FF",
            "lightsalmon": "#FFA07AFF",
            "lightseagreen": "#20B2AAFF",
            "lightskyblue": "#87CEFAFF",
            "lightslategray": "#778899FF",
            "lightslategrey": "#778899FF",
            "lightsteelblue": "#B0C4DEFF",
            "lightyellow": "#FFFFE0FF",
            "lime": "#00FF00FF",
            "limegreen": "#32CD32FF",
            "linen": "#FAF0E6FF",
            "magenta": "#FF00FFFF",
            "maroon": "#800000FF",
            "mediumaquamarine": "#66CDAAFF",
            "mediumblue": "#0000CDFF",
            "mediumorchid": "#BA55D3FF",
            "mediumpurple": "#9370D8FF",
            "mediumseagreen": "#3CB371FF",
            "mediumslateblue": "#7B68EEFF",
            "mediumspringgreen": "#00FA9AFF",
            "mediumturquoise": "#48D1CCFF",
            "mediumvioletred": "#C71585FF",
            "midnightblue": "#191970FF",
            "mintcream": "#F5FFFAFF",
            "mistyrose": "#FFE4E1FF",
            "moccasin": "#FFE4B5FF",
            "navajowhite": "#FFDEADFF",
            "navy": "#000080FF",
            "oldlace": "#FDF5E6FF",
            "olive": "#808000FF",
            "olivedrab": "#6B8E23FF",
            "orange": "#FFA500FF",
            "orangered": "#FF4500FF",
            "orchid": "#DA70D6FF",
            "palegoldenrod": "#EEE8AAFF",
            "palegreen": "#98FB98FF",
            "paleturquoise": "#AFEEEEFF",
            "palevioletred": "#D87093FF",
            "papayawhip": "#FFEFD5FF",
            "peachpuff": "#FFDAB9FF",
            "peru": "#CD853FFF",
            "pink": "#FFC0CBFF",
            "plum": "#DDA0DDFF",
            "powderblue": "#B0E0E6FF",
            "purple": "#800080FF",
            "rebeccapurple": "#663399FF",
            "red": "#FF0000FF",
            "rosybrown": "#BC8F8FFF",
            "royalblue": "#4169E1FF",
            "saddlebrown": "#8B4513FF",
            "salmon": "#FA8072FF",
            "sandybrown": "#F4A460FF",
            "seagreen": "#2E8B57FF",
            "seashell": "#FFF5EEFF",
            "sienna": "#A0522DFF",
            "silver": "#C0C0C0FF",
            "skyblue": "#87CEEBFF",
            "slateblue": "#6A5ACDFF",
            "slategray": "#708090FF",
            "slategrey": "#708090FF",
            "snow": "#FFFAFAFF",
            "springgreen": "#00FF7FFF",
            "steelblue": "#4682B4FF",
            "tan": "#D2B48CFF",
            "teal": "#008080FF",
            "thistle": "#D8BFD8FF",
            "tomato": "#FF6347FF",
            "turquoise": "#40E0D0FF",
            "violet": "#EE82EEFF",
            "wheat": "#F5DEB3FF",
            "white": "#FFFFFFFF",
            "whitesmoke": "#F5F5F5FF",
            "yellow": "#FFFF00FF",
            "yellowgreen": "#9ACD32FF"
        ]

        let cleanedName = name.replacingOccurrences(of: " ", with: "").lowercased()

        if let hexString = allColors[cleanedName] {
            self.init(hexString: hexString)
        } else {
            return nil
        }
    }
}
