//
//  BYGenerator.h
//  gen
//
//  Created by Young, Braden on 10/9/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BYProperty;

@protocol BYGenerator <NSObject>

- (NSMutableArray<NSString*> *)generateIsEquals:(NSArray<BYProperty*> *)properties;

- (NSMutableArray<NSString*> *)generateHash:(NSArray<BYProperty*> *)properties;

- (NSMutableArray<NSString*> *)generateCopyWithZone:(NSArray<BYProperty*> *)properties className:(NSString *)className;

@end
