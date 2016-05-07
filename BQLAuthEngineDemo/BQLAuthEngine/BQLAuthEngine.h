//
//  BQLAuthEngine.h
//  chuangyou
//
//  Created by 毕青林 on 16/4/30.
//  Copyright © 2016年 毕青林. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WeiboSDK.h"

/**
 *  写在前面：
 *  这是小弟整理的使用原生SDK进行登录、分享操作的工具；不管好与不好，请尊重我的劳动成果，谢谢！
 *  联系方式：QQ931237936 欢迎指正错误或者交流学习(添加请备注IOS开发)
 *  
 
 *  最最开始的工作：当然是你要有申请好的各种秘钥啦（WXAppKey、WXAppSecret、QQAppID、QQAppKey etc）
 
 *  在你的info.plist文件加入以下代码:
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>mqqOpensdkSSoLogin</string>
        <string>mqzone</string>
        <string>sinaweibohd</string>
        <string>sinaweibo</string>
        <string>weibosdk</string>
        <string>weibosdk2.5</string>
        <string>alipayauth</string>
        <string>alipay</string>
        <string>safepay</string>
        <string>mqq</string>
        <string>mqqapi</string>
        <string>mqqopensdkapiV3</string>
        <string>mqqopensdkapiV2</string>
        <string>mqqapiwallet</string>
        <string>mqqwpa</string>
        <string>mqqbrowser</string>
        <string>wtloginmqq2</string>
        <string>weixin</string>
        <string>wechat</string>
    </array>
 
 *  (一)微信SDK接入操作步骤：
 
 *  1：下载官方SDK导入你的工程，直接拖会报错。解决办法：Build Phases -》Link Binary With Libraries 添加 ：
        SystemConfiguration.framework、libz.tbd,libsqlite3.0.tbd,libc++.tbd
 
 *  2：info -》 URL types 添加你的应用秘钥
 
 *  3：在AppDelegate.m文件导入:#import "BQLAuthEngine.h",并重写下面3个方法
 
    - (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
    {
        if ([url.scheme isEqualToString:[NSString stringWithFormat:@"%@",WXAppKey]]) {
        return  [WXApi handleOpenURL:url delegate:[[BQLAuthEngine alloc] init]];
        }
        else if ([url.scheme isEqualToString:[NSString stringWithFormat:@"tencent%@",QQAppID]]) {
            return  [TencentOAuth HandleOpenURL:url];
        }
        else if ([url.scheme isEqualToString:[NSString stringWithFormat:@"wb%@",WeiboAppKey]]) {
            return [WeiboSDK handleOpenURL:url delegate:[[BQLAuthEngine alloc] init]];
        }
        return YES;
    }
 
    - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
    {
        if ([url.scheme isEqualToString:[NSString stringWithFormat:@"%@",WXAppKey]]) {
        return  [WXApi handleOpenURL:url delegate:[[BQLAuthEngine alloc] init]];
        }
        else if ([url.scheme isEqualToString:[NSString stringWithFormat:@"tencent%@",QQAppID]]) {
            return  [TencentOAuth HandleOpenURL:url];
        }
        else if ([url.scheme isEqualToString:[NSString stringWithFormat:@"wb%@",WeiboAppKey]]) {
            return [WeiboSDK handleOpenURL:url delegate:[[BQLAuthEngine alloc] init]];
        }
        return YES;
    }
 
    - (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary*)options {
 
        if ([url.scheme isEqualToString:[NSString stringWithFormat:@"%@",WXAppKey]]) {
            return  [WXApi handleOpenURL:url delegate:[[BQLAuthEngine alloc] init]];
        }
        else if ([url.scheme isEqualToString:[NSString stringWithFormat:@"tencent%@",QQAppID]]) {
            return  [TencentOAuth HandleOpenURL:url];
        }
        else if ([url.scheme isEqualToString:[NSString stringWithFormat:@"wb%@",WeiboAppKey]]) {
            return [WeiboSDK handleOpenURL:url delegate:[[BQLAuthEngine alloc] init]];
        }
        return YES;
    }
 
 *  4：在
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    return之前注册微信应用： [BQLAuthEngine initialAuthEngine]; （copy即可）
 
 *  5：在你需要登陆的方法调用：
 
    BQLAuthEngine *bqlEngine = [[BQLAuthEngine alloc] init];
    [bqlEngine authLoginWeChatWithSuccess:^(id response) {
 
        NSLog(@"success");
    } Failure:^(NSError *error) {
 
        NSLog(@"failure");
    }];
    response 返回的就是你的微信信息包括：headimgurl、nickname、sex etc
 
 *  6：其他参考方法说明，我注释写的还算清楚
 *
 *
 *
 *
 *
 *
 *
 *  这是本人空余时间整理的，难免有瑕疵，后面我会完善功能，如果demo对你有所帮助，给我个星星吧~~~感谢支持~！
 *  若仍有错请联系我
 */



/*
 测试授权秘钥、key
*/
 
//微博参数
#define WeiboAppKey @"你的微博AppKey"
#define WeiboAppSecret @"你的微博AppSecret"
#define WeiboRedirectURI @"跳转地址"

//微信参数
#define WXAppKey @"你的微信AppKey"
#define WXAppSecret @"你的微信AppSecret"

//QQ参数
#define QQAppID @"你的QQAppID"
#define QQAppKey @"你的AppKey"
#define QQRedirectURI @"跳转地址"







// 自定义NSError
#define CustomErrorDomain @"BQLAuthFailureDomain"

/**
 *  回调闭包
 *
 *  @param error    错误信息
 *  @param response 成功回调
 */
typedef void(^BQLAuthFailureBlock)(NSError *error);
typedef void(^BQLAuthSuccessBlock)(id response);

// 分享类型
typedef NS_ENUM(NSInteger, ShareToWXScene)
{
    ShareToWXSceneSession = 0,  /**< 聊天界面    */
    ShareToWXSceneTimeline,     /**< 朋友圈      */
    ShareToWXSceneFavorite      /**< 收藏       */
};

// 授权错误码
typedef NS_ENUM(NSInteger, AuthErrorCode)
{
    AuthErrorCodeSuccess    = 0,    /**< 成功    */
    AuthErrorCodeCommon     = -1,   /**< 普通错误类型    */
    AuthErrorCodeUserCancel = -2,   /**< 用户点击取消并返回    */
    AuthErrorSentFail       = -3,   /**< 发送失败    */
    AuthErrorAuthDeny       = -4,   /**< 授权失败    */
    AuthErrorUnsupport      = -5    /**< 微信不支持    */
};











 
#pragma 遵守微信SDK代理
@interface BQLAuthEngine : NSObject <WXApiDelegate,TencentSessionDelegate,WeiboSDKDelegate,QQApiInterfaceDelegate>

@property (nonatomic, strong) BQLAuthSuccessBlock successBlock;
@property (nonatomic, strong) BQLAuthFailureBlock failureBlock;

/**
 *  初始化工具类单例
 */
+ (instancetype)sharedSingletonTool;

/**
 *  注册授权(微信、微博)
 */
+ (void)initialAuthEngine;

/**
 *  检测微信是否已安装
 */
+ (BOOL)isWXAppInstalled;

/**
 *  检测QQ是否已安装
 */
+ (BOOL)isQQInstalled;

/**
 *  检测微博是否已安装
 */
+ (BOOL)isWeiboAppInstalled;

/**
 *  检查用户是否可以通过微博客户端进行分享
 */
+ (BOOL)isCanShareInWeiboAPP;

/*
 -----------------------------------
 微信SDK接入（分享、登陆）🔽
 -----------------------------------
*/

/**
 *  授权微信登陆
 *
 *  @param success  成功回调
 *  @param failure  失败回调
 */
- (void)authLoginWeChatWithSuccess:(BQLAuthSuccessBlock )success Failure:(BQLAuthFailureBlock )failure;

/**
 *  授权微信文本分享
 *
 *  @param text     分享文本
 *  @param scene    分享类型(会话、朋友圈、收藏)
 *  @param success  成功回调
 *  @param failure  失败回调
 */
- (void)authShareToWeChatWithText:(NSString *)text Scene:(ShareToWXScene )scene Success:(BQLAuthSuccessBlock )success Failure:(BQLAuthFailureBlock )failure;

/**
 *  授权微信图片分享
 *
 *  @param image    分享图片
 *  @param scene    分享类型(会话、朋友圈、收藏)
 *  @param success  成功回调
 *  @param failure  失败回调
 */
- (void)authShareToWeChatWithImage:(UIImage *)image Scene:(ShareToWXScene )scene Success:(BQLAuthSuccessBlock )success Failure:(BQLAuthFailureBlock )failure;

/**
 *  授权微信音乐分享
 *
 *  @param musicTitle   音乐标题（音乐名）
 *  @param description  音乐描述（音乐演唱者、简介etc）
 *  @param thumbImage   音乐缩略图
 *  @param musicUrl     音乐地址
 *  @param musicDataUrl 音乐数据地址(不写不影响)
 *  @param scene        分享类型(会话、朋友圈、收藏)
 *  @param success      成功回调
 *  @param failure      失败回调
 */
- (void)authShareToWeChatWithMusic:(NSString *)musicTitle Description:(NSString *)description ThumbImage:(UIImage *)thumbImage Url:(NSString *)musicUrl MusicDataUrl:(NSString *)musicDataUrl Scene:(ShareToWXScene )scene Success:(BQLAuthSuccessBlock )success Failure:(BQLAuthFailureBlock )failure;

/**
 *  授权微信链接分享
 *
 *  @param linkTitle    链接标题
 *  @param description  链接描述
 *  @param thumbImage   链接缩略图
 *  @param linkUrl      链接地址
 *  @param scene        分享类型(会话、朋友圈、收藏)
 *  @param success      成功回调
 *  @param failure      失败回调
 */
- (void)authShareToWeChatWithLink:(NSString *)linkTitle Description:(NSString *)description ThumbImage:(UIImage *)thumbImage Url:(NSString *)linkUrl Scene:(ShareToWXScene )scene Success:(BQLAuthSuccessBlock )success Failure:(BQLAuthFailureBlock )failure;

/**
 *  授权微信视频分享
 *
 *  @param videoTitle   视频标题
 *  @param description  视频描述
 *  @param thumbImage   视频缩略图
 *  @param videoUrl     视频地址
 *  @param scene        分享类型(会话、朋友圈、收藏)
 *  @param success      成功回调
 *  @param failure      失败回调
 */
- (void)authShareToWeChatWithVideo:(NSString *)videoTitle Description:(NSString *)description ThumbImage:(UIImage *)thumbImage Url:(NSString *)videoUrl Scene:(ShareToWXScene )scene Success:(BQLAuthSuccessBlock )success Failure:(BQLAuthFailureBlock )failure;

/*
 -----------------------------------
 微信SDK接入（分享、登陆）🔼
 -----------------------------------
 */



/*
 -----------------------------------
 QQSDK接入（分享、登陆）🔽
 -----------------------------------
 */

/**
 *  授权QQ登陆
 *
 *  @param success  成功回调
 *  @param failure  失败回调
 */
- (void)authLoginQQWithSuccess:(BQLAuthSuccessBlock )success Failure:(BQLAuthFailureBlock )failure;

/*
 分享消息到QQ的接口，可将新闻、图片、文字、应用等分享给QQ好友、群和讨论组。Tencent类的shareToQQ函数可直接调用，不用用户授权（使用手机QQ当前的登录态）。调用将打开分享的界面，用户选择好友、群或讨论组之后，点击确定即可完成分享，并进入与该好友进行对话的窗口。
*/

/**
 *  分享文本信息到QQ好友
 *
 *  @param text         文本信息
 *  @param success      成功回调
 *  @param failure      失败回调
 */
- (void)authShareToQQWithText:(NSString *)text Success:(BQLAuthSuccessBlock )success Failure:(BQLAuthFailureBlock )failure;

#warning 下面的QQ分享带shareToZone参数说明是可以分享到空间的，否则只支持分享给好友
/**
 *  分享图片信息到QQ好友
 *
 *  @param image        图片
 *  @param success      成功回调
 *  @param failure      失败回调
 */
- (void)authShareToQQWithImage:(UIImage *)image Success:(BQLAuthSuccessBlock )success Failure:(BQLAuthFailureBlock )failure;

/**
 *  分享链接信息到QQ好友
 *
 *  @param link         链接地址
 *  @param shareToZone  是否分享到空间(YES:分享到空间 NO:分享给好友)
 *  @param success      成功回调
 *  @param failure      失败回调
 */
- (void)authShareToQQWithLink:(NSString *)link ShareToZone:(BOOL )shareToZone Success:(BQLAuthSuccessBlock )success Failure:(BQLAuthFailureBlock )failure;


/*
 -----------------------------------
 QQSDK接入（分享、登陆）🔼
 -----------------------------------
 */



/*
 -----------------------------------
 微博SDK接入（分享、登陆）🔽
 -----------------------------------
 */

#warning 微博的比较坑，要求你的bundle identifier与申请的一致，我写Demo用的就是不一致，授权是失败的，不过授权方法是没错的，你们测试的时候注意保持一致，若有问题联系我

/**
 *  授权微博登陆
 *
 *  @param success  成功回调
 *  @param failure  失败回调
 */
- (void)authLoginWeiBoWithSuccess:(BQLAuthSuccessBlock )success Failure:(BQLAuthFailureBlock )failure;




/*
 -----------------------------------
 微博SDK接入（分享、登陆）🔼
 -----------------------------------
 */




@end
























