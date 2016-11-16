//
//  BYMacros.h
//  XcodeBasics
//
//  Created by Young, Braden on 11/13/16.
//  Copyright © 2016 Young, Braden. All rights reserved.
//

#ifndef BYMacros_h
#define BYMacros_h

#define sSwitch(__x)                    for (NSString *__sSwitchStr = (__x), *__sSwitchIdx = nil; __sSwitchIdx == nil; __sSwitchIdx = @"")
#define sCase(__x)                      if ([__sSwitchStr isEqualToString:(__x)])
#define sCases(...)                     if ([[NSSet setWithArray:@[__VA_ARGS__]] containsObject:__sSwitchStr])
#define sCaseSet(__x)                   if ([(__x) containsObject:__sSwitchStr])
#define sDefault

#endif /* BYMacros_h */
