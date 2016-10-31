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

typedef NS_ENUM(NSUInteger, BYSourceFileType) {
    BYSourceFileTypeUnknown,
    BYSourceFileTypeHeader,
    BYSourceFileTypeImplementation
};

@interface BYSourceInfo : NSObject

@property (nonatomic, readonly) BYSourceLanguage sourceLanguage;
@property (nonatomic, readonly) BYSourceFileType fileType;

- (instancetype)initWithContentUTI:(NSString *)contentUTI; 

@end
