//
//  ViewController.m
//  BQLAuthEngineDemo
//
//  Created by 毕青林 on 16/5/1.
//  Copyright © 2016年 毕青林. All rights reserved.
//

#import "ViewController.h"
#import "BQLAuthEngine.h"

@interface ViewController ()
{
    BQLAuthEngine *_bqlAuthEngine;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _bqlAuthEngine = [[BQLAuthEngine alloc] init];
}

/**
 *
 *  BQLAuthEngine 提供了
 *  [BQLAuthEngine isQQInstalled]、
 *  [BQLAuthEngine isWXAppInstalled]、
 *  [BQLAuthEngine isWeiboAppInstalled]
 *  判断APP是否能够使用三方登陆，此Demo就直接展示了登陆、分享功能，望新手开发注意！（大神略过）
 *
 *
 *  下面的例子自己调试看打印结果，我没有做UI展示
 *
 */

// 微信登陆
- (IBAction)weChatLogin:(id)sender {
    
    [_bqlAuthEngine authLoginWeChatWithSuccess:^(id response) {
        
        NSLog(@"success:%@",response);
    } Failure:^(NSError *error) {
        
        NSLog(@"failure:%@",error);
    }];
}

// 微信文本分享
- (IBAction)weChatShareWithTxt:(id)sender {
    
    [_bqlAuthEngine authShareToWeChatWithText:@"这是一个微信分享测试文本" Scene:ShareToWXSceneSession Success:^(id response) {
        
        // 成功授权、在这里你可以提示用户已分享成功、并进行下面的操作
        NSLog(@"success:%@",response);
    } Failure:^(NSError *error) {
        
        // 错误返回授权错误码，请自行对照错误码查看错误原因
        NSLog(@"failure:%@",error);
    }];
}

// 微信图片分享
- (IBAction)weChatShareWithImg:(id)sender {
    
    [_bqlAuthEngine authShareToWeChatWithImage:[UIImage imageNamed:@"mashimaro.png"] Scene:ShareToWXSceneSession Success:^(id response) {
        
        // 成功授权、在这里你可以提示用户已分享成功、并进行下面的操作
        NSLog(@"success:%@",response);
    } Failure:^(NSError *error) {
        
        // 错误返回授权错误码，请自行对照错误码查看错误原因
        NSLog(@"failure:%@",error);
    }];
}

// 微信音乐分享
- (IBAction)weChatShareWithMusic:(id)sender {
    
    NSString *url = @"http://y.qq.com/i/song.html#p=7B22736F6E675F4E616D65223A22E4B880E697A0E68980E69C89222C22736F6E675F5761704C69766555524C223A22687474703A2F2F74736D7573696334382E74632E71712E636F6D2F586B30305156342F4141414130414141414E5430577532394D7A59344D7A63774D4C6735586A4C517747335A50676F47443864704151526643473444442F4E653765776B617A733D2F31303130333334372E6D34613F7569643D3233343734363930373526616D703B63743D3026616D703B636869643D30222C22736F6E675F5769666955524C223A22687474703A2F2F73747265616D31342E71716D757369632E71712E636F6D2F33303130333334372E6D7033222C226E657454797065223A2277696669222C22736F6E675F416C62756D223A22E4B880E697A0E68980E69C89222C22736F6E675F4944223A3130333334372C22736F6E675F54797065223A312C22736F6E675F53696E676572223A22E5B494E581A5222C22736F6E675F576170446F776E4C6F616455524C223A22687474703A2F2F74736D757369633132382E74632E71712E636F6D2F586C464E4D313574414141416A41414141477A4C36445039536A457A525467304E7A38774E446E752B6473483833344843756B5041576B6D48316C4A434E626F4D34394E4E7A754450444A647A7A45304F513D3D2F33303130333334372E6D70333F7569643D3233343734363930373526616D703B63743D3026616D703B636869643D3026616D703B73747265616D5F706F733D35227D";
    UIImage *thumb = [UIImage imageNamed:@"wait.png"];
    [_bqlAuthEngine authShareToWeChatWithMusic:@"一无所有" Description:@"崔健" ThumbImage:thumb Url:url MusicDataUrl:nil Scene:ShareToWXSceneSession Success:^(id response) {
        
        // 成功授权、在这里你可以提示用户已分享成功、并进行下面的操作
        NSLog(@"success:%@",response);
        
    } Failure:^(NSError *error) {
        
        // 错误返回授权错误码，请自行对照错误码查看错误原因
        NSLog(@"failure:%@",error);
    }];

}

// 微信链接分享
- (IBAction)weChatShareWithLink:(id)sender {
    
    UIImage *thumb = [UIImage imageNamed:@"wait.png"];
    [_bqlAuthEngine authShareToWeChatWithLink:@"专访张小龙：产品之上的世界观" Description:@"微信的平台化发展方向是否真的会让这个原本简洁的产品变得臃肿？在国际化发展方向上，微信面临的问题真的是文化差异壁垒吗？腾讯高级副总裁、微信产品负责人张小龙给出了自己的回复。" ThumbImage:thumb Url:@"http://tech.qq.com/zt2012/tmtdecode/252.htm" Scene:ShareToWXSceneSession Success:^(id response) {
        
        // 成功授权、在这里你可以提示用户已分享成功、并进行下面的操作
        NSLog(@"success:%@",response);
        
    } Failure:^(NSError *error) {
        
        // 错误返回授权错误码，请自行对照错误码查看错误原因
        NSLog(@"failure:%@",error);
    }];

}

// 微信视频分享
- (IBAction)weChatShareWithVideo:(id)sender {
    
    // 视频地址你们自己找吧，我这个是应用介绍的，不知道为毛分享到微信显示被举报！尼玛- -！
    UIImage *thumb = [UIImage imageNamed:@"wait.png"];
    [_bqlAuthEngine authShareToWeChatWithVideo:@"应用介绍" Description:@"本周应用介绍" ThumbImage:thumb Url:@"http://krtv.qiniudn.com/150522nextapp" Scene:ShareToWXSceneSession Success:^(id response) {
        
        // 成功授权、在这里你可以提示用户已分享成功、并进行下面的操作
        NSLog(@"success:%@",response);
        
    } Failure:^(NSError *error) {
        
        // 错误返回授权错误码，请自行对照错误码查看错误原因
        NSLog(@"failure:%@",error);
    }];

}


// QQ登陆
- (IBAction)qqLogin:(id)sender {
    
    [_bqlAuthEngine authLoginQQWithSuccess:^(id response) {
        
        NSLog(@"success:%@",response);
    } Failure:^(NSError *error) {
        
        NSLog(@"failure:%@",error);
    }];
}

// QQ文本分享
- (IBAction)qqShareWithTxt:(id)sender {
    
    [_bqlAuthEngine authShareToQQWithText:@"这是我要分享给QQ好友的消息" Success:^(id response) {
        
        // 成功授权、在这里你可以提示用户已分享成功、并进行下面的操作
        NSLog(@"success");
        
    } Failure:^(NSError *error) {
        
        // 错误返回授权错误码，请自行对照错误码查看错误原因
        NSLog(@"failure:%@",error);
    }];

}

// QQ图片分享
- (IBAction)qqShareWithImg:(id)sender {
    
    [_bqlAuthEngine authShareToQQWithImage:[UIImage imageNamed:@"shareTest.png"] Success:^(id response) {
        
        // 成功授权、在这里你可以提示用户已分享成功、并进行下面的操作
        NSLog(@"success");
        
    } Failure:^(NSError *error) {
        
        // 错误返回授权错误码，请自行对照错误码查看错误原因
        NSLog(@"failure : %@",error.localizedDescription);
    }];

}

// QQ链接分享
- (IBAction)qqShareWithLink:(id)sender {
    
    [_bqlAuthEngine authShareToQQWithLink:@"http://www.cocoachina.com" ShareToZone:NO Success:^(id response) {
        
        // 成功授权、在这里你可以提示用户已分享成功、并进行下面的操作
        NSLog(@"success");
        
    } Failure:^(NSError *error) {
        
        // 错误返回授权错误码，请自行对照错误码查看错误原因
        NSLog(@"failure : %@",error.localizedDescription);
    }];
}


// 微博登陆
- (IBAction)weiBoLogin:(id)sender {
}

















- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
