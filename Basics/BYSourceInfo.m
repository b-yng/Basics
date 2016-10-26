//
//  BYSourceInfo.m
//  gen
//
//  Created by Young, Braden on 10/9/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import "BYSourceInfo.h"

@implementation BYSourceInfo

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    _sourceLanguage = BYSourceLanguageUnsupported;
    
    return self;
}

- (void)setContentUTI:(NSString *)contentUTI {
    _contentUTI = contentUTI;
    
    CFStringRef contentUTIRef = (__bridge CFStringRef)contentUTI;
    
    if (UTTypeEqual(contentUTIRef, kUTTypeObjectiveCSource) ||  // .m
        UTTypeEqual(contentUTIRef, kUTTypeCHeader)) {           // .h
        _sourceLanguage = BYSourceLanguageObjc;
    }
    else if (UTTypeEqual(contentUTIRef, kUTTypeSwiftSource)) {  // .swift
        _sourceLanguage = BYSourceLanguageSwift;
    }
    else {
        _sourceLanguage = BYSourceLanguageUnsupported;
    }
}

@end
