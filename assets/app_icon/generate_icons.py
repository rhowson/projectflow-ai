#!/usr/bin/env python3
"""
ProjectFlow AI Icon Generator

This script generates all required app icons for iOS, Android, and Web platforms
from the base SVG design.

Requirements:
    pip install pillow cairosvg

Usage:
    python generate_icons.py
"""

import os
import json
from pathlib import Path
try:
    import cairosvg
    from PIL import Image
except ImportError:
    print("Please install required packages: pip install pillow cairosvg")
    exit(1)

# Base paths
BASE_DIR = Path(__file__).parent
PROJECT_ROOT = BASE_DIR.parent.parent
SVG_FILE = BASE_DIR / "icon_base.svg"

# Icon sizes for different platforms
IOS_SIZES = {
    "Icon-App-20x20@1x.png": 20,
    "Icon-App-20x20@2x.png": 40,
    "Icon-App-20x20@3x.png": 60,
    "Icon-App-29x29@1x.png": 29,
    "Icon-App-29x29@2x.png": 58,
    "Icon-App-29x29@3x.png": 87,
    "Icon-App-40x40@1x.png": 40,
    "Icon-App-40x40@2x.png": 80,
    "Icon-App-40x40@3x.png": 120,
    "Icon-App-60x60@2x.png": 120,
    "Icon-App-60x60@3x.png": 180,
    "Icon-App-76x76@1x.png": 76,
    "Icon-App-76x76@2x.png": 152,
    "Icon-App-83.5x83.5@2x.png": 167,
    "Icon-App-1024x1024@1x.png": 1024,
}

ANDROID_SIZES = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192,
}

WEB_SIZES = {
    "Icon-192.png": 192,
    "Icon-512.png": 512,
    "Icon-maskable-192.png": 192,
    "Icon-maskable-512.png": 512,
}

def generate_png_from_svg(svg_path, output_path, size):
    """Convert SVG to PNG at specified size"""
    try:
        # Convert SVG to PNG using cairosvg
        cairosvg.svg2png(
            url=str(svg_path),
            write_to=str(output_path),
            output_width=size,
            output_height=size
        )
        print(f"Generated {output_path} ({size}x{size})")
        return True
    except Exception as e:
        print(f"Error generating {output_path}: {e}")
        return False

def generate_ios_icons():
    """Generate iOS app icons"""
    ios_dir = PROJECT_ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
    ios_dir.mkdir(parents=True, exist_ok=True)
    
    # Generate icon files
    for filename, size in IOS_SIZES.items():
        output_path = ios_dir / filename
        generate_png_from_svg(SVG_FILE, output_path, size)
    
    # Update Contents.json
    contents_json = {
        "images": [
            {"filename": "Icon-App-20x20@1x.png", "idiom": "iphone", "scale": "1x", "size": "20x20"},
            {"filename": "Icon-App-20x20@2x.png", "idiom": "iphone", "scale": "2x", "size": "20x20"},
            {"filename": "Icon-App-20x20@3x.png", "idiom": "iphone", "scale": "3x", "size": "20x20"},
            {"filename": "Icon-App-29x29@1x.png", "idiom": "iphone", "scale": "1x", "size": "29x29"},
            {"filename": "Icon-App-29x29@2x.png", "idiom": "iphone", "scale": "2x", "size": "29x29"},
            {"filename": "Icon-App-29x29@3x.png", "idiom": "iphone", "scale": "3x", "size": "29x29"},
            {"filename": "Icon-App-40x40@1x.png", "idiom": "iphone", "scale": "1x", "size": "40x40"},
            {"filename": "Icon-App-40x40@2x.png", "idiom": "iphone", "scale": "2x", "size": "40x40"},
            {"filename": "Icon-App-40x40@3x.png", "idiom": "iphone", "scale": "3x", "size": "40x40"},
            {"filename": "Icon-App-60x60@2x.png", "idiom": "iphone", "scale": "2x", "size": "60x60"},
            {"filename": "Icon-App-60x60@3x.png", "idiom": "iphone", "scale": "3x", "size": "60x60"},
            {"filename": "Icon-App-20x20@1x.png", "idiom": "ipad", "scale": "1x", "size": "20x20"},
            {"filename": "Icon-App-20x20@2x.png", "idiom": "ipad", "scale": "2x", "size": "20x20"},
            {"filename": "Icon-App-29x29@1x.png", "idiom": "ipad", "scale": "1x", "size": "29x29"},
            {"filename": "Icon-App-29x29@2x.png", "idiom": "ipad", "scale": "2x", "size": "29x29"},
            {"filename": "Icon-App-40x40@1x.png", "idiom": "ipad", "scale": "1x", "size": "40x40"},
            {"filename": "Icon-App-40x40@2x.png", "idiom": "ipad", "scale": "2x", "size": "40x40"},
            {"filename": "Icon-App-76x76@1x.png", "idiom": "ipad", "scale": "1x", "size": "76x76"},
            {"filename": "Icon-App-76x76@2x.png", "idiom": "ipad", "scale": "2x", "size": "76x76"},
            {"filename": "Icon-App-83.5x83.5@2x.png", "idiom": "ipad", "scale": "2x", "size": "83.5x83.5"},
            {"filename": "Icon-App-1024x1024@1x.png", "idiom": "ios-marketing", "scale": "1x", "size": "1024x1024"}
        ],
        "info": {"author": "xcode", "version": 1}
    }
    
    with open(ios_dir / "Contents.json", "w") as f:
        json.dump(contents_json, f, indent=2)
    
    print("iOS icons generated successfully!")

def generate_android_icons():
    """Generate Android app icons"""
    android_res_dir = PROJECT_ROOT / "android" / "app" / "src" / "main" / "res"
    
    for density, size in ANDROID_SIZES.items():
        mipmap_dir = android_res_dir / f"mipmap-{density}"
        mipmap_dir.mkdir(parents=True, exist_ok=True)
        
        output_path = mipmap_dir / "ic_launcher.png"
        generate_png_from_svg(SVG_FILE, output_path, size)
    
    print("Android icons generated successfully!")

def generate_web_icons():
    """Generate Web app icons"""
    web_icons_dir = PROJECT_ROOT / "web" / "icons"
    web_icons_dir.mkdir(parents=True, exist_ok=True)
    
    for filename, size in WEB_SIZES.items():
        output_path = web_icons_dir / filename
        generate_png_from_svg(SVG_FILE, output_path, size)
    
    print("Web icons generated successfully!")

def main():
    if not SVG_FILE.exists():
        print(f"SVG file not found: {SVG_FILE}")
        return
    
    print("Generating ProjectFlow AI app icons...")
    print(f"Using SVG: {SVG_FILE}")
    
    generate_ios_icons()
    generate_android_icons()
    generate_web_icons()
    
    print("\nAll icons generated successfully!")
    print("Icons are now ready for app store submission.")

if __name__ == "__main__":
    main()