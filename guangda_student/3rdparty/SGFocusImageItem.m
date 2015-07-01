//
//  SGFocusImageItem.m
//  ScrollViewLoop
//
//  Created by Vincent Tang on 13-7-18.
//  Copyright (c) 2013年 Vincent Tang. All rights reserved.
//

#import "SGFocusImageItem.h"

@implementation SGFocusImageItem

- (id)initWithTitle:(NSString *)title image:(NSString *)image tag:(NSInteger)tag
{
    self = [super init];
    if (self) {
        self.title = title;
        self.image = image;
        self.tag = tag;
    }
    
    return self;
}

- (id)initWithDict:(NSDictionary *)dict tag:(NSInteger)tag
{
    self = [super init];
    if (self)
    {
        if ([dict isKindOfClass:[NSDictionary class]])
        {
            self.title = [dict objectForKey:@"title"];
            self.image = [dict objectForKey:@"pic_url"];
            self.linkStr = [dict objectForKey:@"link"];
            self.tag = tag;
        }
    }
    return self;
}

- (id)initWithUrlString:(NSString *)string
{
    self = [super init];
    if (self)
    {
        if ([string isKindOfClass:[NSString class]])
        {
            self.image = string;
        }
    }
    return self;
}

- (id)initWithRecDict:(NSDictionary *)dict tag:(NSInteger)tag {
    self = [super init];
    if (self)
    {
        if ([dict isKindOfClass:[NSDictionary class]])
        {
            self.title = [dict objectForKey:@"title"];
            self.image = [CommonUtil stringForID:[dict objectForKey:@"img_id"] ];

            self.tag = tag;
        }
    }
    return self;
}

- (id)initWithProduct:(NSDictionary *)dict tag:(NSInteger)tag {
    self = [super init];
    if (self)
    {
        if ([dict isKindOfClass:[NSDictionary class]])
        {
            self.title = [dict objectForKey:@"product_name"];
            self.image = [CommonUtil stringForID:[dict objectForKey:@"img_url"] ];
            self.price = [dict objectForKey:@"menu_price"];
            
            self.tag = tag;
        }
    }
    return self;
}

- (id)initWithProduct2:(NSDictionary *)dict tag:(NSInteger)tag {
    self = [super init];
    if (self)
    {
        if ([dict isKindOfClass:[NSDictionary class]])
        {
            self.title = [dict objectForKey:@"product_name"];
            self.image = [CommonUtil stringForID:[dict objectForKey:@"img_url"] ];
            self.price = [NSString stringWithFormat:@"¥%@元起",[dict objectForKey:@"mall_price"]];
            self.productid = [dict objectForKey:@"product_id"];
            self.tag = tag;
        }
    }
    return self;
}

@end
