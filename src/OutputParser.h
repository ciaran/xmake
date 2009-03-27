#import <Cocoa/Cocoa.h>

@interface OutputParser : NSObject
{
	NSString* sourcePath;
	double progressValue;
}
@property (copy) NSString* sourcePath;
@property (readonly) double progressValue;
- (NSString*)openLinkForFile:(NSString*)path line:(NSUInteger)lineNumber;
- (NSAttributedString*)processOutput:(NSString*)output;
@end
