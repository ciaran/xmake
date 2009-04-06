#import "OutputParser.h"
#import "RegexKitLite.h"

@implementation OutputParser
// ==================
// = Setup/Teardown =
// ==================

- (void)dealloc
{
	self.sourcePath = nil;
	[super dealloc];
}

// =============
// = Accessors =
// =============

@synthesize sourcePath, progressValue;

- (NSString*)openLinkForFile:(NSString*)path line:(NSUInteger)lineNumber
{
	return [NSString stringWithFormat:@"txmt://open?url=file://%@&line=%d", path, lineNumber];
}

- (NSString*)pathForFilename:(NSString*)filename inDirectory:(NSString*)directory
{
	NSTask* task        = [[NSTask new] autorelease];
	task.launchPath     = @"/usr/bin/find";
	task.arguments      = [NSArray arrayWithObjects:directory, @"-name", filename, nil];
	[task setStandardOutput:[NSPipe pipe]];
	[task launch];
	[task waitUntilExit];
	NSString* result = [[[NSString alloc] initWithData:[[[task standardOutput] fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding] autorelease];
	return [[result componentsSeparatedByString:@"\n"] objectAtIndex:0];
}

- (NSAttributedString*)processOutput:(NSString*)output
{
	static NSDictionary* const attributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont fontWithName:@"DejaVuSansMono" size:11], NSFontAttributeName, nil];
	NSMutableAttributedString* string     = [[[NSMutableAttributedString alloc] initWithString:output attributes:attributes] autorelease];

	NSRange matchedRange = {0, 0};
	while(matchedRange.location < string.string.length)
	{
		NSRange searchRange = NSMakeRange(matchedRange.location, string.string.length - matchedRange.location);
		matchedRange = [string.string rangeOfRegex:@"^(/[^:]+?):(\\d+)?"
                                           options:RKLMultiline
                                           inRange:searchRange
                                           capture:0
                                             error:NULL];
		if(matchedRange.location != NSNotFound)
		{
			NSArray* components   = [[string.string substringWithRange:matchedRange] componentsSeparatedByString:@":"];
			NSString* path        = [components objectAtIndex:0];
			NSUInteger lineNumber = [[components objectAtIndex:1] intValue];
			NSString* pathText    = [string.string substringWithRange:matchedRange];
			if(self.sourcePath && [[pathText substringToIndex:self.sourcePath.length] isEqualToString:self.sourcePath])
				pathText = [pathText substringFromIndex:self.sourcePath.length];

			NSMutableAttributedString* pathString = [[[NSMutableAttributedString alloc] initWithString:pathText attributes:attributes] autorelease];
			[pathString addAttribute:NSLinkAttributeName value:[self openLinkForFile:path line:lineNumber] range:NSMakeRange(0, pathString.length)];
			[string replaceCharactersInRange:matchedRange withAttributedString:pathString];
			matchedRange.location += pathString.length + 1;
		}
	}

	if(self.sourcePath)
	{
		// Look for “filename:line” from exception backtraces
		matchedRange = (NSRange){0, 0};
		while(matchedRange.location < string.string.length)
		{
			NSRange searchRange = NSMakeRange(matchedRange.location, string.string.length - matchedRange.location);
			matchedRange = [string.string rangeOfRegex:@"^\\s*([^/:].+?\\.[a-z]+):(\\d+)"
	                                           options:RKLMultiline
	                                           inRange:searchRange
	                                           capture:0
	                                             error:NULL];
			if(matchedRange.location != NSNotFound)
			{
				NSArray* components   = [[string.string substringWithRange:matchedRange] componentsSeparatedByString:@":"];
				NSString* filename    = [[components objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				NSUInteger lineNumber = [[components objectAtIndex:1] intValue];

				if(NSString* path = [self pathForFilename:filename inDirectory:self.sourcePath])
					[string addAttribute:NSLinkAttributeName value:[self openLinkForFile:path line:lineNumber] range:matchedRange];
				matchedRange.location += matchedRange.length + 1;
			}
		}
	}

	if(NSString* progress = [output stringByMatching:@"\\[\\s*(\\d+)%\\]" capture:1]) // FIXME this should really search for the last occurence in the string
		progressValue = [progress doubleValue];

	return string;
}
@end
