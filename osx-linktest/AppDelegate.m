//
//  AppDelegate.m
//  osx-linktest
//
//  Created by Armando Di Cianno on 12/3/15.
//  Copyright © 2015 Armando Di Cianno. All rights reserved.
//

#import "AppDelegate.h"


@import CommonCrypto;

@interface AppDelegate ()

@end

@interface NSData (foo)
- (NSData *)base64Decoded;
@end

@implementation NSData (foo)
- (NSData *)base64Decoded
{
    const unsigned char	*bytes = [self bytes];
    NSMutableData *result = [NSMutableData dataWithCapacity:[self length]];
    
    unsigned long ixtext = 0;
    unsigned long lentext = [self length];
    unsigned char ch = 0;
    unsigned char inbuf[4] = {0, 0, 0, 0};
    unsigned char outbuf[3] = {0, 0, 0};
    short i = 0, ixinbuf = 0;
    BOOL flignore = NO;
    BOOL flendtext = NO;
    
    while( YES )
    {
        if( ixtext >= lentext ) break;
        ch = bytes[ixtext++];
        flignore = NO;
        
        if( ( ch >= 'A' ) && ( ch <= 'Z' ) ) ch = ch - 'A';
        else if( ( ch >= 'a' ) && ( ch <= 'z' ) ) ch = ch - 'a' + 26;
        else if( ( ch >= '0' ) && ( ch <= '9' ) ) ch = ch - '0' + 52;
        else if( ch == '+' ) ch = 62;
        else if( ch == '=' ) flendtext = YES;
        else if( ch == '/' ) ch = 63;
        else flignore = YES;
        
        if( ! flignore )
        {
            short ctcharsinbuf = 3;
            BOOL flbreak = NO;
            
            if( flendtext )
            {
                if( ! ixinbuf ) break;
                if( ( ixinbuf == 1 ) || ( ixinbuf == 2 ) ) ctcharsinbuf = 1;
                else ctcharsinbuf = 2;
                ixinbuf = 3;
                flbreak = YES;
            }
            
            inbuf [ixinbuf++] = ch;
            
            if( ixinbuf == 4 )
            {
                ixinbuf = 0;
                outbuf [0] = ( inbuf[0] << 2 ) | ( ( inbuf[1] & 0x30) >> 4 );
                outbuf [1] = ( ( inbuf[1] & 0x0F ) << 4 ) | ( ( inbuf[2] & 0x3C ) >> 2 );
                outbuf [2] = ( ( inbuf[2] & 0x03 ) << 6 ) | ( inbuf[3] & 0x3F );
                
                for( i = 0; i < ctcharsinbuf; i++ )
                    [result appendBytes:&outbuf[i] length:1];
            }
            
            if( flbreak )  break;
        }
    }
    
    return [NSData dataWithData:result];
}
@end


@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmacAlgorithm algorithm = kCCHmacAlgSHA1;
    NSData *saltData = [[@"salt" dataUsingEncoding:NSUTF8StringEncoding] base64Decoded];
    NSData *passwordData = [@"password" dataUsingEncoding:NSUTF8StringEncoding];
    
    CCHmac(algorithm, [saltData bytes], [saltData length], [passwordData bytes], [passwordData length], cHMAC);
    NSData *result = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSLog(@"result bytes: %lu", (unsigned long)[result length]);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
