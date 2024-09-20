//
//  TTCategoryMenubarOptionButtonConfig.m
//  TTCategoryMenuBar
//
//  Created by ByteDance on 19/9/2024.
//

#import "TTCategoryMenubarOptionButtonConfig.h"

@implementation TTCategoryMenubarOptionButtonBackgroundConfig

@end

@implementation TTCategoryMenubarOptionButtonTitleConfig

@end

@implementation TTCategoryMenubarOptionButtonIconConfig

@end

@interface TTCategoryMenubarOptionButtonConfig ()

@property (nonatomic, strong) NSMutableDictionary *backgroundConfigs;
@property (nonatomic, strong) NSMutableDictionary *titleConfigs;
@property (nonatomic, strong) NSMutableDictionary *iconConfigs;

@end

@implementation TTCategoryMenubarOptionButtonConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        _backgroundConfigs = [NSMutableDictionary dictionary];
        _titleConfigs = [NSMutableDictionary dictionary];
        _iconConfigs = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setBackgroundConfig:(TTCategoryMenubarOptionButtonBackgroundConfig *)config forState:(TTCategoryMenubarOptionButtonState)state {
    [self.backgroundConfigs setObject:config forKey:@(state)];
}

- (TTCategoryMenubarOptionButtonBackgroundConfig *)backgroundConfigForState:(TTCategoryMenubarOptionButtonState)state {
    return self.backgroundConfigs[@(state)];
}

- (void)setTitleConfig:(TTCategoryMenubarOptionButtonTitleConfig *)config forState:(TTCategoryMenubarOptionButtonState)state {
    [self.titleConfigs setObject:config forKey:@(state)];
}

- (TTCategoryMenubarOptionButtonTitleConfig *)titleConfigForState:(TTCategoryMenubarOptionButtonState)state {
    return self.titleConfigs[@(state)];
}

- (void)setIconConfig:(TTCategoryMenubarOptionButtonIconConfig *)config forState:(TTCategoryMenubarOptionButtonState)state {
    [self.iconConfigs setObject:config forKey:@(state)];
}

- (TTCategoryMenubarOptionButtonIconConfig *)iconConfigForState:(TTCategoryMenubarOptionButtonState)state {
    return self.iconConfigs[@(state)];
}

@end

@interface TTCategoryMenubarOptionButtonsConfig ()

@property (nonatomic, strong) NSMutableDictionary *buttonConfigs;

@end

@implementation TTCategoryMenubarOptionButtonsConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        _buttonConfigs = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setButtonConfig:(TTCategoryMenubarOptionButtonConfig *)config forStyle:(TTCategoryMenubarOptionButtonStyle)style {
    config.style = style;
    [self.buttonConfigs setObject:config forKey:@(style)];
}

- (TTCategoryMenubarOptionButtonConfig *)buttonConfigForStyle:(TTCategoryMenubarOptionButtonStyle)style {
    return [self.buttonConfigs objectForKey:@(style)];
}

- (NSArray<TTCategoryMenubarOptionButtonConfig *> *)buttons {
    NSMutableArray *buttons = [NSMutableArray array];
    [self.buttonConfigs enumerateKeysAndObjectsUsingBlock:^(NSNumber *style, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (style.intValue == TTCategoryMenubarOptionButtonStyleReset) {
            if (buttons.count > 0) {
                [buttons insertObject:obj atIndex:0];
            } else {
                [buttons addObject:obj];
            }
        } else {
            [buttons addObject:obj];
        }
    }];
    return buttons.copy;
}

+ (instancetype)defaultConfig {
    TTCategoryMenubarOptionButtonsConfig *defaultConfig = [[TTCategoryMenubarOptionButtonsConfig alloc] init];
    
    defaultConfig.insetHorizontal = 10;
    defaultConfig.buttonGap = 5;
    defaultConfig.buttonTop = 10;
    defaultConfig.buttonBottom = 15;
    
    defaultConfig.buttonContainerTopBorderColor = UIColor.redColor;
    defaultConfig.buttonContainerTopBorderWidth = 0.5;
    
    {
        TTCategoryMenubarOptionButtonConfig *resetButton = [[TTCategoryMenubarOptionButtonConfig alloc] init];
        resetButton.resetStyle = TTCategoryMenuBarCategoryResetToLastCommit;
        resetButton.height = 44;
        resetButton.width = 80;
        resetButton.widthRatio = 0.3;
        
        TTCategoryMenubarOptionButtonBackgroundConfig *backgroundConfig = [[TTCategoryMenubarOptionButtonBackgroundConfig alloc] init];
        backgroundConfig.backgroundColor = UIColor.lightGrayColor;
        backgroundConfig.cornerRadius = 10;
        [resetButton setBackgroundConfig:backgroundConfig forState:TTCategoryMenubarOptionButtonStateNormal];
        
        TTCategoryMenubarOptionButtonTitleConfig *titleConfig = [[TTCategoryMenubarOptionButtonTitleConfig alloc] init];
        titleConfig.title = @"重置";
        titleConfig.titleColor = UIColor.whiteColor;
        titleConfig.titleFont = [UIFont systemFontOfSize:15];
        [resetButton setTitleConfig:titleConfig forState:TTCategoryMenubarOptionButtonStateNormal];
        
        TTCategoryMenubarOptionButtonIconConfig *iconConfig = [[TTCategoryMenubarOptionButtonIconConfig alloc] init];
        iconConfig.image = [UIImage imageNamed:@"refresh_icon"];
        iconConfig.size = CGSizeMake(15, 15);
        iconConfig.iconTitleGap = 10;
        [resetButton setIconConfig:iconConfig forState:TTCategoryMenubarOptionButtonStateNormal];
        
        [defaultConfig setButtonConfig:resetButton forStyle:TTCategoryMenubarOptionButtonStyleReset];
    }
    
    {
        TTCategoryMenubarOptionButtonConfig *doneButton = [[TTCategoryMenubarOptionButtonConfig alloc] init];
        doneButton.height = 44;
        doneButton.widthRatio = 0.7;
        
        TTCategoryMenubarOptionButtonBackgroundConfig *backgroundConfig = [[TTCategoryMenubarOptionButtonBackgroundConfig alloc] init];
        backgroundConfig.backgroundColor = UIColor.blueColor;
        backgroundConfig.borderColor = UIColor.yellowColor;
        backgroundConfig.borderWidth = 1;
        backgroundConfig.cornerRadius = 10;
        [doneButton setBackgroundConfig:backgroundConfig forState:TTCategoryMenubarOptionButtonStateNormal];
        
        TTCategoryMenubarOptionButtonBackgroundConfig *backgroundConfig2 = [[TTCategoryMenubarOptionButtonBackgroundConfig alloc] init];
        backgroundConfig2.backgroundColor = UIColor.brownColor;
        backgroundConfig2.cornerRadius = 5;
        [doneButton setBackgroundConfig:backgroundConfig2 forState:TTCategoryMenubarOptionButtonStateHasSelectedItems];
        
        TTCategoryMenubarOptionButtonTitleConfig *titleConfig = [[TTCategoryMenubarOptionButtonTitleConfig alloc] init];
        titleConfig.title = @"确定";
        titleConfig.titleColor = UIColor.whiteColor;
        titleConfig.titleFont = [UIFont boldSystemFontOfSize:16];
        [doneButton setTitleConfig:titleConfig forState:TTCategoryMenubarOptionButtonStateNormal];
        
        TTCategoryMenubarOptionButtonTitleConfig *titleConfig2 = [[TTCategoryMenubarOptionButtonTitleConfig alloc] init];
        titleConfig2.titleFormat = @"已选择%ld项";
        titleConfig2.titleColor = UIColor.redColor;
        titleConfig2.titleFont = [UIFont boldSystemFontOfSize:16];
        [doneButton setTitleConfig:titleConfig2 forState:TTCategoryMenubarOptionButtonStateHasSelectedItems];
        
        [defaultConfig setButtonConfig:doneButton forStyle:TTCategoryMenubarOptionButtonStyleDone];
    }
    
    return defaultConfig;
}

+ (instancetype)onlyDoneConfig {
    TTCategoryMenubarOptionButtonsConfig *defaultConfig = [[TTCategoryMenubarOptionButtonsConfig alloc] init];
    
    defaultConfig.insetHorizontal = 10;
    defaultConfig.buttonGap = 5;
    defaultConfig.buttonTop = 5;
    defaultConfig.buttonBottom = 5;
    defaultConfig.buttonContainerTopBorderColor = UIColor.grayColor;
    defaultConfig.buttonContainerTopBorderWidth = 1;

    
    {
        TTCategoryMenubarOptionButtonConfig *doneButton = [[TTCategoryMenubarOptionButtonConfig alloc] init];
        doneButton.height = 44;
        doneButton.widthRatio = 0.5;
        
        TTCategoryMenubarOptionButtonBackgroundConfig *backgroundConfig = [[TTCategoryMenubarOptionButtonBackgroundConfig alloc] init];
        backgroundConfig.backgroundColor = UIColor.blueColor;
        backgroundConfig.borderColor = UIColor.yellowColor;
        backgroundConfig.borderWidth = 1;
        backgroundConfig.cornerRadius = 10;
        [doneButton setBackgroundConfig:backgroundConfig forState:TTCategoryMenubarOptionButtonStateNormal];
        
        TTCategoryMenubarOptionButtonBackgroundConfig *backgroundConfig2 = [[TTCategoryMenubarOptionButtonBackgroundConfig alloc] init];
        backgroundConfig2.backgroundColor = UIColor.brownColor;
        backgroundConfig2.cornerRadius = 5;
        [doneButton setBackgroundConfig:backgroundConfig2 forState:TTCategoryMenubarOptionButtonStateHasSelectedItems];
        
        TTCategoryMenubarOptionButtonTitleConfig *titleConfig = [[TTCategoryMenubarOptionButtonTitleConfig alloc] init];
        titleConfig.title = @"确定";
        titleConfig.titleColor = UIColor.blackColor;
        titleConfig.titleFont = [UIFont boldSystemFontOfSize:16];
        [doneButton setTitleConfig:titleConfig forState:TTCategoryMenubarOptionButtonStateNormal];
        
        TTCategoryMenubarOptionButtonTitleConfig *titleConfig2 = [[TTCategoryMenubarOptionButtonTitleConfig alloc] init];
        titleConfig2.customTitle = ^NSAttributedString *(NSInteger count) {
            NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"已选择%ld", count] attributes:@{NSForegroundColorAttributeName:UIColor.blackColor}];
            [attributedTitle addAttributes:@{NSForegroundColorAttributeName:UIColor.redColor} range:NSMakeRange(3, attributedTitle.string.length - 3)];
            return attributedTitle;
        };
        titleConfig2.titleColor = UIColor.redColor;
        titleConfig2.titleFont = [UIFont boldSystemFontOfSize:16];
        [doneButton setTitleConfig:titleConfig2 forState:TTCategoryMenubarOptionButtonStateHasSelectedItems];
        
        [defaultConfig setButtonConfig:doneButton forStyle:TTCategoryMenubarOptionButtonStyleDone];
    }
    
    return defaultConfig;
}

@end
