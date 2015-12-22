import OMGHTTPURLRQ
import XCTest

class OMGFormURLEncodeTestCase: XCTestCase {
    func test1() {
        let input = [
            "propStr1": "str1",
            "propStr2": "str2",
            "propArr1": ["arrStr1[]", "arrStr2"]
        ]
        let output = OMGFormURLEncode(input)
        let expect = "propArr1[]=arrStr1%5B%5D&propArr1[]=arrStr2&propStr1=str1&propStr2=str2"
        XCTAssertEqual(output, expect)
    }

    func test2() {
        let input = ["key": " !\"#$%&'()*+,/[]"]
        let output = OMGFormURLEncode(input)
        let expect = "key=%20%21%22%23%24%25%26%27%28%29%2A%2B%2C%2F%5B%5D"
        XCTAssertEqual(output, expect)
    }

    func test3() {
        let input = ["key": ["key": "value"]]
        let output = OMGFormURLEncode(input)
        let expect = "key[key]=value"
        XCTAssertEqual(output, expect)
    }
    
    func test4() {
        let input = ["key": ["key": ["+": "value value", "-": ";"]]]
        let output = OMGFormURLEncode(input)
        let expect = "key[key][%2B]=value%20value&key[key][-]=%3B"
        XCTAssertEqual(output, expect)
    }
    
    func test5() {
        let rq = try! OMGHTTPURLRQ.GET("http://example.com", ["key": " !\"#$%&'()*+,/"])
        XCTAssertEqual(rq.URL!.query, "key=%20%21%22%23%24%25%26%27%28%29%2A%2B%2C%2F")
    }
    
    func test6() {
        let params = ["key": "%20%21%22%23%24%25%26%27%28%29%2A%2B%2C%2F"]
        let rq = try! OMGHTTPURLRQ.GET("http://example.com", params)
        XCTAssertEqual(rq.URL!.query, "key=%2520%2521%2522%2523%2524%2525%2526%2527%2528%2529%252A%252B%252C%252F")
    }
    
    func test7() {
        let params = ["key": "value"]
        let rq = try! OMGHTTPURLRQ.POST("http://example.com", JSON: params)
        
        let body = String(data: rq.HTTPBody!, encoding: NSUTF8StringEncoding)
        
        XCTAssertEqual("{\"key\":\"value\"}", body, "Parameters were not encoded correctly")
    }
    
    func test8() {
        let params = [["key": "value"]]
        let rq = try! OMGHTTPURLRQ.POST("http://example.com", JSON: params)
        
        let body = String(data: rq.HTTPBody!, encoding: NSUTF8StringEncoding)
        
        XCTAssertEqual("[{\"key\":\"value\"}]", body, "Parameters were not encoded correctly")
    }
}
