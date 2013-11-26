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
    
    MonthlyEvents *events = [MonthlyEvents getSharedInstance];
    
    [self setDay:[events getSelectedDay]];
    
    [self.tableView reloadData];
    
    NSLog(@"View loaded.");
}





/*
 *  Request new information from day at index.
 */
-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"View appeared: requesting new information from a specific day.");
    
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
}





/*
 *  Possibly useless?
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}





// Useless comment!
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MonthlyEvents *events = [MonthlyEvents getSharedInstance];
 
    //NSLog(@"THe number of rows is %d", (int)[[events getEventsForDay:_day] count]);
    
    //NSLog(@"The events for the selected day are %@", [events getEventsForDay:_day]);
    
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
    
    
    
    MonthlyEvents *events = [MonthlyEvents getSharedInstance];
    //NSLog(@"\n \n \n events at pos 1: \n %@ \n \n \n", [events getEventsForDay:1]);
    
    
    
    NSDictionary *eventTime = [[events getEventsForDay:_day] objectAtIndex:indexPath.row]; //                                                 <--
    //NSLog(@"\n \n \n I have no idea what this will do! \n \n \n %@ \n \n \n", eventTime);
    
    
    
    NSString *eventStart = [[eventTime objectForKey:@"start"] objectForKey:@"dateTime"];
    //NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> First Test. Start time: %@", eventStart);
    
    /* Okay, to explain this piece of code:
     * NSRange creates a range from which we can extract a tiny substring. This sub-string corrects the
     * (null) problem that we were having. I'll save the code, just in case, but I'll also implement the
     * new stuff. :D
     */
    NSRange elevenToSixteenStart = NSMakeRange(11, 5);
    NSString *startTime = [eventStart substringWithRange:elevenToSixteenStart];
    //NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Testing substring: startTime = %@", startTime);
    
    NSString *eventEnd = [[eventTime objectForKey:@"end"] objectForKey:@"dateTime"];
    //NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> First Test. End time: %@", eventEnd);
    
    /* Okay, to explain this piece of code:
     * NSRange creates a range from which we can extract a tiny substring. This sub-string corrects the
     * (null) problem that we were having. I'll save the code, just in case, but I'll also implement the
     * new stuff. :D
     */
    NSRange elevenToSixteenEnd = NSMakeRange(11, 5);
    NSString *endTime = [eventEnd substringWithRange:elevenToSixteenEnd];
    //NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Testing substring: endTime = %@", endTime);
    
    
    /*
    UILabel *textView1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width/4, cell.frame.size.height)];
    textView1.text = [NSString stringWithFormat:@"%@-%@", startTime, endTime];
    textView1.numberOfLines = 2;
    textView1.font = [UIFont systemFontOfSize:25];
    textView1.minimumScaleFactor = .5;
    [cell.contentView addSubview:textView1];
    
    UILabel *textView2 = [[UILabel alloc] initWithFrame:CGRectMake((cell.frame.size.width)/4, 0, 3*cell.frame.size.width/8, cell.frame.size.height)];
    textView2.text = @"Custom text 1"; //[eventTime objectForKey:@"summary"];
    textView2.numberOfLines = 2;
    textView2.font = [UIFont systemFontOfSize:25];
    textView2.minimumScaleFactor = .5;
    [cell.contentView addSubview:textView2];
    
    UILabel *textView3 = [[UILabel alloc] initWithFrame:CGRectMake((3*cell.frame.size.width)/8, 0, 3*cell.frame.size.width/4, cell.frame.size.height)];
    textView2.text = @"Custom text 2"; //[eventTime objectForKey:@"summary"];
    textView2.numberOfLines = 2;
    textView2.font = [UIFont systemFontOfSize:25];
    textView2.minimumScaleFactor = .5;
    [cell.contentView addSubview:textView3];
    
    UILabel *textView4 = [[UILabel alloc] initWithFrame:CGRectMake((3*cell.frame.size.width)/4, 0, cell.frame.size.width, cell.frame.size.height)];
    textView2.text = [eventTime objectForKey:@"summary"];
    textView2.numberOfLines = 2;
    textView2.font = [UIFont systemFontOfSize:25];
    textView2.minimumScaleFactor = .5;
    [cell.contentView addSubview:textView4];
    */
    
    /*
    [self.tableView setSortDescriptors:[NSArray arrayWithObjects:
                                       [NSSortDescriptor sortDescriptorWithKey:[[eventTime objectForKey:@"start"] objectForKey:@"dateTime"] ascending:YES selector:@selector(compare:)],
                                       [NSSortDescriptor sortDescriptorWithKey:[[eventTime objectForKey:@"end"] objectForKey:@"dateTime"] ascending:YES selector:@selector(compare:)],
                                       nil]];
    */
    
    
    return cell;
}





- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Uncertain as to what goes in here.
}





@end
