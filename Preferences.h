//
//  Preferences.h
//  LCSC Campus Life
//
//  Created by Super Student on 11/19/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Preferences : NSObject

@property (nonatomic, setter=setPrefOne:) BOOL prefOne;         // Entertainment
@property (nonatomic, setter=setPrefTwo:) BOOL prefTwo;         // Academics
@property (nonatomic, setter=setPrefThree:) BOOL prefThree;     // Activities
@property (nonatomic, setter=setPrefFour:) BOOL prefFour;       // Residence
@property (nonatomic, setter=setPrefFive:) BOOL prefFive;       // Athletics

+(Preferences *) getSharedInstance;

- (void) setPreference:(int) index :(BOOL)preference;
- (BOOL) getPreference:(int) index;
- (void) negatePreference:(int) index;

- (void) loadPreferences;
- (void) savePreferences;

@end
