import os
import cv2
import numpy as np
from PIL import Image
from keras.applications.mobilenet_v2 import preprocess_input
from keras.models import load_model
from keras.preprocessing.image import img_to_array
import shutil
import imagehash

# Load aesthetic model (you can use NIMA or MobileNetV2 variant)
# We'll simulate a dummy aesthetic score here to simplify
def aesthetic_score(image):
    # Placeholder: return a random score between 5 and 10
    return np.random.uniform(5.0, 10.0)

def variance_of_laplacian(image):
    # Sharpness estimator using Laplacian variance
    return cv2.Laplacian(image, cv2.CV_64F).var()

def average_brightness(image):
    # Convert to grayscale and compute mean brightness
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    return np.mean(gray)

def is_duplicate(img_hash, existing_hashes):
    return img_hash in existing_hashes

def process_images(input_folder, output_folder, top_n=10):
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    scores = []
    image_hashes = set()

    for filename in os.listdir(input_folder):
        if not filename.lower().endswith(('.jpg', '.jpeg', '.png')):
            continue
        path = os.path.join(input_folder, filename)
        try:
            pil_img = Image.open(path).convert('RGB')
            img_cv = cv2.imread(path)

            # Skip if unreadable
            if img_cv is None:
                continue

            # Skip duplicates
            hash_val = str(imagehash.phash(pil_img))
            if is_duplicate(hash_val, image_hashes):
                continue
            image_hashes.add(hash_val)

            # Quality scores
            sharpness = variance_of_laplacian(img_cv)
            brightness = average_brightness(img_cv)
            aesthetic = aesthetic_score(pil_img)

            # Combine scores (you can weight them differently)
            final_score = (
                (sharpness / 1000.0) * 0.4 +
                (brightness / 255.0) * 0.2 +
                (aesthetic / 10.0) * 0.4
            )

            scores.append((final_score, path))
        except Exception as e:
            print(f"Error processing {filename}: {e}")

    # Sort and copy top images
    scores.sort(reverse=True)
    for i, (_, img_path) in enumerate(scores[:top_n]):
        dest_path = os.path.join(output_folder, f"top_{i+1}_" + os.path.basename(img_path))
        shutil.copy(img_path, dest_path)

    print(f"\nSelected top {top_n} images saved to: {output_folder}")

if __name__ == "__main__":
    input_dir = "your_photo_folder"      # 🔁 Change this to your photo folder
    output_dir = "best_photos"           # Where to save best photos
    top_n_photos = 10                    # Number of top photos to select

    process_images(input_dir, output_dir, top_n=top_n_photos)
