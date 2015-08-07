//
//  TimelineViewController.m
//  Nebulus
//
//  Created by Gang Wu on 8/5/15.
//  Copyright (c) 2015 CMU-eBiz. All rights reserved.
//

#import "TimelineViewController.h"
#import "MusicHttpClient.h"
#import "UserHttpClient.h"

@interface TimelineViewController ()
@property (strong, nonatomic) NSArray *activity;
@end

@implementation TimelineViewController

#pragma mark - property
-(NSArray *)activity{
    return _activity ? _activity : @[];
}

#pragma mark - View Controller
-(void)viewWillAppear:(BOOL)animated{
    //self.activity = [MusicHttpClient getAllFollowingActivities:[UserHttpClient getCurrentUser]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    //return [self.activity count];
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;

    if(indexPath.row == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:@"topCell"];
            [(UILabel *)[cell viewWithTag:102] setText:@"Bon Jovi"];
            [(UILabel *)[cell viewWithTag:103] setText:@"1 min ago"];
            [(UILabel *)[cell viewWithTag:104] setText:@"Shared a song"];
    } else if(indexPath.row == 1){
            cell = [tableView dequeueReusableCellWithIdentifier:@"textCell"];
            UITextView *textView = (UITextView *)[cell viewWithTag:101];
            [textView setText:@"Rock the world"];
    } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"buttomCell"];
    }
    
    return cell;
}

#define HEIGHT_TOP_CELL     80.0
#define HEIGHT_BOTTOM_CELL  35.0
#define HEIGHT_TEXT_CELL    35.0
#define HEIGHT_PLAY_CELL    45.0
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        return HEIGHT_TOP_CELL;
    } else if(indexPath.row == 1){
        return HEIGHT_TEXT_CELL;
    } else {
        return HEIGHT_BOTTOM_CELL;
    }
    return 0.0;
}




@end