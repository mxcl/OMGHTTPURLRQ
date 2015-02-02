#import <OMGHTTPURLRQ/OMGFormURLEncode.h>
@import XCTest;


@interface Tests: XCTestCase @end @implementation Tests

- (void)test1 {
    id input = @{ 
        @"propStr1": @"str1",
        @"propStr2": @"str2",
        @"propArr1": @[@"arrStr1[]", @"arrStr2"]
    };
    id output = OMGFormURLEncode(input);
    id expect = @"propArr1[]=arrStr1%5B%5D&propArr1[]=arrStr2&propStr1=str1&propStr2=str2";
    XCTAssertEqualObjects(output, expect);
}

- (void)test2 {
    id input = @{@"key": @" !\"#$%&'()*+,/[]"};
    id output = OMGFormURLEncode(input);
    id expect = @"key=%20%21%22%23%24%25%26%27%28%29%2A%2B%2C%2F%5B%5D";
    XCTAssertEqualObjects(output, expect);
}

- (void)test3 {
    id input = @{@"key": @{@"key": @"value"}};
    id output = OMGFormURLEncode(input);
    id expect = @"key[key]=value";
    XCTAssertEqualObjects(output, expect);
}

- (void)test4 {
    id input = @{@"key": @{@"key": @{@"+": @"value value", @"-": @";"}}};
    id output = OMGFormURLEncode(input);
    id expect = @"key[key][%2B]=value%20value&key[key][-]=%3B";
    XCTAssertEqualObjects(output, expect);
}

@end
