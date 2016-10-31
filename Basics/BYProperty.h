//
//  Property.h
//  gen
//
//  Created by Young, Braden on 10/6/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BYType.h"

@interface BYProperty : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) BYType *type;
@property (nonatomic) BOOL readonly;

@end
