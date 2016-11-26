//
//  BYObjcParserTests.m
//  XcodeBasics
//
//  Created by Young, Braden on 11/26/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BYObjcParser.h"

@interface BYObjcParserTests : XCTestCase

@end

@implementation BYObjcParserTests

- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    [super tearDown];
}

- (void)testParsePropertiesFromText {
    NSString *fileText = [self textForTest:0];
    XCTAssertNotNil(fileText);

    NSArray<BYProperty*> *properties = [BYObjcParser parsePropertiesFromText:fileText];
    XCTAssert(properties.count == 5);
}

#pragma mark - Helpers

- (NSString *)textForTest:(NSUInteger)testIndex {
    NSString *fileName = [NSString stringWithFormat:@"ObjcParser_%zd.txt", testIndex];
    
    NSURL *url = [[NSBundle bundleForClass:self.class] URLForResource:fileName withExtension:nil];
    XCTAssertNotNil(url, @"Failed find file; fileName=%@", fileName);
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    XCTAssertNotNil(data, @"Failed get data; url=%@", url);
    
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return text;
}

@end
