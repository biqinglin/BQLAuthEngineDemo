# BQLAuthEngineDemo
利用QQ、微信的原生SDK实现的三方登陆、分享功能。包括：QQ登陆、微信登陆、微信文本、图片、链接等分享到会话、朋友圈、收藏；QQ文本、图片分享等实用功能

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
