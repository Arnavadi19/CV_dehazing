# Create directory for renamed GT images
mkdir -p /home/arnav/CVproj/RESIDE-6K/train/GT_renamed

# Process all GT training images with the correct naming format
for file in /home/arnav/CVproj/RESIDE-6K/train/GT/*.jpg; do
  # Extract just the numeric part without extension
  basename=$(basename "$file")
  filename="${basename%.*}"  # Remove the extension
  
  echo "Converting $file to ${filename}.png"
  convert "$file" "/home/arnav/CVproj/RESIDE-6K/train/GT_renamed/${filename}.png"
done