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
    
    CFStringRef contentUTIRef = (__bridge CFStringRef)contentUTI;
    
    if (UTTypeEqual(contentUTIRef, kUTTypeObjectiveCSource)) {  // .m
        _sourceLanguage = BYSourceLanguageObjc;
        _fileType = BYSourceFileTypeImplementation;
    }
    else if (UTTypeEqual(contentUTIRef, kUTTypeCHeader)) {      // .h
        _sourceLanguage = BYSourceLanguageObjc;
        _fileType = BYSourceFileTypeHeader;
    }
    else if (UTTypeEqual(contentUTIRef, kUTTypeSwiftSource)) {  // .swift
        _sourceLanguage = BYSourceLanguageSwift;
        _fileType = BYSourceFileTypeImplementation;
    }
    else {
        _sourceLanguage = BYSourceLanguageUnsupported;
        _fileType = BYSourceFileTypeUnknown;
    }
    
    return self;
}

@end
