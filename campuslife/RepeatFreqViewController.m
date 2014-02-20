//
//  RepeatFreqViewController.m
//  campuslife
//
//  Created by Super Student on 2/18/14.
//  Copyright (c) 2014 LCSC. All rights reserved.
//

#import "RepeatFreqViewController.h"
#import "AddEventParentViewController.h"

@interface RepeatFreqViewController ()

@property(strong, nonatomic) NSString *repFreq;

@end

@implementation RepeatFreqViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (void)viewDidAppear:(BOOL)animated
{
    _repFreq = @"Never";
}

- (void)viewWillDisappear
{
    AddEventParentViewController *eventController = (AddEventParentViewController *)[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    
    [eventController setRepFreq:_repFreq];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (indexPath.row == 0)
    {
        ((UILabel *)[cell viewWithTag:5]).text = @"Daily";
    }
    else if (indexPath.row == 1)
    {
        ((UILabel *)[cell viewWithTag:5]).text = @"Weekly";
    }
    else if (indexPath.row == 2)
    {
        ((UILabel *)[cell viewWithTag:5]).text = @"Monthly";
    }
    else if (indexPath.row == 3)
    {
        ((UILabel *)[cell viewWithTag:5]).text = @"Yearly";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        _repFreq = @"Daily";
    }
    else if (indexPath.row == 1)
    {
        _repFreq = @"Weekly";
    }
    else if (indexPath.row == 2)
    {
        _repFreq = @"Monthly";
    }
    else if (indexPath.row == 3)
    {
        _repFreq = @"Yearly";
    }
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}


@end
