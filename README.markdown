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


## OMGUserAgent

If you just need a sensible UserAgent string for your application you can `pod OMGHTTPURLRQ/UserAgent` and then:

```objc
#import <OMGHTTPURLRQ/OMGUserAgent.h>

NSString *userAgent = OMGUserAgent();
```
