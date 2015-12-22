# OMGHTTPURLRQ

Vital extensions to `NSURLRequest` that Apple left out for some reason.

```swift
let rq = try? OMGHTTPURLRQ.GET("http://api.com", ["key": "value"])

// application/x-www-form-urlencoded
let rq = try? OMGHTTPURLRQ.POST("http://api.com", ["key": "value"])

// application/json
let rq = try? OMGHTTPURLRQ.POST("http://api.com", JSON: ["key": "value"])

// PUT
let rq = try? OMGHTTPURLRQ.PUT("http://api.com", ["key": "value"])

// DELETE
let rq = try? OMGHTTPURLRQ.DELETE("http://api.com", ["key": "value"])
```

You can then pass these to an `NSURLSession`.


## `multipart/form-data`

OMG! Constructing multipart/form-data for POST requests is complicated, let us do it for you:

```swift

let multipartFormData = OMGMultipartFormData()

let data1 = NSData(contentsOfFile: "myimage1.png")!
multipartFormData.addFile(data1, parameterName: "file1", filename: "myimage1.png", contentType: "image/png")

// Ideally you would not want to re-encode the PNG, but often it is
// tricky to avoid it.
let image2 = UIImage(named: "image2")!
let data2 = UIImagePNGRepresentation(image2)!
multipartFormData.addFile(data2, parameterName: "file2", filename: "myimage2.png", contentType: "image/png")

// SUPER Ideally you would not want to re-encode the JPEG as the process
// is lossy. If you image comes from the AssetLibrary you *CAN* get the
// original `NSData`. See stackoverflow.com.
let image3 = UIImage(named: "image3")!
let data3 = UIImageJPEGRepresentation(image3, 0.8)!
multipartFormData.addFile(data3, parameterName: "file2", filename: "myimage3.jpeg", contentType: "image/jpeg")

let rq = try? OMGHTTPURLRQ.POST(url, multipartFormData)
```

Now feed `rq` to `NSURLSession.dataTaskWithRequest(_:completionHandler:)`.


## Configuring an `NSURLSessionUploadTask`

If you need to use `NSURLSession`’s `uploadTask` but you have become frustrated because your endpoint expects a multipart/form-data POST request and `NSURLSession` sends the data *raw*, use this:

```swift
let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(someID)
let session = NSURLSession.sessionWithConfiguration(config, delegate: someObject, delegateQueue: NSOperationQueue())

let multipartFormData = OMGMultipartFormData()
multipartFormData.addFile(data, parameterName: "file")

let rq = try! OMGHTTPURLRQ.POST(urlString, multipartFormData)

let path = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).last!).URLByAppendingPathComponent("upload.NSData").absoluteString
rq.HTTPBody?.writeToFile(path, atomically: true)

session.uploadTaskWithRequest(rq, fromFile: NSURL(fileURLWithPath: path)).resume()
```


## OMGUserAgent

If you just need a sensible UserAgent string for your application you can `pod OMGHTTPURLRQ/UserAgent` and then:

```Swift
import OMGHTTPURLRQ

let userAgent = OMGUserAgent
```

OMGHTTPURLRQ adds this User-Agent to all requests it generates automatically.

So for URLRequests generated **other** than by OMGHTTPURLRQ you would do:

```swift
someURLRequest.addValue(OMGUserAgent, forHTTPHeaderField: "User-Agent")
```


# Twitter Reverse Auth

You need an OAuth library, here we use the [TDOAuth](https://github.com/tweetdeck/TDOAuth) pod. You also need
your API keys that registering at https://dev.twitter.com will provide
you.

```swift
let rq = TDOAuth.URLRequestForPath("/oauth/request_token", POSTParameters: ["x_auth_mode": "reverse_auth"], host: "api.twitter.com", consumerKey: APIKey, consumerSecret: APISecret, accessToken: nil, tokenSecret: nil)
rq.addValue(OMGUserAgent, forHTTPHeaderField: "User-Agent")

NSURLSession.sharedSession().dataTaskWithRequest(rq) { (data, response, error) in
    let oauth = String(data: data, encoding: NSUTF8StringEncoding)!
    let reverseAuth = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, URL: NSURL(string: "https://api.twitter.com/oauth/access_token")!, parameters: [
        "x_reverse_auth_target": APIKey,
        "x_reverse_auth_parameters": oauth
    ])
    reverseAuth.account = account
    reverseAuth.performRequestWithHandler { (data, urlResponse, error) in
        let creds = String(data: data, encoding: NSUTF8StringEncoding)!.characters.split { $0 == "&" }
        var credsDict = [String: String]()
        for pair in creds {
            let pair = pair.split { $0 == "=" }
            credsDict[String(pair[0])] = String(pair[1])
        }
        print(credsDict)
    }
}.resume()
```


# License

```
Copyright 2014 Max Howell <mxcl@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```