//
//  TimelineDetailViewController.m
//  Nebulus
//
//  Created by Gang Wu on 8/17/15.
//  Copyright (c) 2015 CMU-eBiz. All rights reserved.
//

#import "TimelineDetailViewController.h"
#import "UserHttpClient.h"
#import "ActivityHttpClient.h"
#import "OtherProfileViewController.h"
#import "Comment.h"
#import "PostCommentViewController.h"

@interface TimelineDetailViewController ()
@property (nonatomic, strong) NSArray *comments;
@end

@implementation TimelineDetailViewController

#pragma mark - view controller

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.comments = [ActivityHttpClient getCommentofActivity:self.activity.objectID];
    NSLog(@"Fetched %ld comments", [self.comments count]);
}

#pragma mark - Property

-(NSArray *)comments{
    if(!_comments) _comments = @[];
    return _comments;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0) return 0.1;
    else if(section == 1) return 30.0;
    return 0.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0)
        return 3;
    else if(section == 1)
        return [self.comments count];
    return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return @"";
    } else {// if (section == 1){
        return @"Comments";
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            cell = [tableView dequeueReusableCellWithIdentifier:@"topCell"];
            [(UIImageView *)[cell viewWithTag:101] setImage: [UserHttpClient getUserImage:self.activity.creator.objectID]];
            [(UILabel *)[cell viewWithTag:102] setText:self.activity.creator.username];
            [(UILabel *)[cell viewWithTag:103] setText:[self.activity.tags componentsJoinedByString:@", "]];
            [(UILabel *)[cell viewWithTag:104] setText:self.activity.title];
            
            if(![self.activity.type isEqualToString:@"clipShare"]){
                [(UIButton *)[cell viewWithTag:200] setHidden:YES];
            }else{
                [(UIButton *)[cell viewWithTag:200] setHidden:NO];
            }
        } else if(indexPath.row == 1){
            cell = [tableView dequeueReusableCellWithIdentifier:@"textCell"];
            UITextView *textView = (UITextView *)[cell viewWithTag:101];
            [textView setText:self.activity.text];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"buttomCell"];
        }
    }else if(indexPath.section == 1){
        cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
        
        Comment *comment = [self.comments objectAtIndex:indexPath.row];
        [(UIImageView *)[cell viewWithTag:101] setImage: [UserHttpClient getUserImage:comment.creator.objectID]];
        [(UILabel *)[cell viewWithTag:102] setText:comment.creator.username];
        [(UITextView *)[cell viewWithTag:103] setText:comment.text];
        [(UIButton *)[cell viewWithTag:104] setHidden:NO];   // LIKE button
        
        if(comment.clip && comment.clip.objectID){
            [(UIButton *)[cell viewWithTag:105] setHidden:NO];  // PLAY button
        }else{
            [(UIButton *)[cell viewWithTag:105] setHidden:YES];
        }
    }
    
    return cell;
}

#define HEIGHT_TOP_CELL     80.0
#define HEIGHT_BOTTOM_CELL  35.0
#define HEIGHT_TEXT_CELL    35.0
#define HEIGHT_PLAY_CELL    45.0
#define HEIGHT_COMMENT_CELL 60.0
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if(indexPath.section == 0){
        if(indexPath.row == 0){
            return HEIGHT_TOP_CELL;
        } else if(indexPath.row == 1){
            return HEIGHT_TEXT_CELL;
        } else {
            return HEIGHT_BOTTOM_CELL;
        }
    }else if(indexPath.section == 1){
        return HEIGHT_COMMENT_CELL;
    }
    return 0.0;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"viewUser"]) {
        if ([segue.destinationViewController isKindOfClass:[OtherProfileViewController class]]) {
            OtherProfileViewController *vc = (OtherProfileViewController *)segue.destinationViewController;

            vc.me = self.currUser;
            vc.other = self.activity.creator;
            vc.invitation_mode = NO;
        }
    }else if ([segue.identifier isEqualToString:@"comment"]) {
        if ([segue.destinationViewController isKindOfClass:[PostCommentViewController class]]) {
            PostCommentViewController *vc = (PostCommentViewController *)segue.destinationViewController;
            vc.currUser = self.currUser;
            vc.activity = self.activity;
            vc.commentMode = YES;
        }
    }
}

#pragma mark - open clip player
- (IBAction)openActivityClip:(UIButton *)sender {
    NSLog(@"Activity clip is clicked");
}

- (IBAction)openCommentClip:(UIButton *)sender {
    UIButton *button = sender;
    CGRect buttonFrame = [button convertRect:button.bounds toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonFrame.origin];
    
    if(indexPath.section == 1){
        NSLog(@"Should open clip %ld in comment", indexPath.row);
    }
}

@end
