import Foundation

private var OMGMutableURLRequest: NSMutableURLRequest {
    let rq = NSMutableURLRequest()
    rq.setValue(OMGUserAgent, forHTTPHeaderField: "User-Agent")
    return rq
}

/**
 POST this with `OMGHTTPURLRQ`’s `POST(_:_:)` static method.
*/
public final class OMGMultipartFormData {
    private let boundary: String
    private let body: NSMutableData
    
    public init() {
        body = NSMutableData()
        boundary = String(format: "------------------------%08X%08X", arc4random(), arc4random())
    }
    
    private func add(payload: NSData, _ name: String, _ filename: String?, _ contentType: String?) {
        let ln1 = "--\(boundary)\r\n"
        let ln2: String = {
            var s = "Content-Disposition: form-data; "
            s += "name=\"\(name)\""
            if let filename = filename {
                s += "; filename=\"\(filename)\""
            }
            s += "\r\n"
            if let contentType = contentType {
                s += "Content-Type: \(contentType)\r\n"
            }
            s += "\r\n"
            return s
        }()
        
        body.appendData(ln1.dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(ln2.dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(payload)
        body.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    /**
     The `filename` parameter is optional. The content-type is optional, and
     if left `nil` will default to *octet-stream*.
    */
    public func addFile(payload: NSData, parameterName name: String, filename: String? = nil, contentType: String? = nil) {
        add(payload, name, filename, contentType ?? "application/octet-stream")
    }
    
    public func addText(text: String, parameterName: String) {
        add(text.dataUsingEncoding(NSUTF8StringEncoding)!, parameterName, nil, nil)
    }
    
    /**
     Technically adding parameters to a multipart/form-data request is abusing
     the specification. What we do is add each parameter as a text-item. Any
     API that expects parameters in a multipart/form-data request will expect
     the parameters to be encoded in this way.
    */
    public func addParameters(parameters: [String: NSObject]) {
        for (key, value) in parameters {
            addText(value.description, parameterName: key)
        }
    }
}

private var OMGInvalidURLError: NSError {
    return NSError(domain: NSURLErrorDomain, code: NSURLErrorUnsupportedURL, userInfo: [NSLocalizedDescriptionKey: "The provided URL was invalid."])
}

private func OMGFormURLEncodedRequest(urlString: String, _ method: String, _ parameters: [String: NSObject]) throws -> NSMutableURLRequest {
    guard let url = NSURL(string: urlString) else {
        throw OMGInvalidURLError
    }
    
    let rq = OMGMutableURLRequest
    rq.URL = url
    rq.HTTPMethod = method
    
    let queryString = OMGFormURLEncode(parameters)
    let data = queryString.dataUsingEncoding(NSUTF8StringEncoding)
    rq.addValue("8bit", forHTTPHeaderField: "Content-Transfer-Encoding")
    rq.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    rq.addValue(String(data?.length ?? 0), forHTTPHeaderField: "Content-Length")
    rq.HTTPBody = data
    
    return rq
}


/**
 The error will either be a JSON error (NSCocoaDomain :/) or in the NSURLErrorDomain
 with code: NSURLErrorUnsupportedURL.
*/
public struct OMGHTTPURLRQ {
    public static func GET(urlString: String, _ params: [String: NSObject] = [:]) throws -> NSMutableURLRequest {
        let queryString = OMGFormURLEncode(params)
        guard let url = NSURL(string: urlString + "?\(queryString)") else {
            throw OMGInvalidURLError
        }
        let rq = OMGMutableURLRequest
        rq.HTTPMethod = "GET"
        rq.URL = url
        return rq
    }
    
    public static func POST(urlString: String, _ parametersOrMultipartFormData: AnyObject = [:]) throws -> NSMutableURLRequest {
        guard let multipartFormData = parametersOrMultipartFormData as? OMGMultipartFormData else {
            return try OMGFormURLEncodedRequest(urlString, "POST", parametersOrMultipartFormData as? [String: NSObject] ?? [:])
        }
        guard let url = NSURL(string: urlString) else {
            throw OMGInvalidURLError
        }
        
        let charset = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))
        let contentType = "multipart/form-data; charset=\(charset); boundary=\(multipartFormData.boundary)"
        
        let data = multipartFormData.body.mutableCopy() as! NSMutableData
        let lastLine = "\r\n--\(multipartFormData.boundary)--\r\n"
        data.appendData(lastLine.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        let rq = OMGMutableURLRequest
        rq.URL = url
        rq.HTTPMethod = "POST"
        rq.addValue(contentType, forHTTPHeaderField: "Content-Type")
        rq.HTTPBody = data
        return rq
    }
    
    public static func POST(urlString: String, JSON params: NSObject) throws -> NSMutableURLRequest {
        guard let url = NSURL(string: urlString) else {
            throw OMGInvalidURLError
        }
        
        let JSONData = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        
        let rq = OMGMutableURLRequest
        rq.URL = url
        rq.HTTPMethod = "POST"
        rq.HTTPBody = JSONData
        rq.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        rq.setValue("json", forHTTPHeaderField: "Data-Type")
        return rq
    }
    
    public static func PUT(url: String, _ parameters: [String: NSObject] = [:]) throws -> NSMutableURLRequest {
        return try OMGFormURLEncodedRequest(url, "PUT", parameters)
    }
    
    public static func PUT(url: String, JSON params: NSObject) throws -> NSMutableURLRequest {
        let rq = try POST(url, params)
        rq.HTTPMethod = "PUT"
        return rq
    }
    
    public static func DELETE(url: String, _ parameters: [String: NSObject] = [:]) throws -> NSMutableURLRequest {
        return try OMGFormURLEncodedRequest(url, "DELETE", parameters)
    }
}
