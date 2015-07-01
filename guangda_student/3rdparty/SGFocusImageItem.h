
#import <Foundation/Foundation.h>

@interface SGFocusImageItem : NSObject

@property (nonatomic, retain)  NSString     *title;
@property (nonatomic, retain)  NSString     *image;
@property (nonatomic, assign)  NSInteger     tag;
@property (nonatomic, retain)  NSString     *price;
@property (nonatomic, assign)  NSNumber     *productid;
@property (nonatomic, strong)  NSString      *linkStr;


- (id)initWithTitle:(NSString *)title image:(NSString *)image tag:(NSInteger)tag;
- (id)initWithDict:(NSDictionary *)dict tag:(NSInteger)tag;
- (id)initWithRecDict:(NSDictionary *)dict tag:(NSInteger)tag;

- (id)initWithProduct:(NSDictionary *)dict tag:(NSInteger)tag;
- (id)initWithProduct2:(NSDictionary *)dict tag:(NSInteger)tag;


- (id)initWithUrlString:(NSString *)string;
@end
