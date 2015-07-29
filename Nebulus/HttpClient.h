//
//  HttpClient.h
//  Nebulus
//
//  Created by Jike on 7/24/15.
//  Copyright (c) 2015 CMU-eBiz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Clip.h"

@interface HttpClient : NSObject
+(User*) getUser: (NSString*) username password: (NSString*) password;
+(void) logout;
+(BOOL) registerUser:(NSString*) username password: (NSString*) password email: (NSString*) email;
+(User*) getCurrentUser;
+(NSArray*) getFollowers:(User*) user;
+(NSArray*) getFollowing:(User*) user;
+(NSArray*) getTimeline:(User*) user;
+(BOOL) follow:(User*) followee follower:(User*) follower;
+(NSArray*) getClip:(NSString*) userId;

@end
