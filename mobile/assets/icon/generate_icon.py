"""One-off script to draw the NovaLearn app icon (not part of the app build).

Reuses the sparkle motif already shown on the sign-in screen (Icons.auto_awesome) on the app's
brand purple (AppTheme.seed, 0xff6246ea), so the icon matches the in-app visual identity rather
than introducing an unrelated symbol. Generates a single 1024x1024 master PNG; flutter_launcher_icons
derives every platform-specific size from it.
"""
import math

from PIL import Image, ImageDraw

SIZE = 1024
BRAND_PURPLE = (98, 70, 234, 255)  # 0xff6246ea
WHITE = (255, 255, 255, 255)


def four_point_star(cx, cy, outer_r, inner_r, rotation_deg=0):
    points = []
    for i in range(8):
        angle = math.radians(i * 45 + rotation_deg)
        r = outer_r if i % 2 == 0 else inner_r
        points.append((cx + r * math.sin(angle), cy - r * math.cos(angle)))
    return points


img = Image.new("RGBA", (SIZE, SIZE), BRAND_PURPLE)
draw = ImageDraw.Draw(img)

center = SIZE / 2
main_star = four_point_star(center, center, outer_r=SIZE * 0.34, inner_r=SIZE * 0.11)
draw.polygon(main_star, fill=WHITE)

small_cx, small_cy = SIZE * 0.72, SIZE * 0.28
small_star = four_point_star(small_cx, small_cy, outer_r=SIZE * 0.085, inner_r=SIZE * 0.03)
draw.polygon(small_star, fill=WHITE)

img.save("icon.png")
print("wrote icon.png", img.size)
