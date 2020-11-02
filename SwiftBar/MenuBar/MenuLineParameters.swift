import Cocoa

struct MenuLineParameters {
    let title: String
    let params: [String:String]

    init(line: String) {
        guard let index = line.range(of: "|") else {
            title = line
            params = [:]
            return
        }
        title = String(line[...index.lowerBound].dropLast())
        params = MenuLineParameters.getParams(from: String(line[index.upperBound...]).trimmingCharacters(in: .whitespaces))
    }

    static func getParams(from line: String) -> [String:String] {
        let scanner = Scanner(string: line)
        let keyValueSeparator = CharacterSet(charactersIn: "=")
        let quoteSeparator = CharacterSet(charactersIn: "\"'")

        var params: [String:String] = [:]

        while !scanner.isAtEnd {
            var key: String? = ""
            var value: String? = ""
            key = scanner.scanUpToCharacters(from: keyValueSeparator)
            _ = scanner.scanCharacters(from: keyValueSeparator)
            if scanner.scanCharacters(from: quoteSeparator) != nil {
                value = scanner.scanUpToCharacters(from: quoteSeparator)
                _ = scanner.scanCharacters(from: quoteSeparator)
            } else {
                value = scanner.scanUpToString(" ")
            }

            if let key = key?.trimmingCharacters(in: .whitespaces).lowercased(),
               let value = value?.trimmingCharacters(in: .whitespaces) {
                params[key] = value
            }
        }
        return params
    }

    var href: String? {
        params["href"]
    }

    var bash: String? {
        params["bash"]
    }

    var bashParams: [String] {
        var out: [String] = []
        for i in 1...10 {
            guard let param = params["param\(i)"] else {continue}
            out.append(param)
        }
        return out
    }

    var terminal: Bool {
        params["terminal"] != "false"
    }

    var refresh: Bool {
        params["refresh"] == "true"
    }

    var color: NSColor? {
        NSColor.webColor(from: params["color"])
    }

    var font: String? {
        params["font"]
    }

    var size: CGFloat? {
        guard let sizeStr = params["size"], let pSize = Int(sizeStr) else {return nil}
        return CGFloat(pSize)
    }

    var dropdown: Bool {
        params["dropdown"] != "false"
    }

    var trim: Bool {
        params["trim"] != "false"
    }

    var length: Int? {
        guard let lengthStr = params["length"], let pLength = Int(lengthStr) else { return nil }
        return pLength
    }

    var alternate: Bool {
        params["alternate"] == "true"
    }

    var image: NSImage? {
        if #available(OSX 11.0, *) {
            if let sfString = params["sfimage"] {
                let config = NSImage.SymbolConfiguration(scale: .large)
                return NSImage(systemSymbolName: sfString, accessibilityDescription: nil)?.withSymbolConfiguration(config)
            }
        }

        let image = NSImage.createImage(from: params["image"] ?? params["templateImage"], isTemplate: params["templateImage"] != nil)
        if let widthStr = params["width"], let width = Float(widthStr),
           let heightStr = params["height"], let height = Float(heightStr) {
            return image?.resizedCopy(w: CGFloat(width), h: CGFloat(height))
        }

        return image
    }

    var emojize: Bool {
        params["emojize"] != "false"
    }

    var tooltip: String? {
        params["tooltip"]
    }
}