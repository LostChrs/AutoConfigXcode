#import "PfuAdsManager.h"
#import "cocos2d.h"

#include "cocos/scripting/js-bindings/jswrapper/SeApi.h"
using namespace std;

@implementation PfuAdsManager
{
    enum EAdsType {
        eAdsUnity = 1,
        eAdsVungle = 2,
        eAdsAppLovin = 3,
        eAdsMAX = 4,
        eAdsMintegra
    };
    EAdsType m_adsFlag;//1,Unity 2,Vungle 3,AppLovin 4,Mintegra
    int m_adsCount;
    BOOL bCanShowAds;
    
    
}

-(void)initSdk
{
    rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    //init all AdsSdk
    self->bCanShowAds = YES;
    self->m_adsFlag = eAdsUnity;
    self->m_adsCount = 0;

    [UnityAds initialize:UNITYID delegate:self testMode:NO];
        
    //applovinSDK
    [ALSdk initializeSdk];
    [self loadInterstitialAd];
    
    UIView* rootView = rootViewController.view;
    CGSize rootSize = rootView.frame.size;
    //applovinBanner
    ALAdView* adView = [[ALAdView alloc] initWithFrame:CGRectMake(0, rootSize.height-80, rootSize.width, 70) size:[ALAdSize sizeBanner] sdk:[ALSdk shared]];
    [adView loadNextAd];
    [rootViewController.view addSubview:adView];
    
    self.bannerView = adView;
    
    
    NSArray* placeArray = @[AdsIdVungle];
    VungleSDK* sdk = [VungleSDK sharedSDK];
    [sdk setDelegate:self];
    [sdk startWithAppId:VUNGLEID placements:placeArray error:nil];
    
    [UMConfigure setLogEnabled:NO];
    [UMConfigure initWithAppkey:UMID channel:@"App Store"];
    
    
    //wechat share
    [WXApi registerApp:WXAppId];
}

//banner
-(void)showBanner
{
    [self.bannerView setHidden:NO];
}

-(void)hideBanner
{
    [self.bannerView setHidden:YES];
}

-(BOOL)AdsAvailable
{
    return [self checkAdsAvailable:eAdsUnity];
}

-(void)showAd
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showAdsAutopick];
                   });
}

- (BOOL)checkAdsAvailable:(EAdsType)adsType
{
    //选择当前播放的广告
    
    BOOL unityReady = [UnityAds isReady:AdsIdUnity];
    BOOL vungleReady = [[VungleSDK sharedSDK] isAdCachedForPlacementID:AdsIdVungle];
    BOOL lovinReady = self.ad != nil;

    
    
    if(!unityReady && !vungleReady && !lovinReady){
        //广告都没准备好
        self->bCanShowAds = NO;
        return NO;
    }
    
    //至少有一个广告可以播放
    switch (adsType) {
        case eAdsUnity:
            return unityReady;
            break;
        case eAdsVungle:
            return vungleReady;
            break;
        case eAdsAppLovin:
            return lovinReady;
            break;
            
        default:
            break;
    }
    
    return YES;
}

- (void)nextAds
{
    NSLog(@"nextAds:%d",(int)self->m_adsFlag);
    if([self checkAdsAvailable:self->m_adsFlag]){
        self->m_adsCount++;
        if(self->m_adsCount <= 3){
            return;//Ready
        }
    }
    
    if(self->bCanShowAds == NO)return;
    
    self->m_adsCount = 0;
    if((int)self->m_adsFlag >= ((int)eAdsMAX-1) )
    {
        self->m_adsFlag = (EAdsType)1;
    }else{
        self->m_adsFlag = (EAdsType)((int)self->m_adsFlag + 1);
    }
    [self nextAds];
}

- (void)showAdsAutopick
{
    //自动选择广告，每种广告播放3次，之后播放下一个广告。
    
    [self nextAds];
    
    if(self->bCanShowAds == NO){
        [self OnAdsCallback:NO];
        return;
    }
    
    
    if(self->m_adsFlag == eAdsUnity){
        [UnityAds show:self->rootViewController placementId:AdsIdUnity];
    }
    else if(self->m_adsFlag == eAdsVungle)
    {
        VungleSDK* sdk = [VungleSDK sharedSDK];
        NSError *error;
        [sdk playAd:self->rootViewController options:nil placementID:AdsIdVungle error:&error];
        if (error) {
            NSLog(@"Error encountered playing ad: %@", error);
        }
    }
    else if(self->m_adsFlag == eAdsAppLovin)
    {
        [ALInterstitialAd shared].adVideoPlaybackDelegate = self;
        [[ALInterstitialAd shared] showOver:[UIApplication sharedApplication].keyWindow andRender:self.ad];
    }

}

//applovin
- (void)loadInterstitialAd
{
    [[ALSdk shared].adService loadNextAd:[ALAdSize sizeInterstitial] andNotify: self];
}

- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad
{
    NSLog(@"ApplovinAds didLoadAd......");
    self.ad = ad;
}
- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code
{
    NSLog(@"Error LovinAds playing ad: %d", code);
}
- (void)videoPlaybackBeganInAd:(ALAd *)ad
{
    
}

- (void)videoPlaybackEndedInAd:(ALAd *)ad atPlaybackPercent:(NSNumber *)percentPlayed fullyWatched:(BOOL)wasFullyWatched
{
    NSLog(@"ApplovinAds videoPlaybackEndedInAd !");
    [[ALSdk shared].adService loadNextAd:[ALAdSize sizeInterstitial] andNotify: self];
    if(wasFullyWatched){
        [self OnAdsCallback:YES];
    }else{
        [self OnAdsCallback:NO];
    }
}




- (void)unityAdsReady:(NSString *)placementId{
    NSLog(@"UnityAds unityAdsReady:%@",placementId);
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message{
    NSLog(@"UnityAds unityAdsDidError:%@",message);
    
}

- (void)unityAdsDidStart:(NSString *)placementId{
}

- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state{
    if(state == kUnityAdsFinishStateCompleted){
        //reward the player!
        NSLog(@"UnityAds Finish!");
        [self OnAdsCallback:YES];
    }else{
        [self OnAdsCallback:NO];
    }
}

- (void)vungleWillCloseAdWithViewInfo:(VungleViewInfo *)info placementID:(NSString *)placementID
{
    NSLog(@"vungleWillCloseAdWithViewInfo !");
    if(info.completedView){
        [self OnAdsCallback:YES];
    }else{
        [self OnAdsCallback:NO];
    }
    
}
- (void)vungleWillShowAdForPlacementID:(nullable NSString *)placementID
{

}
- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable placementID:(NSString *)placementID
{

}

- (void)OnAdsCallback:(BOOL)success
{
    NSLog(@"PFU-------PLAY ADS CALLBACK ..%d",(int)success);
    NSString* _bSuccess = success?@"1":@"0";
    [self callJs:@"AdsCallback" withCmd:_bSuccess];
}

-(void)callJs:(NSString*) funcNameStr withCmd:(NSString*) cmdStr
{
    string funcName = [funcNameStr UTF8String];
    string param001 = [cmdStr UTF8String];
    std::string jsCallStr = cocos2d::StringUtils::format("cc.find('GameNative').getComponent('GameNative').nativeCall(\"%s\",\"%s\");",funcName.c_str(), param001.c_str());
    NSLog(@"jsCallStr = %s", jsCallStr.c_str());
    //se::ScriptEngine::getInstance()->evalString(jsCallStr.c_str());
    se::ScriptEngine::getInstance()->evalString(jsCallStr.c_str());
}


-(void)showShare
{
    NSLog(@"IOS Show Share");
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = ShareTitle;
    message.description = ShareTitle;
    [message setThumbImage:[UIImage imageNamed:@"share.jpg"]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = ShareUrl;
    
    message.mediaObject = ext;
    
    GetMessageFromWXResp* resp = [[[GetMessageFromWXResp alloc] init] autorelease];
    resp.message = message;
    resp.bText = NO;
    
    [WXApi sendResp:resp];
}

-(void) onReq:(BaseReq*)req
{
    if([req isKindOfClass:[GetMessageFromWXReq class]])
    {
        
    }
    else if([req isKindOfClass:[ShowMessageFromWXReq class]])
    {
       
    }
    else if([req isKindOfClass:[LaunchFromWXReq class]])
    {
        
    }
}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL isSuc = [WXApi handleOpenURL:url delegate:self];
    NSLog(@"url %@ isSuc %d",url,isSuc == YES ? 1 : 0);
    return  isSuc;
}


@end
