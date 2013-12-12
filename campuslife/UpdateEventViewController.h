//
//  UpdateEventViewController.h
//  campuslife
//
//  Created by Super Student on 12/8/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdateEventViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>

//This will be given to us from the previous class (EventDetailViewController)
@property (nonatomic, strong, setter=setEventInfo:) NSDictionary *eventInfo;


@property (weak, nonatomic) IBOutlet UITextField *summary;
@property (weak, nonatomic) IBOutlet UITextField *where;
@property (weak, nonatomic) IBOutlet UITextView *description;

@property (weak, nonatomic) IBOutlet UISwitch *allDayEventSwitch;

@property (weak, nonatomic) IBOutlet UIDatePicker *startTimePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endTimePicker;

@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;

-(IBAction) addEvent;
- (IBAction)allDayEventToggle:(id)sender;

@end
