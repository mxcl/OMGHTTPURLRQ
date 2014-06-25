# OMGHTTPURLRQ

The bits of `NSURLRequest` that Apple left out for some reason.

```objc

NSMutableURLRequest *rq = [OMGHTTPURLRQ GET:@"http://api.com":@{@"key": @"value"}];

// application/x-www-form-urlencoded
NSMutableURLRequest *rq = [OMGHTTPURLRQ POST:@"http://api.com":@{@"key": @"value"}];

// multipart/form-data
NSMutableURLRequest *rq = [OMGHTTPURLRQ POST:@"http://api.com":filedata filename:@"filename.jpg"];

// application/json
NSMutableURLRequest *rq = [OMGHTTPURLRQ POST:@"http://api.com" JSON:@{@"key": @"value"}];
```
