//
//  BellScene.m
//  NimaMonkey
//
//  Created by Ricky on 1/9/13.
//  Copyright 2013 meetgame. All rights reserved.
//

#import "BellScene.h"
#import "GameData.h"
#import "Constants.h"
#import "SceneManager.h"
#import "SimpleAudioEngine.h"


@implementation BellScene

+(CCScene*)scene{
    
    CCScene *scene = [CCScene node];
    BellScene *layer = [BellScene node];
    [scene addChild:layer];
    return scene;
}

#pragma mark 添加基本视觉元素

//返回游戏开始界面
-(void)backToStart{
    [[SimpleAudioEngine sharedEngine]playEffect:@"button2.mp3"];
    
    [SceneManager goChapterSelect];
    
}
//添加返回按钮
-(void)addBackItem{
    CGSize screenSize =[CCDirector sharedDirector].winSize;
    
    CCMenuItemImage* backButton = [CCMenuItemImage itemWithNormalImage:@"button_back.png" selectedImage:nil target:self selector:@selector(backToStart)];
    
    CCMenu *menuButton = [CCMenu menuWithItems:backButton,  nil];
    menuButton.position = ccp(screenSize.width*0.85,screenSize.height*0.85);
    [self addChild:menuButton z:1];
    
}

//添加背景图片
-(void)addBackground{
    
    
  CGSize  size = [CCDirector sharedDirector].winSize;
    
    if(deviceType == kDeviceTypeNotIphone5){
      CCSprite *  sceneBg = [CCSprite spriteWithFile:@"bg_cartoonpiano.png"];
        sceneBg.position = ccp(size.width/2,size.height/2);
        [self addChild:sceneBg z:-1];
    }else if(deviceType == kDeviceTypeIphone5OrNewTouch){
        CCSprite *  sceneBg= [CCSprite spriteWithFile:@"bg_cartoonpiano-iphone5.png"];
        sceneBg.position = ccp(size.width/2,size.height/2);
        [self addChild:sceneBg z:-1];
    }
    
}

//添加说明
-(void)addTips{
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
   CCLabelTTF *tips = [CCLabelTTF labelWithString:@"Touch or shake the bell" fontName:@"ChalkboardSE-Bold" fontSize:18];

    tips.position =ccp(screenSize.width/2,screenSize.height*0.85);
    tips.color = ccc3(16,174,231);
    
    [self addChild:tips z:1];
}


//添加摇铃
-(void)addBell{
      CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    bell = [CCSprite spriteWithFile:@"ringbell.png"];
    
    bell.position = ccp(screenSize.width/2,screenSize.height*0.4);
    [self addChild:bell z:2];
    
}
//添加摇铃的触摸相应区域
-(void)addBellTouchArea{
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    CCSprite *touchAreaSprite = [CCSprite spriteWithFile:@"touchArea.png"];
    
    CCMenuItemSprite *touchItem = [CCMenuItemSprite itemWithNormalSprite:touchAreaSprite selectedSprite:nil target:self selector:@selector(bellTouched)];
    
    touchItem.position =  ccp(screenSize.width/2,screenSize.height*0.4);
    CCMenu *menu = [CCMenu menuWithItems:touchItem, nil];
    menu.position = ccp(0,0);
    [self addChild:menu z:2];

    
    
}

//
-(void)bellTouched{
    
    [self bellRingByTouch];
    [self bellShake];
}

//发出声音

-(void)bellRingByTouch{
    
    [[SimpleAudioEngine sharedEngine]playEffect:@"belltouched.wav"];
}

//发出声音

-(void)bellRingByShake{
    
    [[SimpleAudioEngine sharedEngine]playEffect:@"bell.wav"];
}

//铃铛摇摆
-(void)bellShake{
    
    id action1 = [CCRotateTo actionWithDuration:0.2 angle:60];
    
    
    id action2 = [CCRotateTo actionWithDuration:0.2 angle:-60];
    id action3 = [CCRotateTo actionWithDuration:0.2 angle:0];
    CCSequence *sequence = [CCSequence actions:action1,action2, action3,nil];
    [bell runAction:sequence];
    
    
    CGSize size = [CCDirector sharedDirector].winSize;
    [self showParticleEffect:ccp(size.width/2,size.height/2)];
}

#pragma mark 粒子效果

-(void)showParticleEffect:(CGPoint)particlePosition{
    
    NSString *textureName;
    //    int randomIndex = arc4random()%3;
    //    switch (randomIndex) {
    //        case 0:
    //            textureName = @"sign1.png";
    //            break;
    //        case 1:
    //            textureName = @"sign2.png";
    //            break;
    //        case 2:
    //            textureName = @"sign3.png";
    //            break;
    //
    //        default:
    //            break;
    //    }
    textureName = @"ringbell.png";
    
    CCParticleSystemQuad *particle = [CCParticleSystemQuad particleWithFile:@"particle.plist"];
    
    
    particle.position = particlePosition;
    particle.autoRemoveOnFinish = YES;
    particle.duration = 1;
    
    
    particle.texture = [[CCTextureCache sharedTextureCache]addImage:textureName];
    
    [self addChild:particle z:5];
    
    
    
}


#pragma mark 检测摇晃事件并进行处理

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
    
    float THRESHOLD = 1; //该数值将决定摇晃所需的力度
    
    
    if (acceleration.x > THRESHOLD || acceleration.x < -THRESHOLD ||
        acceleration.y > THRESHOLD || acceleration.y < -THRESHOLD ||
        acceleration.z > THRESHOLD || acceleration.z < -THRESHOLD) {
        
        if (!shake_once) {
            //      int derp = 22/7;
            shake_once = true;
            
            //玩家在摇晃屏幕
            CCLOG(@"玩家在摇晃屏幕");
            
            
            //让摇铃发声并摇晃
            [self bellRingByShake];
            [self bellShake];
        }
        
    }
    else {
        shake_once = false;
    }
    
}

//获取设备类型
-(void)getDeviceType{
    
    if([GameData sharedData].isDeviceIphone5 == NO){
        deviceType = kDeviceTypeNotIphone5;
    }else{
        deviceType = kDeviceTypeIphone5OrNewTouch;
    }
}

-(void)playIntroMusic{
    
    [[SimpleAudioEngine sharedEngine]playEffect:@"bellintro.wav"];
}

#pragma mark 初始化方法

-(id)init{
    if((self =[super init])){
        [self getDeviceType];
        
        [self addBackItem];
        [self addBackground];
        [self addTips];
        [self addBell];
        [self addBellTouchArea];
        
        [self playIntroMusic];
        
        //启用加速计（检测摇晃事件）
        self.isAccelerometerEnabled = YES;
        [[UIAccelerometer sharedAccelerometer]setUpdateInterval:1/60];
        shake_once = false;
    }
    return self;
    
}

@end
