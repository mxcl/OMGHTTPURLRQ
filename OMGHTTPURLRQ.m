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
    id combine = url;
    if (queryString) combine = [combine stringByAppendingFormat:@"?%@",queryString];
    NSMutableURLRequest *rq = OMGMutableURLRequest();
    rq.HTTPMethod = @"GET";
    rq.URL = [NSURL URLWithString:combine];
    return rq;
}

+ (NSMutableURLRequest *)POST:(NSString *)url multipartForm:(void(^)(void(^)(NSData *payload, NSString *name, NSString *filename)))addFiles {

    id const boundary = [NSString stringWithFormat:@"Boundary+%08X%08X", arc4random(), arc4random()];
    id const charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    id const contentType = [NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@", charset, boundary];

    NSMutableData *body = [NSMutableData data];
    addFiles(^(NSData *payload, NSString *name, NSString *filename) {
        id ln1 = [NSString stringWithFormat:@"--%@\r\n", boundary];
        id ln2 = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, filename];
        id ln3 = @"Content-Type: application/octet-stream\r\n\r\n";
        id ln5 = [NSString stringWithFormat:@"\r\n--%@--\r\n", boundary];
        [body appendData:[ln1 dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[ln2 dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[ln3 dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:payload];
        [body appendData:[ln5 dataUsingEncoding:NSUTF8StringEncoding]];
    });

    NSMutableURLRequest *rq = OMGMutableURLRequest();
    [rq setURL:[NSURL URLWithString:url]];
    [rq setHTTPMethod:@"POST"];
    [rq addValue:contentType forHTTPHeaderField:@"Content-Type"];
    [rq setHTTPBody:body];
    return rq;
}

+ (NSMutableURLRequest *)POST:(NSString *)url :(NSDictionary *)parameters {
    NSMutableURLRequest *rq = OMGMutableURLRequest();
    rq.URL = [NSURL URLWithString:url];
    rq.HTTPMethod = @"POST";

    id queryString = NSDictionaryToURLQueryString(parameters);
    NSData *data = [queryString dataUsingEncoding:NSUTF8StringEncoding];
    [rq addValue:@"8bit" forHTTPHeaderField:@"Content-Transfer-Encoding"];
    [rq addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [rq addValue:@(data.length).description forHTTPHeaderField:@"Content-Length"];
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


