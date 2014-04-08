//
//  EventDetailTableViewController.m
//  campuslife
//
//  Created by Super Student on 3/4/14.
//  Copyright (c) 2014 LCSC. All rights reserved.
//

#import "EventDetailTableViewController.h"
#import "MonthlyEvents.h"
#import "Authentication.h"

@interface EventDetailTableViewController ()
{
    MonthlyEvents *events;
    
    Authentication *auth;
}

@end



@implementation EventDetailTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    events = [MonthlyEvents getSharedInstance];
    
    [self setDay:[events getSelectedDay]];
    
    auth = [Authentication getSharedInstance];
    
    if ([auth getUserCanManageEvents]) {
        //
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = 0;
    
    if (section == 0)
    {
        rows = 3;
    }
    else if (section == 1)
    {
        rows = 4;
    }
    else
    {
        rows = 2;
    }
    
    return rows;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"grayCell" forIndexPath:indexPath];
            cell.separatorInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
            cell.backgroundColor = [UIColor colorWithRed:240.0/256.0 green:240.0/256.0 blue:240.0/256.0 alpha:1.0];
        }
        
        if (indexPath.row == 1)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"standardInformationDisplay" forIndexPath:indexPath];
            UILabel *title = (UILabel *)[cell viewWithTag:1];
            title.text = @"Summary";
            UILabel *summary = (UILabel *)[cell viewWithTag:2];
            summary.text = [_eventDict objectForKey:@"summary"];
        }
        
        if (indexPath.row == 2)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"standardInformationDisplay" forIndexPath:indexPath];
            UILabel *title = (UILabel *)[cell viewWithTag:1];
            title.text = @"Location";
            UILabel *summary = (UILabel *)[cell viewWithTag:2];
            summary.text = [_eventDict objectForKey:@"location"];
            cell.separatorInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"grayCell" forIndexPath:indexPath];
            cell.separatorInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
            cell.backgroundColor = [UIColor colorWithRed:240.0/256.0 green:240.0/256.0 blue:240.0/256.0 alpha:1.0];
        }
        
        if (indexPath.row == 1)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"allDaySwitch" forIndexPath:indexPath];
            UILabel *title = (UILabel *)[cell viewWithTag:3];
            title.text = @"All Day Event";
            
            if ([[_eventDict objectForKey:@"start"] objectForKey:@"date"])
            {
                UISwitch *allDay = (UISwitch *)[cell viewWithTag:4];
                [allDay setOn:YES];
            }
        }
        
        if (indexPath.row == 2)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"dayAndTimePicker" forIndexPath:indexPath];
            UILabel *title = (UILabel *)[cell viewWithTag:5];
            title.text = @"Start";
            
            
            
            UILabel *timeLbl = (UILabel *)[cell viewWithTag:6];
            if ([[_eventDict objectForKey:@"start"] objectForKey:@"date"])
            {
                NSString *eventStart = [[_eventDict objectForKey:@"start"] objectForKey:@"date"];
                NSRange zeroToTenStart = NSMakeRange(0, 10);
                timeLbl.text = [eventStart substringWithRange:zeroToTenStart];
            }
            else
            {
                NSString *eventStart1 = [[_eventDict objectForKey:@"start"] objectForKey:@"dateTime"];
                NSRange zeroToTen = NSMakeRange(0, 10);
                NSString *datePart = [eventStart1 substringWithRange:zeroToTen];
                
                NSString *eventStart2 = [[_eventDict objectForKey:@"start"] objectForKey:@"dateTime"];
                NSRange elevenToSixteen = NSMakeRange(11, 5);
                NSString *timePart = [eventStart2 substringWithRange:elevenToSixteen];
                timePart = [self twentyFourToTwelve:timePart];
                
                datePart = [datePart stringByAppendingString:@"  "];
                datePart = [datePart stringByAppendingString:timePart];
                
                timeLbl.text = datePart;
            }
        }
        
        if (indexPath.row == 3)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"dayAndTimePicker" forIndexPath:indexPath];
            UILabel *title = (UILabel *)[cell viewWithTag:5];
            title.text = @"End";
            
            UILabel *timeLbl = (UILabel *)[cell viewWithTag:6];
            if ([[_eventDict objectForKey:@"end"] objectForKey:@"date"])
            {
                NSString *eventEnd = [[_eventDict objectForKey:@"end"] objectForKey:@"date"];
                NSRange zeroToTenEnd = NSMakeRange(0, 10);
                timeLbl.text = [eventEnd substringWithRange:zeroToTenEnd];
            }
            else
            {
                NSString *eventEnd1 = [[_eventDict objectForKey:@"end"] objectForKey:@"dateTime"];
                NSRange zeroToTen = NSMakeRange(0, 10);
                NSString *datePart = [eventEnd1 substringWithRange:zeroToTen];
                
                NSString *eventEnd2 = [[_eventDict objectForKey:@"end"] objectForKey:@"dateTime"];
                NSRange elevenToSixteen = NSMakeRange(11, 5);
                NSString *timePart = [eventEnd2 substringWithRange:elevenToSixteen];
                timePart = [self twentyFourToTwelve:timePart];
                
                datePart = [datePart stringByAppendingString:@"  "];
                datePart = [datePart stringByAppendingString:timePart];
                
                timeLbl.text = datePart;
            }
            
            cell.separatorInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        }
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"grayCell" forIndexPath:indexPath];
            cell.separatorInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
            cell.backgroundColor = [UIColor colorWithRed:240.0/256.0 green:240.0/256.0 blue:240.0/256.0 alpha:1.0];
        }
        
        if (indexPath.row == 1)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"repeatDisplay" forIndexPath:indexPath];
            cell.separatorInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
            UILabel *title = (UILabel *)[cell viewWithTag:7];
            title.text = @"Repeat";
            UILabel *repState = (UILabel *)[cell viewWithTag:8];
            
            if ([_eventDict objectForKey:@"recurrence"])
            {
                NSLog(@"Recurrence: %@", [_eventDict objectForKey:@"recurrence"]);
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
                
                NSString *repeatUntilLbl;
                NSString *repeatUntilOtherStuff;
                
                //Is the ocurrence daily?
                if ([[_eventDict[@"recurrence"][0] substringWithRange:NSMakeRange(11, 1)] isEqualToString:@"D"])
                {
                    repeatUntilLbl = @"Daily until ";
                    repeatUntilOtherStuff = [_eventDict[@"recurrence"][0] substringWithRange:NSMakeRange(23, 15)];
                    NSLog(@"Daily = %@", repeatUntilOtherStuff);
                    repeatUntilOtherStuff = [self formatTimeString:repeatUntilOtherStuff];
                    repeatUntilLbl = [repeatUntilLbl stringByAppendingString:repeatUntilOtherStuff];
                    repState.text = repeatUntilLbl;
                }
                //Is the ocurrence Weekly?
                else if ([[_eventDict[@"recurrence"][0] substringWithRange:NSMakeRange(11, 1)] isEqualToString:@"W"]) {
                    if ([[_eventDict[@"recurrence"][0] substringWithRange:NSMakeRange(18, 10)] isEqualToString:@"INTERVAL=2"]) {
                        repeatUntilLbl = @"Bi-Weekly until ";
                        repeatUntilOtherStuff = [_eventDict[@"recurrence"][0] substringWithRange:NSMakeRange(35, 15)];
                        NSLog(@"Bi-weekly = %@", repeatUntilOtherStuff);
                        repeatUntilOtherStuff = [self formatTimeString:repeatUntilOtherStuff];
                        repeatUntilLbl = [repeatUntilLbl stringByAppendingString:repeatUntilOtherStuff];
                        repState.text = repeatUntilLbl;
                    }
                    else {
                        repeatUntilLbl = @"Weekly until ";
                        repeatUntilOtherStuff = [_eventDict[@"recurrence"][0] substringWithRange:NSMakeRange(24, 15)];
                        NSLog(@"Weekly = %@", repeatUntilOtherStuff);
                        repeatUntilOtherStuff = [self formatTimeString:repeatUntilOtherStuff];
                        repeatUntilLbl = [repeatUntilLbl stringByAppendingString:repeatUntilOtherStuff];
                        repState.text = repeatUntilLbl;
                    }
                }
                //Is the ocurrence Monthly?
                else if ([[_eventDict[@"recurrence"][0] substringWithRange:NSMakeRange(11, 1)] isEqualToString:@"M"]) {
                    repeatUntilLbl = @"Monthly until ";
                    repeatUntilOtherStuff = [_eventDict[@"recurrence"][0] substringWithRange:NSMakeRange(25, 15)];
                    NSLog(@"Monthly = %@", repeatUntilOtherStuff);
                    repeatUntilOtherStuff = [self formatTimeString:repeatUntilOtherStuff];
                    repeatUntilLbl = [repeatUntilLbl stringByAppendingString:repeatUntilOtherStuff];
                    repState.text = repeatUntilLbl;
                }
                //Is the ocurrence Monthly?
                else if ([[_eventDict[@"recurrence"][0] substringWithRange:NSMakeRange(11, 1)] isEqualToString:@"Y"]) {
                    repeatUntilLbl = @"Yearly until ";
                    repeatUntilOtherStuff = [_eventDict[@"recurrence"][0] substringWithRange:NSMakeRange(24, 15)];
                    NSLog(@"Yearly = %@", repeatUntilOtherStuff);
                    repeatUntilOtherStuff = [self formatTimeString:repeatUntilOtherStuff];
                    repeatUntilLbl = [repeatUntilLbl stringByAppendingString:repeatUntilOtherStuff];
                    repState.text = repeatUntilLbl;
                }
                
            }
            else
            {
                repState.text = @"No";
            }
                
            cell.separatorInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        }
    }
    else
    {
        if (indexPath.row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"grayCell" forIndexPath:indexPath];
            cell.separatorInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
            cell.backgroundColor = [UIColor colorWithRed:240.0/256.0 green:240.0/256.0 blue:240.0/256.0 alpha:1.0];
        }
        
        if (indexPath.row == 1)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"description" forIndexPath:indexPath];
            UILabel *title = (UILabel *)[cell viewWithTag:9];
            title.text = @"Description";
            UITextView *descView = (UITextView *)[cell viewWithTag:10];
            descView.text = [_eventDict objectForKey:@"description"];
            cell.separatorInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        }
    }
    
    return cell;
}



- (NSString *)twentyFourToTwelve:(NSString *)time
{
    NSRange stringHourRange = NSMakeRange(0, 2);
    NSString *stringHour = [time substringWithRange:stringHourRange];
    int hourInt = [stringHour intValue];
    
    NSRange stringMinRange = NSMakeRange(2, 3);
    NSString *restOfString = [time substringWithRange:stringMinRange];
    
    if (hourInt == 0)
    {
        time = [NSString stringWithFormat:@"%d%@ AM", 12, restOfString];
    }
    
    else if(hourInt < 12)
    {
        time = [NSString stringWithFormat:@"%d%@ AM", hourInt, restOfString];
    }
    
    else if (hourInt == 12)
    {
        time = [NSString stringWithFormat:@"%d%@ PM", 12, restOfString];
    }
    
    else if (hourInt >= 13)
    {
        time = [NSString stringWithFormat:@"%d%@ PM", hourInt - 12, restOfString];
    }
    
    return time;
}



//Input: 15 character string
//  Output: 15 character string augmented with hyphens and spaces (also, removes the T)
- (NSString *)formatTimeString:(NSString *)time
{
    NSString *timeStr = [time substringWithRange:NSMakeRange(0, 4)];
    timeStr = [timeStr stringByAppendingString:@"-"];
    timeStr = [timeStr stringByAppendingString:[time substringWithRange:NSMakeRange(4, 2)]];
    timeStr = [timeStr stringByAppendingString:@"-"];
    timeStr = [timeStr stringByAppendingString:[time substringWithRange:NSMakeRange(6, 2)]];
    timeStr = [timeStr stringByAppendingString:@" "];
    timeStr = [timeStr stringByAppendingString:[time substringWithRange:NSMakeRange(9, 2)]];
    timeStr = [timeStr stringByAppendingString:@":"];
    timeStr = [timeStr stringByAppendingString:[time substringWithRange:NSMakeRange(11, 2)]];
    
    NSLog(@"timeStr = %@", timeStr);
    
    return timeStr;
}



@end
