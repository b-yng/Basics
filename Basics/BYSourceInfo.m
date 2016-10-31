//
//  BYSourceInfo.m
//  gen
//
//  Created by Young, Braden on 10/9/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import "BYSourceInfo.h"

@implementation BYSourceInfo

- (instancetype)initWithContentUTI:(NSString *)contentUTI {
    self = [super init];
    if (!self) return nil;
    
    _sourceLanguage = [self sourceLanguageFromContentUTI:contentUTI];
    
    return self;
}

- (BYSourceLanguage)sourceLanguageFromContentUTI:(NSString *)contentUTI {
    BYSourceLanguage sourceLanguage = BYSourceLanguageUnsupported;
    CFStringRef contentUTIRef = (__bridge CFStringRef)contentUTI;
    
    if (UTTypeEqual(contentUTIRef, kUTTypeObjectiveCSource) ||  // .m
        UTTypeEqual(contentUTIRef, kUTTypeCHeader)) {           // .h
        sourceLanguage = BYSourceLanguageObjc;
    }
    else if (UTTypeEqual(contentUTIRef, kUTTypeSwiftSource)) {  // .swift
        sourceLanguage = BYSourceLanguageSwift;
    }
    else {
        sourceLanguage = BYSourceLanguageUnsupported;
    }
    
    return sourceLanguage;
}

@end
