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

#pragma mark - Property

-(NSString *)groupName{
    if(!_groupName) _groupName = @"";
    return _groupName;
}

-(NSNumber *)pictureUpdateTime{
    if(!_pictureUpdateTime) _pictureUpdateTime = @0;
    return _pictureUpdateTime;
}

-(NSArray *)projects{
    if(!_projects) _projects = @[];
    return _projects;
}

-(NSArray *)editors{
    if(!_editors) _editors = @[];
    return _editors;
}

-(NSArray *)tags{
    if(!_tags) _tags = @[];
    return _tags;
}

-(NSString *)albumDescription{
    if(!_albumDescription) _albumDescription = @"";
    return _albumDescription;
}

-(NSString *)name{
    if(!_name)_name = @"";
    return _name;
}

#pragma mark - JSON methods

-(id) initWithDict:(NSDictionary *)json {
    self = [super initWithDict: json];
    if(self) {
        NSDictionary *meta = [json objectForKey:@"meta"];
        self.albumDescription = [meta objectForKey:@"description"];
        self.groupName = [meta objectForKey:@"groupName"];
        self.name = [meta objectForKey:@"name"];
        self.tags = [meta objectForKey:@"tags"];
        
        self.pictureUpdateTime = [json objectForKey:@"pictureUpdateTime"];
        
        //Projects
//        NSArray *rawprojects = [json objectForKey:@"projects"];
//        NSMutableArray *projects = [[NSMutableArray alloc] init];
//        for (int i = 0; i < [rawprojects count]; i++) {
//            Project *p = [[Project alloc]initWithDict:rawprojects[i]];
//            [projects addObject:p];
//        }
        self.projects = [json objectForKey:@"projects"];
        
        //Users
        NSDictionary *users = [json objectForKey:@"users"];
        self.creator = [[User alloc] initWithDict:[users objectForKey:@"creator"]];
        NSArray *rawEditors = [users objectForKey:@"editors"];
        NSMutableArray *editors = [[NSMutableArray alloc] init];
        for (int i = 0; i < [rawEditors count]; i++) {
            User *editor = [[User alloc] initWithDict:rawEditors[i]];
            [editors addObject:editor];
        }
        self.editors = editors;
    }
    return self;
    
}
-(NSDictionary*) convertToDict {
    NSMutableDictionary *dict = [super convertToDict].mutableCopy;
    NSMutableDictionary *meta = [[NSMutableDictionary alloc]init];
    [meta setObject:self.groupName forKey:@"groupName"];
    [meta setObject:self.albumDescription forKey:@"description"];
    [meta setObject:self.groupName forKey:@"groupName"];
    [meta setObject:self.name forKey:@"name"];
    [dict setObject:meta forKey:@"meta"];
    [dict setObject:self.pictureUpdateTime forKey:@"pictureUpdateTime"];
    [dict setObject:self.tags forKey:@"tags"];
    
    //Projects
//    NSMutableArray *projects = [[NSMutableArray alloc] init];
//    for (int i = 0; i < [self.projects count]; i++) {
//        [projects addObject:[self.projects[i] convertToDict]];
//    }
    [dict setObject:self.projects forKey:@"projects"];
    
    //Users
    NSMutableDictionary *users = [[NSMutableDictionary alloc]init];
    NSMutableArray *editors = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.editors count]; i++) {
        [editors addObject:[self.editors[i] convertToDict]];
    }
    [users setValue: [self.creator convertToDict] forKey:@"creator"];
    [users setValue: editors forKey:@"editors"];
    [dict setValue:users forKey:@"users"];
    return dict;
}

-(bool) isUser:(NSString*) userId {
    if ([self.creator.objectID isEqualToString: userId]) return YES;
    for (User *editor in self.editors) {
        if ([editor.objectID isEqualToString: userId]) return YES;
    }
    return NO;
}

@end