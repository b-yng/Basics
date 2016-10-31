//
//  BYSourceInfo.h
//  gen
//
//  Created by Young, Braden on 10/9/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import <Foundation/Foundation.h>
@import XcodeKit;

typedef NS_ENUM(NSUInteger, BYSourceLanguage) {
    BYSourceLanguageUnsupported,
    BYSourceLanguageObjc,
    BYSourceLanguageSwift
};

@interface BYSourceInfo : NSObject

@property (nonatomic, readonly) BYSourceLanguage sourceLanguage;

- (instancetype)initWithContentUTI:(NSString *)contentUTI; 

@end
