#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//Umeng
#import <UMCommon/UMCommon.h>        // 公共组件是所有友盟产品的基础组件，必选
#import "UMAnalytics/MobClick.h"        // 统计组件

#import "UnityAds/UnityAds.h"
#import "VungleSDK/VungleSDK.h"
#import "AppLovinSDK/AppLovinSDK.h"
#import "WXApi.h"

#define ShareTitle @"一起来种田吧~"
#define ShareUrl @"https://itunes.apple.com/cn/app/bad-north/id1441005816?mt=12"

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}


//Create by Wangjia
@interface PfuAdsManager : NSObject<WXApiDelegate,UnityAdsDelegate,VungleSDKDelegate,ALAdLoadDelegate,ALAdVideoPlaybackDelegate>
{
	UIViewController* rootViewController;
}
@property (nonatomic, strong) ALAd * ad;
@property (nonatomic, strong) UIView* bannerView;

-(void)initSdk;
-(void)showAd;
-(BOOL)AdsAvailable;

-(void)showBanner;
-(void)hideBanner;

-(void)showShare;
@end
