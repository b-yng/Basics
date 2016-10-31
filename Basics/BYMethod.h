//
//  BYMethod.h
//  XcodeBasics
//
//  Created by Young, Braden on 10/30/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BYType.h"

@interface BYMethod : NSObject

@property (nonatomic) NSString *signature;
@property (nonatomic) BYType *returnType;
@property (nonatomic) BOOL isClassMethod;

@end
