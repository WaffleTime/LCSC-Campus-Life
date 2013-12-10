//
//  Day_Event_ViewController.m
//  LCSC Campus Life
//
//  Created by Super Student on 11/7/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import "Day_Event_ViewController.h"
#import "Authentication.h"
#import "MonthlyEvents.h"
#import "Preferences.h"



@interface Day_Event_ViewController ()
{
    
    MonthlyEvents *events;
    
    NSArray *sortedArray;
    
}

@end





@implementation Day_Event_ViewController





/*
 *  Usefull for checking whether or not the view Loaded.
 *
 *  Only loads once.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    
    if ([[Authentication getSharedInstance] getUserCanManageEvents])
    {
        self.navigationItem.rightBarButtonItem.title = @"Add Event";
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else {
        NSLog(@"User can't manage events.");
    }
    
    events = [MonthlyEvents getSharedInstance];
    
    [self setDay:[events getSelectedDay]];
    
    sortedArray = [self eventSorter:[events getEventsForDay:_day]];
    
    [self.tableView reloadData];
}





/*
 *  Request new information from day at index.
 */
-(void)viewDidAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
}





/*
 *  Possibly useless?
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}





- (NSArray *)eventSorter:(NSArray *)unsorted
{
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    
    [newArray addObjectsFromArray:unsorted];
    
    if ([[events getEventsForDay:_day] count]>1)
    {
        NSLog(@"entered if-loop");
        
        NSLog(@"Checking your preferences");
        
        Preferences *preferences = [Preferences getSharedInstance];
        
        int currentPos = 0;
        
        while (currentPos < [newArray count])
        {
            NSLog(@"Entered while-loop\n");
            
            if ([[newArray[currentPos] objectForKey:@"category"] isEqualToString:@"Entertainment"] && [preferences getPreference:1] == FALSE)
            {
                NSLog(@"Popping Entertainment event");
                
                [newArray removeObjectAtIndex:currentPos];
            }
                
            else if ([[newArray[currentPos] objectForKey:@"category"] isEqualToString:@"Academics"] && [preferences getPreference:2] == FALSE)
            {
                NSLog(@"Popping Academics event");
                
                [newArray removeObjectAtIndex:currentPos];
            }
            
            else if ([[newArray[currentPos] objectForKey:@"category"] isEqualToString:@"Activities"] && [preferences getPreference:3] == FALSE)
            {
                NSLog(@"Popping Activities event");
                
                [newArray removeObjectAtIndex:currentPos];
            }
            
            else if ([[newArray[currentPos] objectForKey:@"category"] isEqualToString:@"Residence"] && [preferences getPreference:4] == FALSE)
            {
                NSLog(@"Popping Residence event");
                
                [newArray removeObjectAtIndex:currentPos];
            }
            
            else if ([[newArray[currentPos] objectForKey:@"category"] isEqualToString:@"Athletics"] && [preferences getPreference:5] == FALSE)
            {
                NSLog(@"Popping Athletics event");
                
                [newArray removeObjectAtIndex:currentPos];
            }
            else
            {
                currentPos++;
                
                NSLog(@"currentPos updated to: %d.", currentPos);
            }
        }
        
        NSLog(@"Printing newArray size: %d\n", [newArray count]);
        
        if ([newArray count] > 1)
        {
            NSLog(@"sorting array");
            
            int currentPos = 0;
            
            BOOL finished = FALSE;
            
            while (!finished)
            {
                if (currentPos < [newArray count] - 1)
                {
                    NSRange startHr1 = NSMakeRange(11, 2);
                    NSRange startMn1 = NSMakeRange(14, 2);
                    NSString *startHrStr1 = [[[newArray[currentPos] objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:startHr1];
                    NSString *startMnStr1 = [[[newArray[currentPos] objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:startMn1];
                    NSString *startTime1 =[startHrStr1 stringByAppendingString:startMnStr1];
                    
                    for (int i = *(&currentPos) + 1; i < [newArray count]; i++)
                    {
                        NSLog(@"\n\n Entered for-loop for sorting, i = %d \n\n", i);
                        
                        NSRange startHr2 = NSMakeRange(11, 2);
                        NSRange startMn2 = NSMakeRange(14, 2);
                        NSString *startHrStr2 = [[[newArray[i] objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:startHr2];
                        NSString *startMnStr2 = [[[newArray[i] objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:startMn2];
                        NSString *startTime2 =[startHrStr2 stringByAppendingString:startMnStr2];
                    
                        NSLog(@"\n\n comparing start times\n\n StartTime1 = %@ \n StartTime2 = %@ \n StartTime1 > StartTime2 = %d \n\n", startTime1, startTime2, startTime1 > startTime2);
                    
                        if (startTime1 > startTime2)
                        {
                            NSDictionary *temp = newArray[currentPos];
                            
                            newArray[currentPos] = newArray[i];
                            
                            newArray[i] = temp;
                        }
                        else
                        {
                            NSRange endHr1 = NSMakeRange(11, 2);
                            NSRange endMn1 = NSMakeRange(14, 2);
                            NSString *endHrStr1 = [[[newArray[currentPos] objectForKey:@"end"] objectForKey:@"dateTime"] substringWithRange:endHr1];
                            NSString *endMnStr1 = [[[newArray[currentPos] objectForKey:@"end"] objectForKey:@"dateTime"] substringWithRange:endMn1];
                            NSString *endTime1 =[endHrStr1 stringByAppendingString:endMnStr1];
                            
                            NSRange endHr2 = NSMakeRange(11, 2);
                            NSRange endMn2 = NSMakeRange(14, 2);
                            NSString *endHrStr2 = [[[newArray[currentPos + 1] objectForKey:@"end"] objectForKey:@"dateTime"] substringWithRange:endHr2];
                            NSString *endMnStr2 = [[[newArray[currentPos + 1] objectForKey:@"end"] objectForKey:@"dateTime"] substringWithRange:endMn2];
                            NSString *endTime2 =[endHrStr2 stringByAppendingString:endMnStr2];
                            
                            if (endTime1 > endTime2)
                            {
                                NSDictionary *temp = newArray[currentPos];
                                
                                newArray[currentPos] = newArray[i];
                                
                                newArray[i] = temp;
                            }
                        }
                        
                        if (i == [newArray count] - 1)
                        {
                            currentPos = currentPos + 1;
                            
                            NSLog(@"Updated currentPos to %d", currentPos);
                        }
                    }
                }
                else
                {
                    finished = TRUE;
                }
            }
        }
        
        /*if ([newArray count] > 1)
        {
            NSLog(@"Entered the sorting algorithm\n");
            
            for (int i = 0; i < [newArray count]; i++)
            {
                NSLog(@"entered into 1st for-loop");
                
                for (int j = 0; j < [newArray count] - 1; j++)
                {
                    NSLog(@"entered into 2nd for-loop");
                    
                //    NSDictionary *eventTime = [[events getEventsForDay:j] objectAtIndex:indexPath.row];
                    //NSString *eventStart = [[eventTime objectForKey:@"start"] objectForKey:@"dateTime"];
                    
                    NSRange startHr1 = NSMakeRange(11, 2);
                    NSRange startMn1 = NSMakeRange(14, 2);
                    NSString *startHrStr1 = [[[newArray[j] objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:startHr1];
                    NSString *startMnStr1 = [[[newArray[j] objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:startMn1];
                    NSString *startTime1 =[startHrStr1 stringByAppendingString:startMnStr1];
                    int st1 = [startTime1 intValue];
                    
                    NSRange startHr2 = NSMakeRange(11, 2);
                    NSRange startMn2 = NSMakeRange(14, 2);
                    NSString *startHrStr2 = [[[newArray[j+1] objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:startHr2];
                    NSString *startMnStr2 = [[[newArray[j+1] objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:startMn2];
                    NSString *startTime2 =[startHrStr2 stringByAppendingString:startMnStr2];
                    int st2 = [startTime2 intValue];
                    
                    
                    
                    if (st1 > st2)
                    {
                        NSDictionary *temp = newArray[j];
                        
                        newArray[j] = newArray[j+1];
                        
                        newArray[j+1] = temp;
                    }
                    else
                    {
                        NSRange endHr1 = NSMakeRange(11, 2);
                        NSRange endMn1 = NSMakeRange(14, 2);
                        NSString *endHrStr1 = [[[newArray[j] objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:endHr1];
                        NSString *endMnStr1 = [[[newArray[j] objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:endMn1];
                        NSString *endTime1 =[endHrStr1 stringByAppendingString:endMnStr1];
                        int st3 = [endTime1 intValue];
                        
                        NSRange endHr2 = NSMakeRange(11, 2);
                        NSRange endMn2 = NSMakeRange(14, 2);
                        NSString *endHrStr2 = [[[newArray[j+1] objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:endHr2];
                        NSString *endMnStr2 = [[[newArray[j+1] objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:endMn2];
                        NSString *endTime2 =[endHrStr2 stringByAppendingString:endMnStr2];
                        int st4 = [endTime2 intValue];
                        
                        if (st3 > st4)
                        {
                            NSDictionary *temp = newArray[j];
                            
                            newArray[j] = newArray[j+1];
                            
                            newArray[j+1] = temp;
                        }
                    }
                }
            }
        }*/
    }
    else
    {
        NSLog(@"didn't enter if-loop");
    }
    
    return (NSArray *)newArray;
}





// Useless comment!
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [sortedArray count];
}





- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EventCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    NSDictionary *eventTime = [sortedArray objectAtIndex:indexPath.row];
    
    if ([[eventTime objectForKey:@"start"] objectForKey:@"dateTime"] == nil)
    {
        UILabel *time = (UILabel *)[cell viewWithTag:20];
        time.text = @"All Day Event";
    }
    else
    {
        NSString *eventStart = [[eventTime objectForKey:@"start"] objectForKey:@"dateTime"];
        NSRange elevenToSixteenStart = NSMakeRange(11, 5);
        NSString *startTime = [eventStart substringWithRange:elevenToSixteenStart];
        startTime = [self twentyFourToTwelve:startTime];
        
        NSString *eventEnd = [[eventTime objectForKey:@"end"] objectForKey:@"dateTime"];
        NSRange elevenToSixteenEnd = NSMakeRange(11, 5);
        NSString *endTime = [eventEnd substringWithRange:elevenToSixteenEnd];
        endTime = [self twentyFourToTwelve:endTime];
        
        UILabel *time = (UILabel *)[cell viewWithTag:20];
        time.text = [NSString stringWithFormat:@"%@\n to \n%@", startTime, endTime];
    }
    
    if ([[eventTime objectForKey:@"category"] isEqualToString:@"Entertainment"])
    {
        UIView *color = (UILabel *)[cell viewWithTag:21];
        color.backgroundColor = [UIColor redColor];
    }
    else if ([[eventTime objectForKey:@"category"] isEqualToString:@"Academics"])
    {
        UIView *color = (UILabel *)[cell viewWithTag:21];
        color.backgroundColor = [UIColor colorWithRed:50.0/255.0f green:50.0/255.0f blue:255.0/255.0f alpha:1.0];
    }
    else if ([[eventTime objectForKey:@"category"] isEqualToString:@"Activities"])
    {
        UIView *color = (UILabel *)[cell viewWithTag:21];
        color.backgroundColor = [UIColor yellowColor];
    }
    else if ([[eventTime objectForKey:@"category"] isEqualToString:@"Residence"])
    {
        UIView *color = (UILabel *)[cell viewWithTag:21];
        color.backgroundColor = [UIColor orangeColor];
    }
    else if ([[eventTime objectForKey:@"category"] isEqualToString:@"Athletics"])
    {
        UIView *color = (UILabel *)[cell viewWithTag:21];
        color.backgroundColor = [UIColor greenColor];
    }
    
    UILabel *summary = (UILabel *)[cell viewWithTag:22];
    summary.text = [eventTime objectForKey:@"summary"];
    
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
    
    else if(hourInt < 10)
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





- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Uncertain as to what goes in here.
}





@end
