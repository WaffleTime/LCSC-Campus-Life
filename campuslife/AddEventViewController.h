//
//  AddEventViewController.h
//  campuslife
//
//  Created by Super Student on 12/2/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleOAuth.h"

@interface AddEventViewController : UIViewController<GoogleOAuthDelegate>

-(IBAction) addEvent;

@end
