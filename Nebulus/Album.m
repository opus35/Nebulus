//
//  Album.m
//  Nebulus
//
//  Created by Jike on 7/28/15.
//  Copyright (c) 2015 CMU-eBiz. All rights reserved.
//
//album = {
//    "description": <string> | optional(null),
//    "groupName": <string> | optional(null),
//    "name": <string>,
//    "pictureUpdateTime": <time> | optional(0),
//    "projects": <array of (ObjectIDs of projects)>,
//    "users": {
//        "creator": <user>,
//        "editors": <array of users>
//    },
//    "tags": <array of strings>
//}

#import "Album.h"

@implementation Album

-(id) initWithDict:(NSDictionary *)json {
    self = [super initWithDict: json];
    if(self) {
        self.albumDescription = [json objectForKey:@"description"];
        self.groupName = [json objectForKey:@"groupName"];
        self.name = [json objectForKey:@"name"];
        self.pictureUpdateTime = [json objectForKey:@"pictureUpdateTime"];
        self.tags = [json objectForKey:@"tags"];
        self.projects = [json objectForKey:@"projects"];
        NSDictionary *users = [json objectForKey:@"users"];
        self.creator = [users objectForKey:@"creator"];
        self.editors = [users objectForKey:@"editors"];
    }
    return self;
    
}
-(NSDictionary*) convertToDict {
    NSMutableDictionary *dict = [super convertToDict].mutableCopy;
    [dict setObject:self.albumDescription forKey:@"description"];
    [dict setObject:self.groupName forKey:@"groupName"];
    [dict setObject:self.pictureUpdateTime forKey:@"pictureUpdateTime"];
    [dict setObject:self.name forKey:@"name"];
    [dict setObject:self.tags forKey:@"tags"];
    [dict setObject:self.projects forKey:@"projects"];
    NSMutableDictionary *users = [[NSMutableDictionary alloc]init];
    [users setValue:self.creator forKey:@"creator"];
    [users setValue:self.editors forKey:@"editors"];
    [dict setValue:users forKey:@"users"];
    return dict;
}

@end