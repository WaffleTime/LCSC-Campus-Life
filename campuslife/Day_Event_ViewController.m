//
//  Day_Event_ViewController.m
//  LCSC Campus Life
//
//  Created by Super Student on 11/7/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import "Day_Event_ViewController.h"

#import "MonthlyEvents.h"



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
        
        for (int i = 0; i < [[events getEventsForDay:_day] count]; i++)
        {
            NSLog(@"entered into 1st for-loop");
            
            for (int j = 0; j < [[events getEventsForDay:_day] count] - 1; j++)
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
                NSLog(@"\n \n \n Printing st1: %d \n \n", st1);
                
                NSRange startHr2 = NSMakeRange(11, 2);
                NSRange startMn2 = NSMakeRange(14, 2);
                NSString *startHrStr2 = [[[newArray[j+1] objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:startHr2];
                NSString *startMnStr2 = [[[newArray[j+1] objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:startMn2];
                NSString *startTime2 =[startHrStr2 stringByAppendingString:startMnStr2];
                int st2 = [startTime2 intValue];
                NSLog(@"\n \n \n Printing st2: %d \n \n", st2);
                
                
                
                if (st1 > st2)
                {
                    NSLog(@"entered into the inner if-loop");
                    NSLog(@"first item %@", newArray[j]);
                    NSLog(@"second item %@", newArray[j+1]);
                    
                    NSDictionary *temp = newArray[j];
                    
                    newArray[j] = newArray[j+1];
                    
                    newArray[j+1] = temp;
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





// Useless comment!
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[events getEventsForDay:_day] count];
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
    
    NSString *eventStart = [[eventTime objectForKey:@"start"] objectForKey:@"dateTime"];
    NSRange elevenToSixteenStart = NSMakeRange(11, 5);
    NSString *startTime = [eventStart substringWithRange:elevenToSixteenStart];
    //startTime = [self twentyFourToTwelve:startTime];
    
    NSString *eventEnd = [[eventTime objectForKey:@"end"] objectForKey:@"dateTime"];
    NSRange elevenToSixteenEnd = NSMakeRange(11, 5);
    NSString *endTime = [eventEnd substringWithRange:elevenToSixteenEnd];
    //endTime = [self twentyFourToTwelve:endTime];
    
    UILabel *time = (UILabel *)[cell viewWithTag:20];
    time.text = [NSString stringWithFormat:@"%@\n to \n%@", startTime, endTime];
    
    //UIView *color = (UILabel *)[cell viewWithTag:21];
    
    UILabel *summary = (UILabel *)[cell viewWithTag:22];
    summary.text = [eventTime objectForKey:@"summary"];
    
    return cell;
}




/*
- (NSString *)twentyFourToTwelve:(NSString *)time
{
    if (time != nil)
    {
        if (time < @"10:00")
        {
            time[0] = @" ";
            [time stringByAppendingString:@"AM"];
        }
        
        if (time >= @"13:00")
        {
            //convert back to 12 hour.
            [time stringByAppendingString:@"PM"];
        }
        
    }
    
    return time;
}
*/




- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Uncertain as to what goes in here.
}





@end
