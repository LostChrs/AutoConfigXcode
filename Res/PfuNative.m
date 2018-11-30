//
//  PfuNative.m
//  Basketball-mobile
//
//  Created by Jason on 2018/5/31.
//

#import "PfuNative.h"
#import "PfuAdsManager.h"
static PfuAdsManager* pfuAdsManager = nil;
@interface PfuNative ()

@end

@implementation PfuNative

+(void)InitAds
{
    NSLog(@"PFU...InitAds");
    pfuAdsManager = [[PfuAdsManager alloc] init];
    [pfuAdsManager initSdk];
}

+(void)ShowAds
{
    NSLog(@"PFU...ShowAd");
    [pfuAdsManager showAd];
}

+(BOOL)AdsAvailable
{
    return [pfuAdsManager AdsAvailable];
}

+(void)showBanner
{
    [pfuAdsManager showBanner];
}

+(void)hideBanner
{
    [pfuAdsManager hideBanner];
}

+(void)showShare
{
    [pfuAdsManager showShare];
}

@end
