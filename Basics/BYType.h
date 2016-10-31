//
//  BYType.h
//  XcodeBasics
//
//  Created by Young, Braden on 10/30/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BYType : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) Class typeClass;
@property (nonatomic) BYType *generic;
@property (nonatomic) BOOL primitive;

@end
