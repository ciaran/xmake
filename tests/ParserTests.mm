#import "ParserTests.h"
#import "OutputParser.h"

@implementation ParserTests
- (void)testPlainText
{
	OutputParser* parser = [[OutputParser new] autorelease];
	NSString* text       = @"foo bar baz";
	STAssertEqualObjects([[parser processOutput:text] string], text, @"Plain text should be returned unmodified.");
}

- (void)testFileLineLinking
{
	OutputParser* parser       = [[OutputParser new] autorelease];
	NSString* path             = @"/path/to/file";
	NSUInteger lineNumber      = 123;
	NSString* text             = [NSString stringWithFormat:@"%@:%d", path, lineNumber];
	NSAttributedString* result = [parser processOutput:text];
	NSString* link             = [result attribute:NSLinkAttributeName atIndex:0 effectiveRange:NULL];
	STAssertEqualObjects(link, [parser openLinkForFile:path line:lineNumber], @"Link was incorrect.");
}

- (void)testFileLinking
{
	OutputParser* parser       = [[OutputParser new] autorelease];
	NSString* path             = @"/path/to/file";
	NSString* text             = [NSString stringWithFormat:@"%@:", path];
	NSAttributedString* result = [parser processOutput:text];
	NSString* link             = [result attribute:NSLinkAttributeName atIndex:0 effectiveRange:NULL];
	STAssertEqualObjects(link, [parser openLinkForFile:path line:0], @"Link was incorrect.");
}
@end
