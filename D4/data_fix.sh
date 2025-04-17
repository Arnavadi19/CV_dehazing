# Step 1: Create directory if it doesn't exist
mkdir -p /home/arnav/CVproj/RESIDE-6K/test/GT_renamed

# Step 2: Process all GT images (this part worked fine)
for file in /home/arnav/CVproj/RESIDE-6K/test/GT/*.jpg; do
  # Extract just the numeric prefix (more robust method)
  prefix=$(basename "$file" | grep -o '^[0-9]\+')
  
  echo "Converting $file to ${prefix}.png"
  convert "$file" "/home/arnav/CVproj/RESIDE-6K/test/GT_renamed/${prefix}.png"
done

# Step 3: Fixed script to check for missing files
python -c "
import json
import os

# Properly read the file list
with open('/home/arnav/CVproj/D4/datasets/reside6k_test_hazy.flist', 'r') as f:
    content = f.read()
    f.seek(0)
    if content.startswith('['):
        hazy_files = json.load(f)
    else:
        hazy_files = [line.strip() for line in f.readlines()]

# Check each hazy file for its clean counterpart
for path in hazy_files:
    prefix = os.path.basename(path).split('_')[0]
    clean_path = f'/home/arnav/CVproj/RESIDE-6K/test/GT_renamed/{prefix}.png'
    if not os.path.exists(clean_path):
        print(f'Missing clean image for: {path} (needs {prefix}.png)')
"