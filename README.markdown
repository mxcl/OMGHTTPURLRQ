# OMGHTTPURLRQ

Vital extensions to `NSURLRequest` that Apple left out for some reason.

```objc
NSMutableURLRequest *rq = [OMGHTTPURLRQ GET:@"http://api.com":@{@"key": @"value"}];

// application/x-www-form-urlencoded
NSMutableURLRequest *rq = [OMGHTTPURLRQ POST:@"http://api.com":@{@"key": @"value"}];

// multipart/form-data
NSMutableURLRequest *rq = [OMGHTTPURLRQ POST:url multipartForm:^(void(^addFile)(NSData *payload, id name, id filename)) {
    addFile(data1, @"file1", @"file1.png");
    addFile(data2, @"file2", @"file2.png");
}];

// application/json
NSMutableURLRequest *rq = [OMGHTTPURLRQ POST:@"http://api.com" JSON:@{@"key": @"value"}];

// PUT
NSMutableURLRequest *rq = [OMGHTTPURLRQ PUT:@"http://api.com":@{@"key": @"value"}];

// DELETE
NSMutableURLRequest *rq = [OMGHTTPURLRQ DELETE:@"http://api.com":@{@"key": @"value"}];
```

You can then pass these to an `NSURLConnection` or `NSURLSession`.


## OMGUserAgent

If you just need a sensible UserAgent string for your application you can `pod OMGHTTPURLRQ/UserAgent` and then:

```objc
#import <OMGHTTPURLRQ/OMGUserAgent.h>

NSString *userAgent = OMGUserAgent();
```

OMGHTTPURLRQ adds this User-Agent to all requests it generates automatically.


## Configuring an `NSURLSessionUploadTask`

If you need to use `NSURLSession`’s `uploadTask:` but it won’t work because your endpoint expects a multipart-form request, use this:

```objc
id config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:someID];
id session = [NSURLSession sessionWithConfiguration:config delegate:someObject delegateQueue:[NSOperationQueue new]];

NSURLRequest *rq = [OMGHTTPURLRQ POST:urlString multipartForm:^(void(^addFile)(NSData *payload, NSString *name, NSString *filename)){
    addFile(data, @"file", @"file.png");
}];

id path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"upload.NSData"];
[rq.HTTPBody writeToFile:path atomically:YES];

[[session uploadTaskWithRequest:rq fromFile:[NSURL fileURLWithPath:path]] resume];
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