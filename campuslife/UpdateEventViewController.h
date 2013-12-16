//
//  UpdateEventViewController.h
//  campuslife
//
//  Created by Super Student on 12/8/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleOAuth.h"

@interface UpdateEventViewController : UIViewController<GoogleOAuthDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

//This will be given to us from the previous class (EventDetailViewController)
@property (nonatomic, strong, setter=setEventInfo:) NSDictionary *eventInfo;


@property (weak, nonatomic) IBOutlet UITextField *summary;
@property (weak, nonatomic) IBOutlet UITextField *where;
@property (weak, nonatomic) IBOutlet UITextView *description;

@property (weak, nonatomic) IBOutlet UISwitch *allDayEventSwitch;

@property (weak, nonatomic) IBOutlet UIDatePicker *startTimePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endTimePicker;

@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;

@property (weak, nonatomic) IBOutlet UILabel *repeatLabel;
@property (weak, nonatomic) IBOutlet UISlider *repeatSlider;
@property (weak, nonatomic) IBOutlet UILabel *numberOfRepeatLabel;
@property (weak, nonatomic) IBOutlet UISlider *numberOfRepeatSlider;

-(IBAction) addEvent;
- (IBAction)allDayEventToggle:(id)sender;

- (IBAction)repeatSliderChanged:(UISlider *)sender;
- (IBAction)numberOfRepeatSliderChanged:(UISlider *)sender;
@end
