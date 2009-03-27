#import <Cocoa/Cocoa.h>

@interface OutputParser : NSObject
{
	NSString* sourcePath;
	double progressValue;
}
@property (copy) NSString* sourcePath;
@property (readonly) double progressValue;
- (NSAttributedString*)processOutput:(NSString*)output;
@end
