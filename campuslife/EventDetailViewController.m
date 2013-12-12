//
//  EventDetailViewController.m
//  LCSC Campus Life
//
//  Created by Super Student on 11/12/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import "EventDetailViewController.h"
#import "Authentication.h"
#import "UpdateEventViewController.h"

@interface EventDetailViewController ()

@end

@implementation EventDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _summaryLabel.text = [_eventDict objectForKey:@"summary"];
    _locLabel.text = [_eventDict objectForKey:@"location"];
    _categoryLabel.text = [_eventDict objectForKey:@"category"];
    _descriptionTextView.text = [_eventDict objectForKey:@"description"];
    
    if (![[Authentication getSharedInstance] getUserCanManageEvents]) {
        _addEventButton.titleLabel.text = @" ";
        _addEventButton.enabled = NO;
    }
    
    if ([_eventDict[@"start"] objectForKey:@"dateTime"] != nil) {
        NSRange yearRange = NSMakeRange(0, 4);
        NSRange monthRange = NSMakeRange(5, 2);
        NSRange dayRange = NSMakeRange(8, 2);
        
        _dateLabel.text = [NSString stringWithFormat:@"%@/%@/%@", [_eventDict[@"start"][@"dateTime"] substringWithRange:monthRange], [_eventDict[@"start"][@"dateTime"] substringWithRange:dayRange], [_eventDict[@"start"][@"dateTime"] substringWithRange:yearRange]];
        
        NSRange hrRange = NSMakeRange(11, 2);
        NSRange minRange = NSMakeRange(14, 2);
        NSString *fromHour = [_eventDict[@"start"][@"dateTime"] substringWithRange:hrRange];
        NSString *fromMin = [_eventDict[@"start"][@"dateTime"] substringWithRange:minRange];
        NSString *fromPeriod = @"AM";
        
        //Periods are set to AM by default.
        if ([fromHour intValue] >= 12) {
            fromPeriod = @"PM";
            //Convert back from military time if necessary.
            if ([fromHour intValue] > 12) {
                fromHour = [NSString stringWithFormat:@"%d", ([fromHour intValue]-12)];
            }
        }
        else if ([fromHour intValue] == 0) {
            fromHour = @"12";
        }
        
        _fromTimeLabel.text = [NSString stringWithFormat:@"%@:%@%@", fromHour, fromMin, fromPeriod];
        
        NSString *toHour = [_eventDict[@"end"][@"dateTime"] substringWithRange:hrRange];
        NSString *toMinute = [_eventDict[@"end"][@"dateTime"] substringWithRange:minRange];
        NSString *toPeriod = @"AM";
        
        //Periods are set to AM by default.
        if ([toHour intValue] >= 12) {
            toPeriod = @"PM";
            //Convert back from military time if necessary.
            if ([toHour intValue] > 12) {
                toHour = [NSString stringWithFormat:@"%d", ([toHour intValue]-12)];
            }
        }
        else if ([toHour intValue] == 0) {
            toHour = @"12";
        }
        
        _toTimeLabel.text = [NSString stringWithFormat:@"%@:%@%@", toHour, toMinute, toPeriod];
    }
    else {
        NSRange yearRange = NSMakeRange(0, 4);
        NSRange monthRange = NSMakeRange(5, 2);
        NSRange dayRange = NSMakeRange(8, 2);
        
        _dateLabel.text = [NSString stringWithFormat:@"%@/%@/%@", [_eventDict[@"start"][@"date"] substringWithRange:monthRange], [_eventDict[@"start"][@"date"] substringWithRange:dayRange], [_eventDict[@"start"][@"date"] substringWithRange:yearRange]];
        
        _fromTimeLabel.hidden = YES;
        _toLabel.hidden = YES;
        _toTimeLabel.hidden = YES;
        
        _allDayLabel.text = @"All Day Event";
    }
    
    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer: tapRec];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tap:(UITapGestureRecognizer *)tapRec{
    [[self view] endEditing: YES];
}


-(void) prepareForSegue:(UIStoryboardPopoverSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EventDetailToUpdateEvent"]) {
        UpdateEventViewController *destViewController = (UpdateEventViewController *)[segue destinationViewController];
        
        [destViewController setEventInfo:_eventDict];
    }
}


@end
