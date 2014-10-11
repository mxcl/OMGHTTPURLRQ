#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>

/**
 Express this dictionary as a `application/x-www-form-urlencoded` string.

 Most users would recognize the result of this transformation as the query
 string in a browser bar. For our purposes it is the query string in a GET
 request and the HTTP body for POST, PUT and DELETE requests.

 If the parameters dictionary is nil or empty, returns nil.
*/
NSString *OMGFormURLEncode(NSDictionary *parameters);
