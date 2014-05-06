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
        
        [_sharedInstance setCalIds:[[NSDictionary alloc] initWithObjectsAndKeys:@"0rn5mgclnhc7htmh0ht0cc5pgk@group.calendar.google.com", @"Academics",
                                    @"l9qpkh5gb7dhjqv8nm0mn098fk@group.calendar.google.com", @"Student Activities",
                                    @"d6jbgjhudph2mpef1cguhn4g9g@group.calendar.google.com", @"Warrior Athletics",
                                    @"m6h2d5afcjfnmaj8qr7o96q89c@group.calendar.google.com", @"Entertainment",
                                    @"gqv0n6j15pppdh0t8adgc1n1ts@group.calendar.google.com", @"Residence Life",
                                    @"h4j413d3q0uftb2crk0t92jjlc@group.calendar.google.com", @"Campus Rec", nil]];
        
        [_sharedInstance setEventIds:[[NSDictionary alloc] initWithObjectsAndKeys:@"lrg46te59n9o54f01qeug727tk", @"Academics",
                                    @"6fhomj6btb4eueb4rl0t1mqsdg", @"Student Activities",
                                    @"m2vg4ncj8bu7oechv50ltk84j4", @"Warrior Athletics",
                                    @"79uiotmngl52ana82ob7ibhc1s", @"Entertainment",
                                    @"mg2obo46a6nqb32v33otufivq8", @"Residence Life",
                                    @"650gme9itnmk2ofvo2crjrm2io", @"Campus Rec", nil]];
        
        [_sharedInstance setAuthCals:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"NO", @"Academics", @"NO", @"Student Activities", @"NO", @"Warrior Athletics", @"NO", @"Entertainment", @"NO", @"Residence Life", @"NO", @"Campus Rec", nil]];
        
        [_sharedInstance setCategoryNames:@[@"Entertainment", @"Academics", @"Student Activities", @"Residence Life", @"Warrior Athletics", @"Campus Rec"]];
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
