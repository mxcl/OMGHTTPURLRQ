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
```
