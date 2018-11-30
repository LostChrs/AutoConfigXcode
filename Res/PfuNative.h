//
//  PfuNative.h
//  Basketball-mobile
//
//  Created by Jason on 2018/5/31.
//

#import <UIKit/UIKit.h>

@interface PfuNative : NSObject
+(void)InitAds;
+(void)ShowAds;
+(BOOL)AdsAvailable;

+(void)showBanner;
+(void)hideBanner;

+(void)showShare;
@end
