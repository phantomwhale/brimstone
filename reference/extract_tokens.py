#!/usr/bin/env python3
"""
Extract circular token images from Shadows of Brimstone reference PDF pages.
Uses OpenCV Hough Circle Transform to detect circular tokens.
"""

import cv2
import numpy as np
import os
from pathlib import Path

# Token names based on position (page, approximate y-range, column)
# Derived from the reference document order
PAGE1_LEFT_TOKENS = [
    "ale", "anti_rad", "bandages", "bomb", "brimstone_ash", 
    "dark_stone_shiv", "dynamite", "exotic_herbs", "fine_cigar",
    "fire_sake", "flash", "hatchet", "hellfire_sake", "herbs",
    "holy_water", "junk_bomb"
]

PAGE1_RIGHT_TOKENS = [
    "javelin", "lantern_oil", "magik_tonic", "meat_cooked", "meat_raw",
    "nectar", "potion", "rum", "sake", "salt", "shatter", "spice",
    "stake", "strong_sake", "swamp_fungus"
]

PAGE2_LEFT_TOKENS = [
    "tea", "tequila", "throwing_axe", "tonic", "void_sake", "whiskey", "wine",
    # Status effect tokens on left
    "bleeding", "burning", "death_mark", "ensnared", "noise", "poison"
]

PAGE2_RIGHT_TOKENS = [
    # Large side bag tokens (pendants) - may not be detected as circles
    "amulet_of_light", "elixer_of_fortitude", "elixer_of_purity", "elixer_of_vitality",
    # Status effect tokens on right
    "potent_poison", "shaken", "stone", "stunned", "traumatized", "void_venom", "webbed"
]


def extract_tokens_from_page(image_path, output_dir, page_num=1, debug=False):
    """
    Detect and extract circular tokens from a page image.
    
    Args:
        image_path: Path to the page image
        output_dir: Directory to save extracted tokens
        page_num: Page number for naming
        debug: If True, save debug images showing detected circles
    """
    # Read image
    img = cv2.imread(str(image_path))
    if img is None:
        print(f"Error: Could not read image {image_path}")
        return []
    
    # Convert to grayscale
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
    # Apply Gaussian blur to reduce noise
    blurred = cv2.GaussianBlur(gray, (9, 9), 2)
    
    # Detect circles using Hough Circle Transform
    # Parameters tuned for ~40-50 pixel radius tokens at 150 DPI
    circles = cv2.HoughCircles(
        blurred,
        cv2.HOUGH_GRADIENT,
        dp=1,
        minDist=50,  # Minimum distance between circle centers
        param1=50,   # Upper threshold for Canny edge detector
        param2=30,   # Accumulator threshold for circle detection
        minRadius=25,  # Minimum circle radius
        maxRadius=45   # Maximum circle radius
    )
    
    extracted = []
    
    if circles is not None:
        circles = np.uint16(np.around(circles))
        print(f"Found {len(circles[0])} circles on page {page_num}")
        
        # Sort circles by y position (top to bottom), then x (left to right)
        sorted_circles = sorted(circles[0], key=lambda c: (c[1], c[0]))
        
        # Split into left and right columns (page width ~1275, midpoint ~637)
        midpoint = img.shape[1] // 2
        left_tokens = [(x, y, r) for x, y, r in sorted_circles if x < midpoint]
        right_tokens = [(x, y, r) for x, y, r in sorted_circles if x >= midpoint]
        
        # Get token names based on page
        if page_num == 1:
            left_names = PAGE1_LEFT_TOKENS
            right_names = PAGE1_RIGHT_TOKENS
        else:
            left_names = PAGE2_LEFT_TOKENS
            right_names = PAGE2_RIGHT_TOKENS
        
        if debug:
            debug_img = img.copy()
        
        def save_token(x, y, r, name, idx):
            # Tighter crop - reduce padding to 1 pixel
            padding = 1
            x1 = max(0, x - r - padding)
            y1 = max(0, y - r - padding)
            x2 = min(img.shape[1], x + r + padding)
            y2 = min(img.shape[0], y + r + padding)
            
            # Extract the token region
            token = img[y1:y2, x1:x2]
            
            # Save the token with name
            token_path = os.path.join(output_dir, f"{name}.png")
            cv2.imwrite(token_path, token)
            extracted.append((token_path, x, y, r, name))
            print(f"  Saved: {name}.png ({x}, {y})")
            
            if debug:
                # Draw circle on debug image
                cv2.circle(debug_img, (x, y), r, (0, 255, 0), 2)
                cv2.circle(debug_img, (x, y), 2, (0, 0, 255), 3)
                cv2.putText(debug_img, name[:8], (x-25, y-r-5), 
                           cv2.FONT_HERSHEY_SIMPLEX, 0.35, (255, 0, 0), 1)
        
        # Process left column
        print(f"  Left column: {len(left_tokens)} tokens")
        for i, (x, y, r) in enumerate(left_tokens):
            name = left_names[i] if i < len(left_names) else f"unknown_left_{i}"
            save_token(x, y, r, name, i)
        
        # Process right column
        print(f"  Right column: {len(right_tokens)} tokens")
        for i, (x, y, r) in enumerate(right_tokens):
            name = right_names[i] if i < len(right_names) else f"unknown_right_{i}"
            save_token(x, y, r, name, i)
        
        if debug:
            debug_path = os.path.join(output_dir, f"debug_page{page_num}.png")
            cv2.imwrite(debug_path, debug_img)
            print(f"Debug image saved to {debug_path}")
    else:
        print(f"No circles detected on page {page_num}")
    
    return extracted


def main():
    # Paths
    base_dir = Path("/Users/ben/code/brimstone/reference")
    tokens_dir = base_dir / "tokens_extracted"
    output_dir = Path("/Users/ben/code/brimstone/app/assets/images/tokens/sidebag")
    
    # Clear output directory
    if output_dir.exists():
        for f in output_dir.glob("*.png"):
            f.unlink()
    
    # Create output directory
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Process each page
    for page_num in [1, 2]:
        page_path = tokens_dir / f"page-{page_num}.png"
        if page_path.exists():
            print(f"\nProcessing {page_path}...")
            extracted = extract_tokens_from_page(
                page_path, 
                str(output_dir), 
                page_num=page_num,
                debug=True
            )
            print(f"Extracted {len(extracted)} tokens from page {page_num}")
        else:
            print(f"Page not found: {page_path}")


if __name__ == "__main__":
    main()
