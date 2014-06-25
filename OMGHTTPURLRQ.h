@import Foundation.NSURLRequest;


@interface OMGHTTPURLRQ : NSObject

+ (NSMutableURLRequest *)GET:(NSString *)url :(NSDictionary *)parameters;
+ (NSMutableURLRequest *)POST:(NSString *)url :(NSDictionary *)parameters;
+ (NSMutableURLRequest *)POST:(NSString *)url JSON:(id)JSONObject;
+ (NSMutableURLRequest *)POST:(NSString *)url :(NSData *)payload filename:(NSString *)name;

@end
