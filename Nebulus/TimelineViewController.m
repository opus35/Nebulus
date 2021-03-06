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
#import "OtherProfileViewController.h"
#import "TimelineDetailViewController.h"
#import "PostCommentViewController.h"
#import "PlayFileViewController.h"
#import "RecordingHttpClient.h"

@interface TimelineViewController ()
@property (weak, nonatomic) IBOutlet UITableView *timelineTableView;
@property (strong, nonatomic) NSArray *activity;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@property (atomic) BOOL started;
@end

@implementation TimelineViewController

#pragma mark - property
-(NSArray *)activity{
    return _activity ? _activity : @[];
}

#pragma mark - View Controller
-(void)viewDidLoad{
    [super viewDidLoad];
    
    if(self.selfMode)
        self.navigationItem.rightBarButtonItem = nil;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    self.indicator = [[UIActivityIndicatorView alloc]
                      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    UIView *view = [[UIView alloc] initWithFrame:self.tableView.tableFooterView.bounds];
    [view addSubview:self.indicator];
    self.tableView.tableFooterView = view;
    
    [self.indicator startAnimating];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!self.currUser) {
            self.currUser = [UserHttpClient getCurrentUser];
        }
        self.activity = self.selfMode ? [MusicHttpClient getUserActivity:self.currUser.objectID]
        : [MusicHttpClient getAllFollowingActivities:self.currUser.objectID];
        
        NSLog(@"Fetched %ld activities", [self.activity count]);
        [self.tableView reloadData];
        [self.indicator stopAnimating];
        self.started = YES;
    });
    
}

-(void)viewWillAppear:(BOOL)animated{
//    if(self.started){
//        self.activity = self.selfMode ? [MusicHttpClient getUserActivity:self.currUser.objectID]
//        : [MusicHttpClient getAllFollowingActivities:self.currUser.objectID];
//        
//        NSLog(@"Fetched %ld activities", [self.activity count]);
//        [self.tableView reloadData];
//    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.activity count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //Activity *activity = self.activity[section];
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    tableView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:240.0/255.0 blue:230.0/255.0 alpha:0.7];
    
    Activity *activity = self.activity[indexPath.section];
    
    if(indexPath.row == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:@"topCell"];
        
        UIImage *image = [UserHttpClient getUserImage:activity.creator.objectID];
        if(image) [(UIImageView *)[cell viewWithTag:101] setImage: image];
        UIImageView *photo = (UIImageView *) [cell viewWithTag:101];
        photo.layer.cornerRadius = photo.frame.size.width / 2;
        photo.clipsToBounds = YES;
        photo.layer.borderWidth = 2.0f;
        photo.layer.borderColor = [UIColor colorWithRed:255.0/255.0 green:99.0/255.0 blue:71.0/255.0 alpha:1].CGColor;
        
        [(UILabel *)[cell viewWithTag:102] setText:activity.creator.username];
        UILabel *userName = (UILabel *) [cell viewWithTag:102];
        [userName setTextColor:[UIColor colorWithRed:255.0/255.0 green:99.0/255.0 blue:71.0/255.0 alpha:1]];
        [userName setFont:[UIFont boldSystemFontOfSize:17]];
        
//        UILabel *userName = (UILabel *) [cell viewWithTag:102];
//        [userName setTextColor:[UIColor colorWithRed:11.0/255.0 green:23.0/255.0 blue:70.0/255.0 alpha:1.0]];

        
        [(UILabel *)[cell viewWithTag:103] setText:[activity.tags componentsJoinedByString:@", "]];
        
        [(UILabel *)[cell viewWithTag:104] setText:activity.title];
        UILabel *title = (UILabel *) [cell viewWithTag:104];
        title.font = [UIFont fontWithName:@"ArialHebrew" size:12];
        [title setTextColor:[UIColor grayColor]];
        
        if(![activity.type isEqualToString:@"clipShare"]){
            [(UIButton *)[cell viewWithTag:200] setHidden:YES];
        }else{
            [(UIButton *)[cell viewWithTag:200] setHidden:NO];
        }
        
//        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(20,60,280,1)];
//        separator.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:99.0/255.0 blue:71.0/255.0 alpha:1];
//        [cell addSubview:separator];
        
    } else if(indexPath.row == 1){
        cell = [tableView dequeueReusableCellWithIdentifier:@"textCell"];
        UITextView *textView = (UITextView *)[cell viewWithTag:101];
        [textView setText:activity.text];
        
        textView.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
//        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(20, 45, 280, 1)];
//        separator.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:99.0/255.0 blue:71.0/255.0 alpha:1];
//        [cell addSubview:separator];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"buttomCell"];
    }
    
    return cell;
}

#pragma mark - Height

#define HEIGHT_TOP_CELL     60.0
#define HEIGHT_BOTTOM_CELL  35.0
#define HEIGHT_TEXT_CELL    40.0
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 3.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 3.0;
}

#pragma mark - Button action

- (IBAction)like:(UIButton *)sender {
    UIButton *likeButton = sender;
    CGRect buttonFrame = [likeButton convertRect:likeButton.bounds toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonFrame.origin];
  //  NSLog(@"Clicked at %ld %ld", indexPath.section, indexPath.row);
}

//- (IBAction)comment:(UIButton *)sender {
//    UIButton *commentButton = sender;
//    CGRect buttonFrame = [commentButton convertRect:commentButton.bounds toView:self.tableView];
//    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonFrame.origin];
//    NSLog(@"Clicked at %ld %ld", indexPath.section, indexPath.row);
//    
//    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Comment"
//                                                     message:@"Enter comment here"
//                                                    delegate:self
//                                           cancelButtonTitle:@"Cancel"
//                                           otherButtonTitles: nil];
//    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
//    [alert addButtonWithTitle:@"Comment"];
//    [alert show];
//    
//}

- (IBAction)viewDetail:(UIButton *)sender {
    UIButton *button = sender;
    CGRect buttonFrame = [button convertRect:button.bounds toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonFrame.origin];
    
    TimelineDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"timelinedetailviewcontroller"];
    Activity *activity = [self.activity objectAtIndex:indexPath.section];
    vc.activity = activity;
    vc.currUser = self.currUser;
    [self.navigationController pushViewController:vc animated:YES];
}



#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"viewPlayer"]) {
        if ([segue.destinationViewController isKindOfClass:[PlayFileViewController class]]) {
            PlayFileViewController *vc = (PlayFileViewController *)segue.destinationViewController;
            UITableViewCell *cell = (UITableViewCell *)sender;
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            Activity *activity = [self.activity objectAtIndex:indexPath.section];

            
            NSData *recording = [RecordingHttpClient getRecording:activity.recordingId];
            NSString *file_name = [NSString stringWithFormat:@"%@'s clip.m4a", activity.creator.username];
            
            [recording writeToURL:[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:file_name]]  atomically:YES];
            vc.fileName =file_name;
            vc.recordingId = activity.recordingId;
        }
    }else if ([segue.identifier isEqualToString:@"viewTimelineDetail"]) {
        if ([segue.destinationViewController isKindOfClass:[TimelineDetailViewController class]]) {
            TimelineDetailViewController *vc = (TimelineDetailViewController *)segue.destinationViewController;
            UITableViewCell *cell = (UITableViewCell *)sender;
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            Activity *activity = [self.activity objectAtIndex:indexPath.section];
            vc.currUser = self.currUser;
            vc.activity = activity;
        }
    }else if ([segue.identifier isEqualToString:@"comment"]) {
        if ([segue.destinationViewController isKindOfClass:[PostCommentViewController class]]) {
            PostCommentViewController *vc = (PostCommentViewController *)segue.destinationViewController;
            UITableViewCell *cell = (UITableViewCell *)sender;
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            Activity *activity = [self.activity objectAtIndex:indexPath.section];
            vc.currUser = self.currUser;
            vc.activity = activity;
            vc.commentMode = YES;
        }
    }else if ([segue.identifier isEqualToString:@"textPost"]) {
        if ([segue.destinationViewController isKindOfClass:[PostCommentViewController class]]) {
            PostCommentViewController *vc = (PostCommentViewController *)segue.destinationViewController;

            vc.currUser = self.currUser;
            vc.activity = nil;
            vc.commentMode = NO;
        }
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if([identifier isEqualToString:@"viewPlayer"]){
        UIButton *button = sender;
        CGRect buttonFrame = [button convertRect:button.bounds toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonFrame.origin];
        Activity *activity = [self.activity objectAtIndex:indexPath.section];
        if([activity.type isEqualToString:@"clipShare"]) return YES;
        else return NO;
    }
    return YES;
}

- (IBAction)doRefresh:(UIRefreshControl *)sender {
    self.activity = self.selfMode ? [MusicHttpClient getUserActivity:self.currUser.objectID]
    : [MusicHttpClient getAllFollowingActivities:self.currUser.objectID];
    
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
    
    //NSLog(@"Fetched %ld activities", [self.activity count]);
}

#pragma mark - open clip player
- (IBAction)openClip:(UIButton *)sender {
    UIButton *button = sender;
    CGRect buttonFrame = [button convertRect:button.bounds toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonFrame.origin];
    Activity *activity = [self.activity objectAtIndex:indexPath.section];
    NSData *recording = [RecordingHttpClient getRecording:activity.recordingId];
    NSString *file_name = [NSString stringWithFormat:@"%@'s clip.m4a", activity.creator.username];

    PlayFileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"playViewController"];
    
    [recording writeToURL:[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:file_name]]  atomically:YES];
    vc.fileName =file_name;
    vc.recordingId = activity.recordingId;

    [self.navigationController pushViewController:vc animated:YES];
    //NSLog(@"Should open clip %ld", indexPath.section);
}

- (NSString *)applicationDocumentsDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}
@end
