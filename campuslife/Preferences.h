//
//  Preferences.h
//  LCSC Campus Life
//
//  Created by Super Student on 11/19/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Preferences : NSObject

<<<<<<< HEAD
@property (nonatomic, setter=setPrefOne:) BOOL prefOne;         // Entertainment
@property (nonatomic, setter=setPrefTwo:) BOOL prefTwo;         // Academics
@property (nonatomic, setter=setPrefThree:) BOOL prefThree;     // Activities
@property (nonatomic, setter=setPrefFour:) BOOL prefFour;       // Residence
@property (nonatomic, setter=setPrefFive:) BOOL prefFive;       // Athletics
=======
//These categories are hopefully accurate. I don't know if they'll change.

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
>>>>>>> 671e2bf5af4cbc90fe830930b84dc4f8afd2d9fd

+(Preferences *) getSharedInstance;

- (void) setPreference:(int) index :(BOOL)preference;
- (BOOL) getPreference:(int) index;
- (void) negatePreference:(int) index;

- (void) loadPreferences;
- (void) savePreferences;

@end
