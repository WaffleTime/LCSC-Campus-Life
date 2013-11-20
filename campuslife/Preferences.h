//
//  Preferences.h
//  LCSC Campus Life
//
//  Created by Super Student on 11/19/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Preferences : NSObject

@property (nonatomic, setter=setPrefOne:) BOOL prefOne;
@property (nonatomic, setter=setPrefTwo:) BOOL prefTwo;
@property (nonatomic, setter=setPrefThree:) BOOL prefThree;
@property (nonatomic, setter=setPrefFour:) BOOL prefFour;
@property (nonatomic, setter=setPrefFive:) BOOL prefFive;

+(Preferences *) getSharedInstance;

- (void) setPreference:(int) index :(BOOL)preference;
- (BOOL) getPreference:(int) index;
- (void) negatePreference:(int) index;

- (void) loadPreferences;
- (void) savePreferences;

@end
