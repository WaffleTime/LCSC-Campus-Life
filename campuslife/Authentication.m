//
//  Authentication.m
//  campuslife
//
//  Created by Super Student on 12/3/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import "Authentication.h"

@implementation Authentication


static Authentication *_sharedInstance;

+(Authentication *) getSharedInstance {
    if (!_sharedInstance) {
        _sharedInstance = [[Authentication alloc] init];
        
        //Just setting the default.
        [_sharedInstance setUserCanManageEvents:NO];
        
        [_sharedInstance setAuthCals:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"NO", @"Academics", @"NO", @"Student Activities", @"NO", @"Warrior Athletics", @"NO", @"Entertainment", @"NO", @"Residence Life", @"NO", @"Campus Rec", nil]];
        
        [_sharedInstance setCategoryNames:@[@"Entertainment", @"Academics", @"Student Activities", @"Residence Life", @"Warrior Athletics", @"Campus Life"]];
    }
    return _sharedInstance;
}



-(GoogleOAuth *) getAuthenticator {
    return _googleOAuth;
}

-(void) setAuthenticator:(GoogleOAuth *)authenticator {
    _googleOAuth = authenticator;
}

-(void) setDelegate:(UIViewController<GoogleOAuthDelegate> *)delegate {
    [_googleOAuth setGOAuthDelegate:delegate];
}

-(void) resetPriviledges
{
    [_sharedInstance setAuthCals:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"NO", @"Academics", @"NO", @"Student Activities", @"NO", @"Warrior Athletics", @"NO", @"Entertainment", @"NO", @"Residence Life", @"NO", @"Campus Rec", nil]];
}


@end
