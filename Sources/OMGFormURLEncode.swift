import Foundation

private func enc(input: String, _ ignore: String) -> String {
    let allowedSet = NSMutableCharacterSet(charactersInString: ignore)
    allowedSet.formUnionWithCharacterSet(.URLQueryAllowedCharacterSet())
    allowedSet.removeCharactersInString(":/?&=;+!@#$()',*")
    return input.stringByAddingPercentEncodingWithAllowedCharacters(allowedSet)!
}

private func DoQueryMagic(key: String?, value: NSObject) -> [String] {
    var parts = [String]()
    // Sort dictionary keys to ensure consistent ordering in query string,
    // which is important when deserializing potentially ambiguous sequences,
    // such as an array of dictionaries
    if let dictionary = value as? [String: NSObject] {
        for nestedKey in dictionary.keys.sort() {
            let recursiveKey = key != nil ? "\(key!)[\(nestedKey)]" : nestedKey
            parts += DoQueryMagic(recursiveKey, value: dictionary[nestedKey]!)
        }
    } else if let array = value as? [NSObject] {
        for nestedValue in array {
            parts += DoQueryMagic("\(key ?? "")[]", value: nestedValue)
        }
    } else if let set = value as? Set<NSObject> {
        for obj in set.sort( { $0.description < $1.description } ) {
            parts += DoQueryMagic(key, value: obj)
        }
    } else if let key = key {
        parts.append(key)
        parts.append(value.description)
    }
    return parts
}

/**
 Express this dictionary as a `application/x-www-form-urlencoded` string.
 
 Most users would recognize the result of this transformation as the query
 string in a browser bar. For our purposes it is the query string in a GET
 request and the HTTP body for POST, PUT and DELETE requests.
 
 If the parameters dictionary is nil or empty, returns nil.
*/
public func OMGFormURLEncode(parameters: [String: NSObject]) -> String {
    guard parameters.count > 0 else {
        return ""
    }
    var queryString = String()
    let array = DoQueryMagic(nil, value: parameters)
    var e = array.generate()
    while true {
        guard let obj = e.next() else {
            break
        }
        queryString += "\(enc(obj, "[]"))=\(enc(e.next() ?? "", ""))&"
    }
    return String(queryString.characters.dropLast())
}
