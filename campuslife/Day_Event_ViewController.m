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
#import "EventDetailViewController.h"



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
        NSLog(@"More than one event. Entered if-loop");
        
        NSLog(@"Checking your preferences");
        
        Preferences *preferences = [Preferences getSharedInstance];
        
        int currentPos = 0;
        
        while (currentPos < [newArray count])
        {
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
            }
        }
        
        
        
        NSLog(@"Printing newArray size: %lu\n", (unsigned long)[newArray count]);
        
        
        
        if ([newArray count] > 1)
        {
            NSLog(@"sorting array");
            
            int currentPos = 0;
            
            BOOL finished = FALSE;
            
            while(!finished)
            {
                NSLog(@"Entered while-loop. currentPos = %d\n\n", currentPos);
                
                int lowestItem = currentPos;
                
                for (int i = currentPos + 1; i < [newArray count]; i++)
                {
                    NSLog(@"Entered for-loop.\n\n currentPos = %d\n lowestItem = %d\n i = %d\n\n", currentPos, lowestItem, i);
                    
                    NSRange startHr1 = NSMakeRange(11, 2);
                    NSRange startMn1 = NSMakeRange(14, 2);
                    NSString *startHrStr1 = [[[newArray[lowestItem] objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:startHr1];
                    NSString *startMnStr1 = [[[newArray[lowestItem] objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:startMn1];
                    NSString *startTime1 =[startHrStr1 stringByAppendingString:startMnStr1];
                    int start1 = [startTime1 intValue];
                    NSLog(@"start1 = %d\n\n", start1);
                    
                    NSRange startHr2 = NSMakeRange(11, 2);
                    NSRange startMn2 = NSMakeRange(14, 2);
                    NSString *startHrStr2 = [[[newArray[i] objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:startHr2];
                    NSString *startMnStr2 = [[[newArray[i] objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:startMn2];
                    NSString *startTime2 =[startHrStr2 stringByAppendingString:startMnStr2];
                    int start2 = [startTime2 intValue];
                    NSLog(@"start2 = %d\n\n", start2);
                    
                    if (start1 > start2)
                    {
                        NSLog(@"\n\nApparently %d > %d.\nSetting lowestItem to %d\n\n", start1, start2, i);
                        
                        lowestItem = i;
                    }
                    else if (start1 == start2)
                    {
                        NSLog(@"start times fine: checking end times\n\n");
                        
                        NSRange endHr1 = NSMakeRange(11, 2);
                        NSRange endMn1 = NSMakeRange(14, 2);
                        NSString *endHrStr1 = [[[newArray[lowestItem] objectForKey:@"end"] objectForKey:@"dateTime"] substringWithRange:endHr1];
                        NSString *endMnStr1 = [[[newArray[lowestItem] objectForKey:@"end"] objectForKey:@"dateTime"] substringWithRange:endMn1];
                        NSString *endTime1 =[endHrStr1 stringByAppendingString:endMnStr1];
                        int end1 = [endTime1 intValue];
                        NSLog(@"end1 = %d\n\n", end1);
                        
                        NSRange endHr2 = NSMakeRange(11, 2);
                        NSRange endMn2 = NSMakeRange(14, 2);
                        NSString *endHrStr2 = [[[newArray[i] objectForKey:@"end"] objectForKey:@"dateTime"] substringWithRange:endHr2];
                        NSString *endMnStr2 = [[[newArray[i] objectForKey:@"end"] objectForKey:@"dateTime"] substringWithRange:endMn2];
                        NSString *endTime2 =[endHrStr2 stringByAppendingString:endMnStr2];
                        int end2 = [endTime2 intValue];
                        NSLog(@"end2 = %d\n\n", end2);
                        
                        if (end1 > end2)
                        {
                            NSLog(@"Apparently end time %d > %d.\nSetting lowestItem to %d\n\n", end1, end2, i);
                            
                            lowestItem = i;
                        }
                    }
                    
                    NSLog(@"End for-loop.\n\n currentPos = %d\n lowestItem = %d\n i = %d\n\n", currentPos, lowestItem, i);
                }
                
                if (lowestItem != currentPos)
                {
                    NSLog(@"Had to swap currentPos[%d] and lowestPos[%d]\n\n", currentPos, lowestItem);
                    
                    NSDictionary *temp = newArray[currentPos];
                    
                    newArray[currentPos] = newArray[lowestItem];
                    
                    newArray[lowestItem] = temp;
                    
                    NSLog(@"updating currentPos to %d\n\n", currentPos + 1);
                    
                    currentPos += 1;
                }
                else
                {
                    currentPos += 1;
                }
                
                if (currentPos == [newArray count] - 1)
                {
                    finished = TRUE;
                    
                    for (int j = 0; j < [newArray count]; j++)
                    {
                        NSLog(@"\n\n Index %d:\n Start: %@\n End:  %@\n\n", j, [[newArray[j] objectForKey:@"start"] objectForKey:@"dateTime"], [[newArray[j] objectForKey:@"end"] objectForKey:@"dateTime"]);
                    }
                }
            }
        }
    }
    else
    {
        NSLog(@"didn't enter if-loop");
    }
    
    return (NSArray *)newArray;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    EventDetailViewController *detailViewController;
    if (IDIOM != IPAD) {
        detailViewController = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"eventDetail"];
        
        [detailViewController setEvent:[sortedArray objectAtIndex:indexPath.row]];
        [self presentPopupViewController:detailViewController animationType:0];
        detailViewController.view.superview.bounds=CGRectMake(0.0, 0.0, 240.0, 408.0);
        ///detailViewController.view.superview.center=detailViewController.view.center;
        detailViewController.view.superview.clipsToBounds=YES;
        
    }
    
    else {
        detailViewController = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"eventDetail"];
        
        [detailViewController setEvent:[sortedArray objectAtIndex:indexPath.row]];
        [self presentPopupViewController:detailViewController animationType:0];
        detailViewController.view.superview.bounds=CGRectMake(0.0, 0.0, 300.0, 500.0);
        ///detailViewController.view.superview.center=detailViewController.view.center;
        detailViewController.view.superview.clipsToBounds=YES;
    }*/
    
}


-(void) prepareForSegue:(UIStoryboardPopoverSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"dayToEventDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        EventDetailViewController *destViewController = (EventDetailViewController *)[segue destinationViewController];
        
        [destViewController setEvent:[sortedArray objectAtIndex:indexPath.row]];
    }
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





@end
