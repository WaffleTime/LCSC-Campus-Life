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

@property (nonatomic, strong, setter=setActivitiesCalId:, getter=getActivitiesCalId) NSString *activitiesCalId;
@property (nonatomic, strong, setter=setEntertainmentCalId:, getter=getEntertainmentCalId) NSString *entertainmentCalId;
@property (nonatomic, strong, setter=setResidenceCalId:, getter=getResidenceCalId) NSString *residenceCalId;
@property (nonatomic, strong, setter=setAthleticsCalId:, getter=getAthleticsCalId) NSString *athleticsCalId;
@property (nonatomic, strong, setter=setAcademicsCalId:, getter=getAcademicsCalId) NSString *academicsCalId;
@property (nonatomic, strong, setter=setCampusRecCalId:, getter=getCampusRecCalId) NSString *campusRecCalId;

@property (nonatomic, strong, setter=setAuthCals:, getter=getAuthCals) NSMutableDictionary *authorizedCalendars;


+(Authentication *) getSharedInstance;

-(GoogleOAuth *) getAuthenticator;

-(void) setAuthenticator:(GoogleOAuth *)authenticator;

-(void) setDelegate:(UIViewController<GoogleOAuthDelegate> *)delegate;

-(void) resetPriviledges;
@end
