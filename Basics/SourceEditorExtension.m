//
//  SourceEditorExtension.m
//  Basics
//
//  Created by Young, Braden on 10/26/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import "SourceEditorExtension.h"
@import AppKit;

NSString * const BYCommandIdPrefix = @"com.young.XcodeBasics";
NSString * const BYCommandIsEquals = @"isEquals";
NSString * const BYCommandNSCopying = @"NSCopying";
NSString * const BYCommandDeleteLines = @"Delete Lines";

@implementation SourceEditorExtension

#pragma mark - XCSourceEditorExtension

- (NSArray <NSDictionary <XCSourceEditorCommandDefinitionKey, id> *> *)commandDefinitions {
    return @[[self commandWithName:BYCommandIsEquals],
             [self commandWithName:BYCommandNSCopying],
             [self commandWithName:BYCommandDeleteLines]];
}

#pragma mark - Helpers

- (NSDictionary<XCSourceEditorCommandDefinitionKey, id> *)commandWithName:(NSString *)name {
    return @{ XCSourceEditorCommandClassNameKey : @"SourceEditorCommand",
              XCSourceEditorCommandIdentifierKey : [NSString stringWithFormat:@"%@.%@", BYCommandIdPrefix, name],
              XCSourceEditorCommandNameKey : name };
}

@end
