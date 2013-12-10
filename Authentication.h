//
//  Authentication.h
//  campuslife
//
//  Created by Super Student on 12/3/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoogleOAuth.h"

@interface Authentication : NSObject

// A GoogleOAuth object that handles everything regarding the Google.
@property (nonatomic, strong) GoogleOAuth *googleOAuth;

//Is for determining if the user can manage events.
@property (nonatomic, getter=getUserCanManageEvents, setter=setUserCanManageEvents:) BOOL userCanManageEvents;


+(Authentication *) getSharedInstance;

-(GoogleOAuth *) getAuthenticator;

-(void) setAuthenticator:(GoogleOAuth *)authenticator;


@end
