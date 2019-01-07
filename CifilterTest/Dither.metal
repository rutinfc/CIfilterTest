//
//  Dither.metal
//  Cloud
//
//  Created by jeongkyu kim on 17/12/2018.
//  Copyright © 2018 skt. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

#include <CoreImage/CoreImage.h>

extern "C" { namespace coreimage {
    
    float orderedDither8x8(float colorin, float bx, float by, float intentsity) {
        
        float error = 0.0;
        int px = int(bx);
        int py = int(by);
        
        if (py == 0) {
            if (px == 0) { error =  1.0 / 65.0; }
            if (px == 1) { error = 49.0 / 65.0; }
            if (px == 2) { error = 13.0 / 65.0; }
            if (px == 3) { error = 61.0 / 65.0; }
            if (px == 4) { error =  4.0 / 65.0; }
            if (px == 5) { error = 52.0 / 65.0; }
            if (px == 6) { error = 16.0 / 65.0; }
            if (px == 7) { error = 64.0 / 65.0; }
        }
        if (py == 1) {
            if (px == 0) { error = 33.0 / 65.0; }
            if (px == 1) { error = 17.0 / 65.0; }
            if (px == 2) { error = 45.0 / 65.0; }
            if (px == 3) { error = 29.0 / 65.0; }
            if (px == 4) { error = 36.0 / 65.0; }
            if (px == 5) { error = 20.0 / 65.0; }
            if (px == 6) { error = 48.0 / 65.0; }
            if (px == 7) { error = 32.0 / 65.0; }
        }
        if (py == 2) {
            if (px == 0) { error =  9.0 / 65.0; }
            if (px == 1) { error = 57.0 / 65.0; }
            if (px == 2) { error =  5.0 / 65.0; }
            if (px == 3) { error = 53.0 / 65.0; }
            if (px == 4) { error = 12.0 / 65.0; }
            if (px == 5) { error = 60.0 / 65.0; }
            if (px == 6) { error =  8.0 / 65.0; }
            if (px == 7) { error = 56.0 / 65.0; }
        }
        if (py == 3) {
            if (px == 0) { error = 41.0 / 65.0; }
            if (px == 1) { error = 25.0 / 65.0; }
            if (px == 2) { error = 37.0 / 65.0; }
            if (px == 3) { error = 21.0 / 65.0; }
            if (px == 4) { error = 44.0 / 65.0; }
            if (px == 5) { error = 28.0 / 65.0; }
            if (px == 6) { error = 40.0 / 65.0; }
            if (px == 7) { error = 24.0 / 65.0; }
        }
        if (py == 4) {
            if (px == 0) { error =  3.0 / 65.0; }
            if (px == 1) { error = 51.0 / 65.0; }
            if (px == 2) { error = 15.0 / 65.0; }
            if (px == 3) { error = 63.0 / 65.0; }
            if (px == 4) { error =  2.0 / 65.0; }
            if (px == 5) { error = 50.0 / 65.0; }
            if (px == 6) { error = 14.0 / 65.0; }
            if (px == 7) { error = 62.0 / 65.0; }
        }
        if (py == 5) {
            if (px == 0) { error = 35.0 / 65.0; }
            if (px == 1) { error = 19.0 / 65.0; }
            if (px == 2) { error = 47.0 / 65.0; }
            if (px == 3) { error = 31.0 / 65.0; }
            if (px == 4) { error = 34.0 / 65.0; }
            if (px == 5) { error = 18.0 / 65.0; }
            if (px == 6) { error = 46.0 / 65.0; }
            if (px == 7) { error = 30.0 / 65.0; }
        }
        if (py == 6) {
            if (px == 0) { error = 11.0 / 65.0; }
            if (px == 1) { error = 59.0 / 65.0; }
            if (px == 2) { error =  7.0 / 65.0; }
            if (px == 3) { error = 55.0 / 65.0; }
            if (px == 4) { error = 10.0 / 65.0; }
            if (px == 5) { error = 58.0 / 65.0; }
            if (px == 6) { error =  6.0 / 65.0; }
            if (px == 7) { error = 54.0 / 65.0; }
        }
        if (py == 7) {
            if (px == 0) { error = 43.0 / 65.0; }
            if (px == 1) { error = 27.0 / 65.0; }
            if (px == 2) { error = 39.0 / 65.0; }
            if (px == 3) { error = 23.0 / 65.0; }
            if (px == 4) { error = 42.0 / 65.0; }
            if (px == 5) { error = 26.0 / 65.0; }
            if (px == 6) { error = 38.0 / 65.0; }
            if (px == 7) { error = 22.0 / 65.0; }
        }
        
        return colorin * (error * 2.0 * intentsity + (1.0 - intentsity));
    }
    
    float4 dither(sampler src, float intensity) {
        
        float4 s = src.sample(src.coord());
        
        float msize = 8;
        
        float2 position = src.coord();
        float2 size = src.size();
        float2 offset = position * size;
        
        float px = fmod(offset.x, msize);
        float py = fmod(offset.y, msize);
        
        float red = orderedDither8x8(s.r, px, py, intensity);
        float green = orderedDither8x8(s.g, px, py, intensity);
        float blue = orderedDither8x8(s.b, px, py, intensity);
        
        return float4(red, green, blue, 1);
    }
}}


