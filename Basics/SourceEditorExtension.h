//
//  SourceEditorExtension.h
//  Basics
//
//  Created by Young, Braden on 10/26/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>

extern NSString * const BYCommandIdPrefix;
extern NSString * const BYCommandIsEquals;
extern NSString * const BYCommandNSCopying;
extern NSString * const BYCommandDeleteLines;

@interface SourceEditorExtension : NSObject <XCSourceEditorExtension>

@end
