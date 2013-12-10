//
//  Preferences.h
//  LCSC Campus Life
//
//  Created by Super Student on 11/19/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Preferences : NSObject

//Entertainment
@property (nonatomic, setter=setPrefOne:) BOOL prefOne;
//Academics
@property (nonatomic, setter=setPrefTwo:) BOOL prefTwo;
//Activities
@property (nonatomic, setter=setPrefThree:) BOOL prefThree;
//Residence
@property (nonatomic, setter=setPrefFour:) BOOL prefFour;
//Athletics
@property (nonatomic, setter=setPrefFive:) BOOL prefFive;

+(Preferences *) getSharedInstance;

- (void) setPreference:(int) index :(BOOL)preference;
- (BOOL) getPreference:(int) index;
- (void) negatePreference:(int) index;

- (void) loadPreferences;
- (void) savePreferences;

@end
