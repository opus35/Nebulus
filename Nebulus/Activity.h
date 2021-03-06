//
//  Activity.h
//  Nebulus
//
//  Created by Jike on 8/5/15.
//  Copyright (c) 2015 CMU-eBiz. All rights reserved.
//
//
//activity = {
//    "creator": <user>,
//    "data": <object(see below)> | optional({}),
//    "pictureUpdateTime": <time> | optional(0),
//    "recordingDuration": <int> | optional(0),
//    "recordingId": <ObjectID of recording> | optional(null),
//    "tags": <array of strings>,
//    "text": <string>,
//    "title": <string>,
//    "type": <enum(see below)>
//}

#import "Model.h"
#import "User.h"

@interface Activity : Model
-(id) initWithDict:(NSDictionary *)json;
-(NSDictionary*)convertToDict;
//Common Property
@property (strong, nonatomic) User *creator;
@property (strong, nonatomic) NSArray *tags;
@property (strong, nonatomic) NSNumber *pictureUpdateTime;
@property (strong, nonatomic) NSString *recordingId;
@property (strong, nonatomic) NSNumber *recordingDuration;
@property (strong, nonatomic) NSString *text;

//Type of Act, {announcement, albumShare, clipShare, projectClassified, projectShare, textShare, userClassified}
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *title;

//Special Data property
//type = "announcement"
//data = {}
//
//type = "albumShare"
//data = {
//    /* This is still being worked on */
//}
//
//type = "clipShare"
//data = {}
//
//type = "projectClassified"
//data = {
//    "fullfilled": <bool>
//}
//
//type = "projectShare"
//data = {
//    "editors": <array of users>
//}
//
//type = "textShare"
//data = {}
//
//type = "userClassified"
//data = {
//    "fullfilled": <bool>
//}

@property (nonatomic) BOOL fullfuilled;
@property (strong, nonatomic) NSArray *editors;



@end
