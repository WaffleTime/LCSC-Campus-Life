//
//  Preferences.m
//  LCSC Campus Life
//
//  Created by Super Student on 11/19/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import "Preferences.h"

@implementation Preferences

static Preferences *_sharedInstance;

+(Preferences *) getSharedInstance {
    if (!_sharedInstance) {
        _sharedInstance = [[Preferences alloc] init];
        
        //Then load the preferences from previous sessions of the app.
        [_sharedInstance loadPreferences];
    }
    return _sharedInstance;
}

- (void) setPreference:(int) index :(BOOL)isSelected {
    switch(index) {
        case 1:
            [self setPrefOne:isSelected];
            break;
        case 2:
            [self setPrefTwo:isSelected];
            break;
        case 3:
            [self setPrefThree:isSelected];
            break;
        case 4:
            [self setPrefFour:isSelected];
            break;
        case 5:
            [self setPrefFive:isSelected];
            break;
        case 6:
            [self setPrefSix:isSelected];
            break;
    }
}

- (void) negatePreference:(int) index {
    switch(index) {
        case 1:
            [self setPrefOne:!_prefOne];
            break;
        case 2:
            [self setPrefTwo:!_prefTwo];
            break;
        case 3:
            [self setPrefThree:!_prefThree];
            break;
        case 4:
            [self setPrefFour:!_prefFour];
            break;
        case 5:
            [self setPrefFive:!_prefFive];
            break;
        case 6:
            [self setPrefSix:!_prefSix];
            break;
    }
}

- (BOOL) getPreference:(int) index {
    BOOL isSelected = YES;
    
    switch(index) {
        case 1:
            isSelected = _prefOne;
            break;
        case 2:
            isSelected = _prefTwo;
            break;
        case 3:
            isSelected = _prefThree;
            break;
        case 4:
            isSelected = _prefFour;
            break;
        case 5:
            isSelected = _prefFive;
            break;
        case 6:
            isSelected = _prefSix;
            break;
    }
    
    return isSelected;
}


//This is called when the instance is being initialized. Nowhere else. So it only loads once.
//The preferences are negated when being loaded, because a NO is returned when the object doesn't exist.
//  I want there to be a YES being returned by default. So when prefs are saved, they are negated and
//  when they're loaded they're being negated again to get the original state (but the default is YES instead of NO.)
- (void) loadPreferences
{
    //This is an object that we'll be loading our saved data from.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Load all of the prefences for the categories that are selected.
    [self setPrefOne:![defaults boolForKey:@"prefOne"]];
    [self setPrefTwo:![defaults boolForKey:@"prefTwo"]];
    [self setPrefThree:![defaults boolForKey:@"prefThree"]];
    [self setPrefFour:![defaults boolForKey:@"prefFour"]];
    [self setPrefFive:![defaults boolForKey:@"prefFive"]];
    [self setPrefSix:![defaults boolForKey:@"prefSix"]];
}

//This is called within AppDelegate when the app is being closed or brought to the background.
//The preferences are negated when being saved, because a NO is returned when the object doesn't exist.
//  I want there to be a YES being returned by default. So when prefs are saved, they are negated and
//  when they're loaded they're being negated again to get the original state (but the default is YES instead of NO.)
- (void) savePreferences
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Save the preferences for future sessions of the app.
    [defaults setBool:!_prefOne forKey:@"prefOne"];
    [defaults setBool:!_prefTwo forKey:@"prefTwo"];
    [defaults setBool:!_prefThree forKey:@"prefThree"];
    [defaults setBool:!_prefFour forKey:@"prefFour"];
    [defaults setBool:!_prefFive forKey:@"prefFive"];
    [defaults setBool:!_prefSix forKey:@"prefSix"];
    
    [defaults synchronize];
}



@end
