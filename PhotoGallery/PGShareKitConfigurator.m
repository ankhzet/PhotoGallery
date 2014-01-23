//
//  PGShareKitConfigurator.m
//  PhotoGallery
//
//  Created by Ankh on 22.01.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "PGShareKitConfigurator.h"

@implementation PGShareKitConfigurator

/*
 App Description
 ---------------
 These values are used by any service that shows 'shared from XYZ'
 */
- (NSString*)appName {
	return @"Photo Gallery";
}

- (NSString*)appURL {
	return @"http://dummy.url";
}

// Twitter

/*
 If you want to force use of old-style, pre-IOS5 twitter authentication, set this to true. This way user will have to enter credentials to the OAuthWebView presented by your app. These credentials will not end up in the device account store. If set to false, sharekit takes user credentials from the builtin device store on iOS6 or later and utilizes social.framework to share content. Much easier, and thus recommended is to leave this false and use iOS builtin authentication.
 */
- (NSNumber*)forcePreIOS5TwitterAccess {
	return [NSNumber numberWithBool:false];
}

/* YOU CAN SKIP THIS SECTION unless you set forcePreIOS5TwitterAccess to true, or if you support iOS 4 or older.
 
 Register your app here - http://dev.twitter.com/apps/new
 
 Differences between OAuth and xAuth
 --
 There are two types of authentication provided for Twitter, OAuth and xAuth.  OAuth is the default and will
 present a web view to log the user in.  xAuth presents a native entry form but requires Twitter to add xAuth to your app (you have to request it from them).
 If your app has been approved for xAuth, set SHKTwitterUseXAuth to 1.
 
 Callback URL (important to get right for OAuth users)
 --
 1. Open your application settings at http://dev.twitter.com/apps/
 2. 'Application Type' should be set to BROWSER (not client)
 3. 'Callback URL' should match whatever you enter in SHKTwitterCallbackUrl.  The callback url doesn't have to be an actual existing url.  The user will never get to it because ShareKit intercepts it before the user is redirected.  It just needs to match.
 */

- (NSString*)twitterConsumerKey {
	return @"w0H5vIiNGZAzpLq34KDi5w";
}

- (NSString*)twitterSecret {
	return @"bHcT7r6d37eN6ZymLvFrtEC4Qs4n5nwEMSBY1rq30";
}
// You need to set this if using OAuth, see note above (xAuth users can skip it)
- (NSString*)twitterCallbackUrl {
	return @"";
}
// To use xAuth, set to 1
- (NSNumber*)twitterUseXAuth {
	return [NSNumber numberWithInt:0];
}
// Enter your app's twitter account if you'd like to ask the user to follow it when logging in. (Only for xAuth)
- (NSString*)twitterUsername {
	return @"";
}


// Tumblr - http://www.tumblr.com/docs/en/api/v2
- (NSString*)tumblrConsumerKey {
	return @"";
}

- (NSString*)tumblrSecret {
	return @"";
}

//you can put whatever here. It must be the same you entered in tumblr app registration, eg tumblr.sharekit.com
- (NSString*)tumblrCallbackUrl {
	return @"";
}


/*
 Favorite Sharers
 ----------------
 These values are used to define the default favorite sharers appearing on ShareKit's action sheet.
 */
- (NSArray*)defaultFavoriteURLSharers {
	return [NSArray arrayWithObjects:@"SHKTwitter",@"SHKTumblr", nil];
}
- (NSArray*)defaultFavoriteImageSharers {
	return [NSArray arrayWithObjects:@"SHKTwitter",@"SHKTumblr", nil];
}
- (NSArray*)defaultFavoriteTextSharers {
	return [NSArray arrayWithObjects:@"SHKTwitter",@"SHKTumblr", nil];
}

- (NSArray *)defaultFavoriteSharersForFile:(SHKFile *)file {
	return [NSArray arrayWithObjects:@"SHKTwitter",@"SHKTumblr", nil];
}

- (NSArray*)defaultFavoriteSharersForMimeType:(NSString *)mimeType {
	return [self defaultFavoriteSharersForFile:nil];
}

- (NSArray *)defaultFavoriteFileSharers {
	return [self defaultFavoriteSharersForFile:nil];
}


@end
