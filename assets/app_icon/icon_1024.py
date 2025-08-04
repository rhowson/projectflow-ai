#!/usr/bin/env python3
"""
Simple PNG icon generator for ProjectFlow AI
Creates a 1024x1024 base icon that can be resized for different platforms.
"""

try:
    from PIL import Image, ImageDraw
    import math
except ImportError:
    print("Please install Pillow: pip install pillow")
    exit(1)

def create_projectflow_icon(size=1024):
    """Create the ProjectFlow AI icon"""
    
    # Create base image with gradient-like background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Background with rounded corners (approximation)
    corner_radius = int(size * 0.18)  # 18% corner radius like iOS
    
    # Create purple gradient background
    for y in range(size):
        for x in range(size):
            # Check if point is within rounded rectangle
            in_corner = False
            
            # Top-left corner
            if x < corner_radius and y < corner_radius:
                if (x - corner_radius)**2 + (y - corner_radius)**2 > corner_radius**2:
                    in_corner = True
            # Top-right corner
            elif x > size - corner_radius and y < corner_radius:
                if (x - (size - corner_radius))**2 + (y - corner_radius)**2 > corner_radius**2:
                    in_corner = True
            # Bottom-left corner
            elif x < corner_radius and y > size - corner_radius:
                if (x - corner_radius)**2 + (y - (size - corner_radius))**2 > corner_radius**2:
                    in_corner = True
            # Bottom-right corner
            elif x > size - corner_radius and y > size - corner_radius:
                if (x - (size - corner_radius))**2 + (y - (size - corner_radius))**2 > corner_radius**2:
                    in_corner = True
            
            if not in_corner:
                # Gradient from top-left purple to bottom-right darker purple
                progress = (x + y) / (size * 2)
                r = int(99 + (79 - 99) * progress)   # 99 -> 79 (6366F1 -> 4F46E5)
                g = int(102 + (70 - 102) * progress) # 102 -> 70
                b = int(241 + (229 - 241) * progress) # 241 -> 229
                img.putpixel((x, y), (r, g, b, 255))
    
    # Center point
    center_x, center_y = size // 2, size // 2
    
    # Scale factor for different elements
    scale = size / 1024
    
    # Draw central hub
    hub_radius = int(45 * scale)
    draw.ellipse([
        center_x - hub_radius, center_y - hub_radius,
        center_x + hub_radius, center_y + hub_radius
    ], fill=(255, 255, 255, 255))
    
    # Draw connected nodes and lines
    node_radius = int(30 * scale)
    line_width = int(8 * scale)
    connection_distance = int(160 * scale)
    
    # 8 nodes around the center
    angles = [0, 45, 90, 135, 180, 225, 270, 315]
    
    for angle in angles:
        rad = math.radians(angle)
        
        # Node position
        node_x = center_x + int(connection_distance * math.cos(rad))
        node_y = center_y + int(connection_distance * math.sin(rad))
        
        # Draw connection line
        line_start_x = center_x + int(hub_radius * math.cos(rad))
        line_start_y = center_y + int(hub_radius * math.sin(rad))
        line_end_x = node_x - int(node_radius * math.cos(rad))
        line_end_y = node_y - int(node_radius * math.sin(rad))
        
        draw.line([
            (line_start_x, line_start_y),
            (line_end_x, line_end_y)
        ], fill=(255, 255, 255, 255), width=line_width)
        
        # Draw node
        draw.ellipse([
            node_x - node_radius, node_y - node_radius,
            node_x + node_radius, node_y + node_radius
        ], fill=(255, 255, 255, 255))
    
    # Draw AI indicator star in center
    star_size = int(20 * scale)
    star_points = []
    for i in range(8):
        angle = i * 45
        if i % 2 == 0:  # Outer points
            radius = star_size
        else:  # Inner points
            radius = star_size * 0.3
        
        rad = math.radians(angle - 90)  # Start from top
        x = center_x + int(radius * math.cos(rad))
        y = center_y + int(radius * math.sin(rad))
        star_points.append((x, y))
    
    draw.polygon(star_points, fill=(99, 102, 241, 200))  # Semi-transparent purple
    
    return img

def resize_icon(base_img, target_size):
    """Resize icon to target size with high quality"""
    return base_img.resize((target_size, target_size), Image.Resampling.LANCZOS)

def main():
    print("Creating ProjectFlow AI icon...")
    
    # Create base 1024x1024 icon
    base_icon = create_projectflow_icon(1024)
    base_icon.save("icon_1024.png", "PNG")
    print("Created base icon: icon_1024.png")
    
    # Common sizes for testing
    common_sizes = [512, 256, 192, 180, 152, 144, 120, 96, 87, 80, 76, 72, 60, 58, 48, 40, 29, 20]
    
    for size in common_sizes:
        resized = resize_icon(base_icon, size)
        resized.save(f"icon_{size}.png", "PNG")
        print(f"Created icon_{size}.png")
    
    print("\nAll icons created successfully!")
    print("Use these PNG files to replace the existing app icons in your project.")

if __name__ == "__main__":
    main()