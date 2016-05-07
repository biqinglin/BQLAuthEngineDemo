//
//  BQLAuthEngine.m
//  chuangyou
//
//  Created by 毕青林 on 16/4/30.
//  Copyright © 2016年 毕青林. All rights reserved.
//

#import "BQLAuthEngine.h"

static BQLAuthEngine *singleten;


@interface BQLAuthEngine ()

@property (nonatomic, strong) TencentOAuth *tencentOAuth;

@end

@implementation BQLAuthEngine

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    @synchronized(self) {
        if(singleten == nil) {
            singleten = [super allocWithZone:zone];
        }
        if(!singleten.tencentOAuth) {
            
            singleten.tencentOAuth = [[TencentOAuth alloc] initWithAppId:QQAppID andDelegate:singleten];
            singleten.tencentOAuth.redirectURI = QQRedirectURI;
        }
    }
    return singleten;
}

+ (instancetype)sharedSingletonTool {
    
    @synchronized(self) {
        singleten = [[self alloc] init];
    }
    return singleten;
}

+ (void)initialAuthEngine {
    
    // 微信注册授权
    [WXApi registerApp:WXAppKey];
    
    // 微博注册授权(开启调试模式，可查看打印日志)
#ifdef DEBUG
    [WeiboSDK enableDebugMode:YES];
#else
    [WeiboSDK enableDebugMode:NO];
#endif
    [WeiboSDK registerApp:WeiboAppKey];
}

+ (BOOL)isWXAppInstalled {
    
    return [WXApi isWXAppInstalled];
}

+ (BOOL)isQQInstalled {
    
    return [QQApiInterface isQQInstalled];
}

+ (BOOL)isWeiboAppInstalled {
    
    return [WeiboSDK isWeiboAppInstalled];
}

+ (BOOL)isCanShareInWeiboAPP {
    
    return [WeiboSDK isCanShareInWeiboAPP];
}


/*----------------------------------------wechat-------------------------------------------*/

/*
 这个代理可以不写任何东西，因为是微信向我发送消息，一般不存在这个情况
 */
-(void)onReq:(BaseReq *)req {
    
    
}

/*
 在这里接收微信返回的状态（成功或者失败）
 以此进行相应的回应操作如：登陆成功进入APP、提示用户分享成功或者失败etc
 
 当然你可以不做任何操作不会报错（用户体验不敢想象- - ~！）
 */
-(void)onResp:(BaseResp *)resp {
    
    // 回应有2种：1：授权登陆回应 2：分享回应
    if ([resp isKindOfClass:[SendAuthResp class]]) { // 授权登陆回应
        
        [self completeAuth:(SendAuthResp*)resp];
    }
    else if ([resp isKindOfClass:[SendMessageToWXResp class]]) { // 分享回应
        
        [self completeShare:(SendMessageToWXResp *)resp];
    }
    else {
        // 当做失败处理
    }
}

// 授权登陆操作：获取code、access_token、openid、userinfo
- (void)completeAuth:(SendAuthResp *)resp {
    
    // 获取code
    NSString *code = resp.code;
    
    // 拼接获取token url
    NSURL *getTokenUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",WXAppKey,WXAppSecret,code]];
    
    // 获取access_token
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    NSURLSessionDataTask *access_tokenTask = [session dataTaskWithURL:getTokenUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(!error) {
            
            // 响应状态代码为200，代表请求数据成功，判断成功后我们再进行数据解析
            NSHTTPURLResponse *access_tokenHttpResp = (NSHTTPURLResponse*) response;
            if (access_tokenHttpResp.statusCode == 200) {
                
                NSError *access_tokenError;
                //解析NSData数据
                NSDictionary *access_tokenJSON =
                [NSJSONSerialization JSONObjectWithData:data
                                                options:NSJSONReadingAllowFragments
                                                  error:&access_tokenError];
                if (!access_tokenError) {
                    
                    // 记录access_token 和 openid
                    NSString *access_token = access_tokenJSON[@"access_token"];
                    NSString *openid = access_tokenJSON[@"openid"];
                    NSURL *getUserInfoUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",access_token,openid]];
                    
                    NSURLSessionDataTask *userInfoTask = [session dataTaskWithURL:getUserInfoUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        
                        NSDictionary *userInfoJSON =
                        [NSJSONSerialization JSONObjectWithData:data
                                                        options:NSJSONReadingAllowFragments
                                                          error:nil];
                        
                        if(self.successBlock) self.successBlock(userInfoJSON);
                        
                    }];
                    [userInfoTask resume];
                }
                else {
                    
                    if(self.failureBlock) self.failureBlock(error);
                }
            }
            else {
                
                if(self.failureBlock) self.failureBlock(error);
            }
        }
        else {
            
            if(self.failureBlock) self.failureBlock(error);
        }
    }];
    [access_tokenTask resume];
}

// 完成分享操作(分享成功、分享失败)
- (void)completeShare:(SendMessageToWXResp *)resp {
    
    if (resp.errCode == AuthErrorCodeSuccess) {
        
        self.successBlock(@(resp.errCode));
    }
    else {
        
        NSError *error = [NSError errorWithDomain:CustomErrorDomain code:resp.errCode userInfo:@{NSLocalizedDescriptionKey:@"授权失败,详情参考授权错误码"}];
        self.failureBlock(error);
    }
}



- (void)authLoginWeChatWithSuccess:(BQLAuthSuccessBlock )success Failure:(BQLAuthFailureBlock )failure {
    
    self.successBlock = success;
    self.failureBlock = failure;
    
    //构造SendAuthReq结构体
    SendAuthReq *req =[[SendAuthReq alloc ] init];
    // 这个字符串参考官方注释,有以下几个可选:@"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact"
    req.scope = @"snsapi_userinfo" ;
    // 这个字符串你最好使用加密算法得到,这里我是乱写的,功能无影响
    req.state = @"qwertyuioplkjhgfdsazxcvbnm" ;
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
}

- (void)authShareToWeChatWithText:(NSString *)text Scene:(ShareToWXScene )scene Success:(BQLAuthSuccessBlock )success Failure:(BQLAuthFailureBlock )failure {
    
    self.successBlock = success;
    self.failureBlock = failure;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.text = text;
    req.bText = YES;
    req.scene = scene;
    [WXApi sendReq:req];
}

- (void)authShareToWeChatWithImage:(UIImage *)image Scene:(ShareToWXScene )scene Success:(BQLAuthSuccessBlock )success Failure:(BQLAuthFailureBlock )failure {
    
    self.successBlock = success;
    self.failureBlock = failure;
    
#warning 这里分享的图切记要满足微信要求的大小要求！！！否则[WXApi sendReq:req]会一直返回NO，也就是不会跳转至微信
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:image];
    WXImageObject *imageObject = [WXImageObject object];
    /* 
    // 这里你也可以传filePath，或者imageObject.imageUrl 三种方式看你需求选择即可
     
    1:  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"shareTest" ofType:@"png"];
        imageObject.imageData = [NSData dataWithContentsOfFile:filePath];
     
    2:  imageObject.imageUrl = @"xxx";
    */
    imageObject.imageData = UIImagePNGRepresentation(image);
    //imageObject.imageData = [self getSuitableImageData:image];
    
    message.mediaObject = imageObject;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.message = message;
    req.bText = NO;
    req.scene = scene;
    [WXApi sendReq:req];
}

- (NSData *)getSuitableImageData:(UIImage *)image {
    
    NSData *imageData;
    UIImage *aImage = image;
    do {
        imageData = UIImageJPEGRepresentation(aImage, 0.1);
        aImage = [UIImage imageWithData:imageData];
    } while (imageData.length>5*1024*1024);
    return imageData;
}

- (void)authShareToWeChatWithMusic:(NSString *)musicTitle Description:(NSString *)description ThumbImage:(UIImage *)thumbImage Url:(NSString *)musicUrl MusicDataUrl:(NSString *)musicDataUrl Scene:(ShareToWXScene )scene Success:(BQLAuthSuccessBlock )success Failure:(BQLAuthFailureBlock )failure {
    
    self.successBlock = success;
    self.failureBlock = failure;
    
    WXMediaMessage *message = [WXMediaMessage message];
    // 音乐标题
    message.title = musicTitle;
    // 音乐描述，你写个作者就行了一般，太长的不好看
    message.description = description;
    // 音乐缩略图：这里切记缩略图大小！！！同分享图片一样，一定要满足微信官方要求大小，否则不跳转(你也可以不传啦!)
    [message setThumbImage:thumbImage];
    WXMusicObject *musicObject = [WXMusicObject object];
    // 音乐url
    musicObject.musicUrl = musicUrl;
    // 音乐数据url
    if (musicDataUrl) musicObject.musicDataUrl = musicDataUrl;
    message.mediaObject = musicObject;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    [WXApi sendReq:req];
}

- (void)authShareToWeChatWithLink:(NSString *)linkTitle Description:(NSString *)description ThumbImage:(UIImage *)thumbImage Url:(NSString *)linkUrl Scene:(ShareToWXScene )scene Success:(BQLAuthSuccessBlock )success Failure:(BQLAuthFailureBlock )failure {
    
    self.successBlock = success;
    self.failureBlock = failure;
    
    // 注释就不写了，参考分享音乐类推...
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = linkTitle;
    message.description = description;
    if (thumbImage) [message setThumbImage:thumbImage];
    
    WXWebpageObject *linkObject = [WXWebpageObject object];
    linkObject.webpageUrl = linkUrl;
    message.mediaObject = linkObject;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    [WXApi sendReq:req];
}

- (void)authShareToWeChatWithVideo:(NSString *)videoTitle Description:(NSString *)description ThumbImage:(UIImage *)thumbImage Url:(NSString *)videoUrl Scene:(ShareToWXScene )scene Success:(BQLAuthSuccessBlock )success Failure:(BQLAuthFailureBlock )failure {
    
    self.successBlock = success;
    self.failureBlock = failure;
    
    // 注释就不写了，参考分享音乐类推...
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = videoTitle;
    message.description = description;
    if (thumbImage) [message setThumbImage:thumbImage];
    
    WXVideoObject *videoObject = [WXVideoObject object];
    videoObject.videoUrl = videoUrl;
    message.mediaObject = videoObject;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    [WXApi sendReq:req];
}

/*---------------------------------------qq------------------------------------------*/

/**
 处理来至QQ的请求
 */
//- (void)onReq:(QQBaseReq *)req {
//    
//    
//}
//
/**
 处理来至QQ的响应
 */
//- (void)onResp:(QQBaseResp *)resp {
//    
//    NSLog(@"aa");
//}

-(void)authLoginQQWithSuccess:(BQLAuthSuccessBlock)success Failure:(BQLAuthFailureBlock)failure {
    
    self.successBlock = success;
    self.failureBlock = failure;

    // 这个数据和微信的类似，可选类型（至少得有用户基本信息）
    NSArray *authorize = @[@"get_user_info", @"get_simple_userinfo", @"add_t"];
    [_tencentOAuth authorize:authorize];
}

#pragma mark - tencentDelegate
- (void)tencentDidLogin{
    
    if (self.tencentOAuth.accessToken && 0 != [self.tencentOAuth.accessToken length]) {

        //  qq_token、qq_openid需要保存起来
        NSString *qq_token = _tencentOAuth.accessToken;
        NSString *qq_openid = _tencentOAuth.openId;
        BOOL getInfoSuccess = [self.tencentOAuth getUserInfo];
        if(getInfoSuccess) {
            
            //登录成功
        }
        else {
            
            //登录失败
            NSError *error = [NSError errorWithDomain:CustomErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey:@"授权失败,详情参考授权错误码"}];
            if (self.failureBlock) self.failureBlock(error);
        }
        
    } else {
        
        //登录失败
        NSError *error = [NSError errorWithDomain:CustomErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey:@"授权失败"}];
        if (self.failureBlock) self.failureBlock(error);
    }
}

// 登录失败(其他因素)
- (void)tencentDidNotLogin:(BOOL)cancelled{
    
    if (cancelled) {
        
        //用户取消登录
        NSError *error = [NSError errorWithDomain:CustomErrorDomain code:-2 userInfo:@{NSLocalizedDescriptionKey:@"你取消了登陆"}];
        if (self.failureBlock) self.failureBlock(error);
        
    }else {
        
        //登录失败
        NSError *error = [NSError errorWithDomain:CustomErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey:@"授权失败"}];
        self.failureBlock(error);
    }
}

// 登录失败(没有网络)
- (void)tencentDidNotNetWork{
    
    //登录失败
    NSError *error = [NSError errorWithDomain:CustomErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey:@"没有网络,授权失败"}];
    if (self.failureBlock) self.failureBlock(error);
}

// 获取QQ信息
- (void)getUserInfoResponse:(APIResponse *)response{
    
    NSDictionary *userInfo = response.jsonResponse;
    if(self.successBlock) self.successBlock(userInfo);
}

/**
 *  QQ分享回调处理
 *
 *  @param code 返回码（详见：QQApiSendResultCode）
 */
- (void)handleSendResult:(QQApiSendResultCode )code {
    
    if(code == EQQAPISENDSUCESS) {
        
        self.successBlock(@(code));
    }
    else {
        
        NSError *error = [NSError errorWithDomain:CustomErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey:@"授权失败,详情参考QQ授权错误码"}];
        self.failureBlock(error);
    }
}


- (void)authShareToQQWithText:(NSString *)text Success:(BQLAuthSuccessBlock )success Failure:(BQLAuthFailureBlock )failure {
    
    self.successBlock = success;
    self.failureBlock = failure;
    
    QQApiTextObject *textObject = [QQApiTextObject objectWithText:text];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:textObject];
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
}

- (void)authShareToQQWithImage:(UIImage *)image Success:(BQLAuthSuccessBlock )success Failure:(BQLAuthFailureBlock )failure {
    
    self.successBlock = success;
    self.failureBlock = failure;
    
    QQApiImageObject *imageObject = [QQApiImageObject objectWithData:UIImagePNGRepresentation(image) previewImageData:UIImagePNGRepresentation(image) title:@"图片" description:@"图片"];
    // 如果是多图用下面的方法:
    //QQApiImageObject *img = [QQApiImageObject objectWithData:<#(NSData *)#> previewImageData:<#(NSData *)#> title:<#(NSString *)#> description:<#(NSString *)#> imageDataArray:<#(NSArray *)#>]
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imageObject];
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
}

- (void)authShareToQQWithLink:(NSString *)link ShareToZone:(BOOL )shareToZone Success:(BQLAuthSuccessBlock )success Failure:(BQLAuthFailureBlock )failure {
    
    self.successBlock = success;
    self.failureBlock = failure;
    
    //分享图预览图URL地址
    NSString *previewImageUrl = @"preImageUrl.png";
    QQApiNewsObject *newsObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:link] title:@"标题" description:@"简介" previewImageURL:[NSURL URLWithString:previewImageUrl]];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObject];
    QQApiSendResultCode sent;
    if(shareToZone) {
        //将内容分享到qzone
        sent = [QQApiInterface SendReqToQZone:req];
    }
    else {
        //将内容分享到qq
        sent = [QQApiInterface sendReq:req];
    }
    [self handleSendResult:sent];
}

/*-----------------------------------------weibo----------------------------------------*/

#pragma weibo delegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    
    if ([response isKindOfClass:[WBAuthorizeResponse class]]) {

        // 记录accessToken、userID
        NSString *accessToken = [(WBAuthorizeResponse *)response accessToken];
        NSString *userID = [(WBAuthorizeResponse *)response userID];
    }
    if ([response isKindOfClass:[WBSendMessageToWeiboResponse class]]) {
        if (response.statusCode == 0) {
            
            NSLog(@"分享成功");
        }else {
            
            NSLog(@"分享失败");
        }
    }
}

- (void)authLoginWeiBoWithSuccess:(BQLAuthSuccessBlock )success Failure:(BQLAuthFailureBlock )failure {
    
    self.successBlock = success;
    self.failureBlock = failure;
    
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = WeiboRedirectURI;
    request.scope = @"all";
    [WeiboSDK sendRequest:request];
}

@end
