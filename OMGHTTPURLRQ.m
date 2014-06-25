#import "OMGHTTPURLRQ.h"
#import "Chuzzle.h"

static inline NSString *enc(NSString *in) {
	return (__bridge_transfer  NSString *) CFURLCreateStringByAddingPercentEscapes(
            kCFAllocatorDefault,
            (__bridge CFStringRef)in.description,
            CFSTR("[]."),
            CFSTR(":/?&=;+!@#$()',*"),
            kCFStringEncodingUTF8);
}

static NSString *OMGUserAgent() {
    static NSString *ua;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        id info = [NSBundle mainBundle].infoDictionary;
        id name = info[@"CFBundleDisplayName"] ?: info[(__bridge NSString *)kCFBundleIdentifierKey];
        id vers = (__bridge id)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey) ?: info[(__bridge NSString *)kCFBundleVersionKey];
      #ifdef UIKIT_EXTERN
        float scale = ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [UIScreen mainScreen].scale : 1.0f);
        ua = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", name, vers, [UIDevice currentDevice].model, [UIDevice currentDevice].systemVersion, scale];
      #else
        ua = [NSString stringWithFormat:@"%@/%@", name, vers];
      #endif
    });
    return ua;
}

static inline NSMutableURLRequest *OMGMutableURLRequest() {
    NSMutableURLRequest *rq = [NSMutableURLRequest new];
    [rq setValue:OMGUserAgent() forHTTPHeaderField:@"User-Agent"];
    return rq;
}

static NSArray *DoQueryMagic(NSString *key, id value) {
    NSMutableArray *parts = [NSMutableArray new];

    // Sort dictionary keys to ensure consistent ordering in query string,
    // which is important when deserializing potentially ambiguous sequences,
    // such as an array of dictionaries
    #define sortDescriptor [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)]

    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[sortDescriptor]]) {
            id recursiveKey = key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey;
            [parts addObjectsFromArray:DoQueryMagic(recursiveKey, dictionary[nestedKey])];
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        for (id nestedValue in value)
            [parts addObjectsFromArray:DoQueryMagic([NSString stringWithFormat:@"%@[]", key], nestedValue)];
    } else if ([value isKindOfClass:[NSSet class]]) {
        for (id obj in [value sortedArrayUsingDescriptors:@[sortDescriptor]])
            [parts addObjectsFromArray:DoQueryMagic(key, obj)];
    } else
        [parts addObjectsFromArray:@[key, value]];

    return parts;

    #undef sortDescriptor
}

NSString *NSDictionaryToURLQueryString(NSDictionary *params) {
    if (!params.chuzzle)
        return nil;
    NSMutableString *s = [NSMutableString new];
    NSEnumerator *e = DoQueryMagic(nil, params).objectEnumerator;
    for (;;) {
        id obj = e.nextObject;
        if (!obj) break;
        [s appendFormat:@"%@=%@&", enc(obj), enc(e.nextObject)];
    }
    [s deleteCharactersInRange:NSMakeRange(s.length-1, 1)];
    return s;
}


@implementation OMGHTTPURLRQ

+ (NSMutableURLRequest *)GET:(NSString *)url :(NSDictionary *)params {
    id queryString = NSDictionaryToURLQueryString(params);
    id combine = [NSString stringWithFormat:@"%@?%@", url, queryString];
    NSMutableURLRequest *rq = OMGMutableURLRequest();
    rq.HTTPMethod = @"GET";
    rq.URL = [NSURL URLWithString:combine];
    return rq;
}

+ (NSMutableURLRequest *)POST:(NSString *)url :(NSData *)payload filename:(NSString *)name {
    NSMutableURLRequest *rq = OMGMutableURLRequest();
    rq.URL = [NSURL URLWithString:url];
    rq.HTTPMethod = @"POST";

    NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));

    id boundary1 = @"0xKhTmLbOuNdArY";
    id boundary2 = [NSString stringWithFormat:@"\r\n--%@\r\n", boundary1];

    id contentType = [NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@", charset, boundary1];
    [rq addValue:contentType forHTTPHeaderField:@"Content-Type"];

    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary1] dataUsingEncoding:NSUTF8StringEncoding]];

    // Sample Key Value for data
    [data appendData:[@"Content-Disposition: form-data; name=\"Key_Param\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[@"Value_Param" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[boundary2 dataUsingEncoding:NSUTF8StringEncoding]];

    // Sample file to send as data
    [data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"file\"\r\n", name] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:payload];
    [data appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary1] dataUsingEncoding:NSUTF8StringEncoding]];

    rq.HTTPBody = data;

    return rq;
}

+ (NSMutableURLRequest *)POST:(NSString *)url :(NSDictionary *)parameters {
    NSMutableURLRequest *rq = OMGMutableURLRequest();
    rq.URL = [NSURL URLWithString:url];
    rq.HTTPMethod = @"POST";

    id queryString = NSDictionaryToURLQueryString(parameters);
    id data = [queryString dataUsingEncoding:NSUTF8StringEncoding];
    [rq addValue:@"8bit" forHTTPHeaderField:@"Content-Transfer-Encoding"];
    [rq addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [rq addValue:[NSString stringWithFormat:@"%i", (int)[data length]] forHTTPHeaderField:@"Content-Length"];
    [rq setHTTPBody:data];

    return rq;
}

+ (NSMutableURLRequest *)POST:(NSString *)url JSON:(id)params {
    NSMutableURLRequest *rq = OMGMutableURLRequest();
    rq.URL = [NSURL URLWithString:url];
    rq.HTTPMethod = @"POST";
    rq.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    [rq setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [rq setValue:@"json" forHTTPHeaderField:@"Data-Type"];
    return rq;
}

@end


