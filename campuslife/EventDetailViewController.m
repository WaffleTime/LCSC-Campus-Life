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
        
        if (![_eventDict[@"start"][@"dateTime"] isEqualToString:_eventDict[@"end"][@"dateTime"]]) {
            _dateLabel.text = [_dateLabel.text stringByAppendingString:[NSString stringWithFormat:@" to %@/%@/%@", [_eventDict[@"end"][@"dateTime"] substringWithRange:monthRange], [_eventDict[@"end"][@"dateTime"] substringWithRange:dayRange], [_eventDict[@"end"][@"dateTime"] substringWithRange:yearRange]]];
        }
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
        
        if (![_eventDict[@"start"][@"dateTime"] isEqualToString:_eventDict[@"end"][@"dateTime"]]) {
            _dateLabel.text = [_dateLabel.text stringByAppendingString:[NSString stringWithFormat:@" to %@/%@/%@", [_eventDict[@"end"][@"dateTime"] substringWithRange:monthRange], [_eventDict[@"end"][@"dateTime"] substringWithRange:dayRange], [_eventDict[@"end"][@"dateTime"] substringWithRange:yearRange]]];
        }
    }
    
    if ([_eventDict objectForKey:@"recurrence"] != nil
        && [self getIndexOfSubstringInString:@"UNTIL" :_eventDict[@"recurrence"][0]] != -1) {
        NSString *repeat = @"Repeat";
        
        //Is the ocurrence daily?
        if ([[_eventDict[@"recurrence"][0] substringWithRange:NSMakeRange(11, 1)] isEqualToString:@"D"]) {
            repeat = [repeat stringByAppendingString:@" Daily"];
        }
        //Is the ocurrence monthly?
        else if ([[_eventDict[@"recurrence"][0] substringWithRange:NSMakeRange(11, 1)] isEqualToString:@"W"]) {
            repeat = [repeat stringByAppendingString:@" Weekly"];
        }
        //Is the ocurrence yearly?
        else if ([[_eventDict[@"recurrence"][0] substringWithRange:NSMakeRange(11, 1)] isEqualToString:@"M"]) {
            repeat = [repeat stringByAppendingString:@" Monthly"];
        }
        
        NSString *untilYear = [_eventDict[@"recurrence"][0] substringWithRange:NSMakeRange([self getIndexOfSubstringInString:@"UNTIL=" :_eventDict[@"recurrence"][0]] + 6, 4)];

        NSString *untilMonth = [_eventDict[@"recurrence"][0] substringWithRange:NSMakeRange([self getIndexOfSubstringInString:@"UNTIL=" :_eventDict[@"recurrence"][0]] + 10, 2)];
        
        NSString *untilDay = [_eventDict[@"recurrence"][0] substringWithRange:NSMakeRange([self getIndexOfSubstringInString:@"UNTIL=" :_eventDict[@"recurrence"][0]] + 12, 2)];
        
        _repeatLabel.text = [repeat stringByAppendingString:[NSString stringWithFormat:@" Until %@/%@/%@", untilMonth, untilDay, untilYear]];
    }
    else {
        _repeatLabel.hidden = YES;
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


//This is strictly for locating things like Category: and ShortDesc: within
//  the summary of the.
- (int)getIndexOfSubstringInString:(NSString *)substring :(NSString *)string {
    BOOL substringFound = NO;
    
    int substringStartIndex = -1;
    
    //Iterate through the string to find the first character in the substring.
    for (int i=0; i<[string length]; i++) {
        //Check to see if the substring character has been found.
        if ([string characterAtIndex:i] == [substring characterAtIndex:0]) {
            //If the substring length is greater than the remaining characters in the string,
            //  there is no possible way that the substring exists there (and an exception will be thrown.)
            //Only search for the substring if the remaining chars is >= to the substring length.
            if ([string length] - i >= [substring length]) {
                //Check to see if the following characters in the string are also in the substring.
                //  This can start at 1 because the 0th index of the substring has already been determined
                //  to be in the string.
                for (int j=1; j<[substring length]; j++) {
                    //Check if one the following characters in the substring aren't within the string.
                    if ([string characterAtIndex:i+j] != [substring characterAtIndex:j]) {
                        //If this is true, then i isn't the index of the first character in the substring
                        //  within the string.
                        break;
                    }
                    else {
                        //If this was the very last character in the substring and it's in the string, the
                        //  substring has been found. (The loop stops when it finds a char in the substring that's
                        //  not in the string.)
                        if (j == [substring length]-1) {
                            substringFound = YES;
                            substringStartIndex = i;
                        }
                    }
                }
            }
            //If we've found the substring, we can stop the loop.
            if (substringFound) {
                break;
            }
        }
    }
    
    return substringStartIndex;
}


-(void) prepareForSegue:(UIStoryboardPopoverSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EventDetailToUpdateEvent"]) {
        UpdateEventViewController *destViewController = (UpdateEventViewController *)[segue destinationViewController];
        
        [destViewController setEventInfo:_eventDict];
    }
}


@end
