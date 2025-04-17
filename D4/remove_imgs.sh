# Step 1: Create a filtered flist that excludes problematic images for BOTH datasets
python -c "
import numpy as np
import os
import json

# Process hazy flist first
hazy_path = '/home/arnav/CVproj/D4/datasets/reside6k_test_hazy.flist'
with open(hazy_path, 'r') as f:
    content = f.read()
    f.seek(0)
    if content.startswith('['):
        hazy_files = json.load(f)
    else:
        hazy_files = [line.strip() for line in f.readlines()]

# Filter out problematic images (those with filenames starting with '14')
filtered_hazy = []
removed_prefixes = set()

for path in hazy_files:
    basename = os.path.basename(path)
    prefix = basename.split('_')[0]
    
    if prefix.startswith('14'):
        removed_prefixes.add(prefix)
        continue
    
    filtered_hazy.append(path)

print(f'Removed {len(hazy_files) - len(filtered_hazy)} hazy images with prefixes: {sorted(list(removed_prefixes))}')

# Save filtered hazy list
filtered_hazy_path = '/home/arnav/CVproj/D4/datasets/reside6k_test_hazy_filtered.flist'
with open(filtered_hazy_path, 'w') as f:
    if isinstance(hazy_files[0], str) and not content.startswith('['):
        f.write('\n'.join(filtered_hazy))
    else:
        json.dump(filtered_hazy, f)

print(f'Created filtered hazy flist at {filtered_hazy_path}')

# Also filter the clean flist if it exists
try:
    clean_path = '/home/arnav/CVproj/D4/datasets/reside6k_test_clean.flist'
    if os.path.exists(clean_path):
        with open(clean_path, 'r') as f:
            content = f.read()
            f.seek(0)
            if content.startswith('['):
                clean_files = json.load(f)
            else:
                clean_files = [line.strip() for line in f.readlines()]
                
        filtered_clean = []
        for path in clean_files:
            basename = os.path.basename(path)
            prefix = basename.split('.')[0] if '.' in basename else basename
            
            if prefix.startswith('14') or prefix in removed_prefixes:
                continue
                
            filtered_clean.append(path)
            
        filtered_clean_path = '/home/arnav/CVproj/D4/datasets/reside6k_test_clean_filtered.flist'
        with open(filtered_clean_path, 'w') as f:
            if isinstance(clean_files[0], str) and not content.startswith('['):
                f.write('\n'.join(filtered_clean))
            else:
                json.dump(filtered_clean, f)
                
        print(f'Created filtered clean flist at {filtered_clean_path}')
        
        # Update config file to use both filtered lists
        config_path = '/home/arnav/CVproj/D4/checkpoints/reside6k_test/config.yml'
        with open(config_path, 'r') as f:
            config = f.read()
            
        config = config.replace('reside6k_test_hazy.flist', 'reside6k_test_hazy_filtered.flist')
        config = config.replace('reside6k_test_clean.flist', 'reside6k_test_clean_filtered.flist')
        
        with open(config_path, 'w') as f:
            f.write(config)
except Exception as e:
    print(f'Note: Could not process clean flist: {str(e)}')
"