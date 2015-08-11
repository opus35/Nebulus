//
//  ModifyAlbumProjectViewController.m
//  Nebulus
//
//  Created by Gang Wu on 8/7/15.
//  Copyright (c) 2015 CMU-eBiz. All rights reserved.
//

#import "ModifyViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
//#import <QuartzCore/QuartzCore.h>

#import "MusicHttpClient.h"
#import "Album.h"
#import "Project.h"
#import "UserHttpClient.h"
#import "User.h"

@interface ModifyViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *tags;
@property (weak, nonatomic) IBOutlet UITextView *desc;

@property (nonatomic) BOOL changePic;

@property (strong, nonatomic) UIImagePickerController *picker;

@end

@implementation ModifyViewController

#pragma mark - View Controller

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.mode == M_PROJECT){
        
        [self setTitle:@"Edit Project"];
    } else if(self.mode == M_ALBUM) {        // ALBUM
        Album *album   = (Album *)self.content;

        self.name.text = album.name;
        [self.tags setText:[album.tags componentsJoinedByString:@","]];
        [self.desc setText:album.albumDescription];
        
        self.imageView.image = self.image;//[MusicHttpClient getAlbumImage:album.objectID];
        
        [self setTitle:@"Edit Album"];
    } else if(self.mode == M_PROFILE){
        User *user = (User *)self.content;
        
        self.name.text = user.name;
        [self.tags setText:[user.tags componentsJoinedByString:@","]];
        [self.desc setText:user.about];
        self.imageView.image = self.image;//[UserHttpClient getUserImage:user.objectID];
        
        [self setTitle:user.username];
    }
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.picker = [[UIImagePickerController alloc] init];
    [self.picker setDelegate:self];
    self.picker.allowsEditing = YES;
    
    UIBarButtonItem *Done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                          target:self
                                                                          action:@selector(performDone)];
    self.navigationItem.rightBarButtonItem = Done;
}

#pragma mark - Update Modification

-(void)performDone{
    if(self.mode == M_ALBUM){
        
        Album *album = (Album *)self.content;
        album.name = self.name.text;
        album.albumDescription = [self.desc.textStorage string];
        album.tags = @[self.tags.text];
        
        album = [MusicHttpClient updateAlbum:album];
    }else if(self.mode == M_PROJECT){ // PROJECT
        
    }else if(self.mode == M_PROFILE) {
        User *user = (User *)self.content;
        
        user.name = self.name.text;
        user.about = [self.desc.textStorage string];
        user.tags = @[self.tags.text];
        
        user = [UserHttpClient updateUserInfo:user];
    }
    
    if (self.changePic == YES){
        if(self.mode == M_ALBUM){
            [MusicHttpClient setAlbumImage:self.image AlbumId:((Album *)self.content).objectID];
        }else if(self.mode == M_PROJECT){ // PROJECT
            
        }else if(self.mode == M_PROFILE) {
            [UserHttpClient setUserImage:self.image userId:((User *)self.content).objectID];
        }
        
        self.changePic = NO;
    }
    
    [self.navigationController popToViewController:self.backVC animated:YES];
}

#pragma mark - Head photo

- (IBAction)add:(id)sender {
    
    // it is in simulator
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil
                                                                delegate:self
                                                       cancelButtonTitle:@"Cancel"
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:@"Take Photo",@"Choose Existing", nil];
        [actionSheet showInView:self.view];
        
    } else {
        self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.picker animated:YES completion:nil];
    }
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.picker animated:YES completion:NULL];
    } else if (buttonIndex == 1) {
        self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.picker animated:YES completion:NULL];
    } else {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}


- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToUse;
    
    // Handle a still image picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        editedImage   = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToUse = editedImage;
        } else {
            imageToUse = originalImage;
        }
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.clipsToBounds = YES;
        [self.imageView setImage:imageToUse];
        
        self.image = imageToUse;
        self.changePic = YES;
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel: (UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end
