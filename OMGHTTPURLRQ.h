#import <Foundation/NSData.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSURLRequest.h>
#import <Foundation/NSString.h>


@interface OMGHTTPURLRQ : NSObject

+ (NSMutableURLRequest *)GET:(NSString *)url :(NSDictionary *)parameters;
+ (NSMutableURLRequest *)POST:(NSString *)url :(NSDictionary *)parameters;
+ (NSMutableURLRequest *)POST:(NSString *)url JSON:(id)JSONObject;
+ (NSMutableURLRequest *)POST:(NSString *)url multipartForm:(void(^)(void(^addFile)(NSData *payload, NSString *name, NSString *filename)))body;
+ (NSMutableURLRequest *)PUT:(NSString *)url :(NSDictionary *)parameters;
+ (NSMutableURLRequest *)PUT:(NSString *)url JSON:(id)JSONObject;
+ (NSMutableURLRequest *)DELETE:(NSString *)url :(NSDictionary *)parameters;

@end
