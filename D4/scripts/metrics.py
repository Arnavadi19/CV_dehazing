import numpy as np
import argparse
import matplotlib.pyplot as plt

from glob import glob
from ntpath import basename
from imageio import imread
from skimage.metrics import structural_similarity as compare_ssim
from skimage.metrics import peak_signal_noise_ratio as compare_psnr
from skimage.color import rgb2gray


def parse_args():
    parser = argparse.ArgumentParser(description='script to compute all statistics')
    parser.add_argument('--data-path', help='Path to ground truth data', type=str)
    parser.add_argument('--output-path', help='Path to output data', type=str)
    parser.add_argument('--debug', default=0, help='Debug', type=int)
    args = parser.parse_args()
    return args


def compare_mae(img_true, img_test):
    img_true = img_true.astype(np.float32)
    img_test = img_test.astype(np.float32)
    return np.sum(np.abs(img_true - img_test)) / np.sum(img_true + img_test)


args = parse_args()
for arg in vars(args):
    print('[%s] =' % arg, getattr(args, arg))

path_true = args.data_path
path_pred = args.output_path

psnr = []
ssim = []
mae = []
names = []
index = 1

files = list(glob(path_true + '/*.jpg')) + list(glob(path_true + '/*.png'))
for fn in sorted(files):
    name = basename(str(fn))
    names.append(name)

    img_gt = (imread(str(fn)) / 255.0).astype(np.float32)
    print('gt ',str(fn))
    print('pred ', path_pred + basename(str(fn)[:-4]+'.png'))
    img_pred = (imread(path_pred + basename(str(fn)[:-4]+'.png')) / 255.0).astype(np.float32)

    img_gt = rgb2gray(img_gt)
    img_pred = rgb2gray(img_pred)

    if args.debug != 0:
        plt.subplot('121')
        plt.imshow(img_gt)
        plt.title('Groud truth')
        plt.subplot('122')
        plt.imshow(img_pred)
        plt.title('Output')
        plt.show()


    diff = imread(str(fn)).astype(np.float32) - imread(path_pred + basename(str(fn)[:-4]+'.png')).astype(np.float32)
    mse = np.mean(np.square(diff))
    mae_temp = np.mean(np.abs(diff)/255)
    psnr_temp = 10 * np.log10(255 * 255 / mse)


    psnr.append(psnr_temp)
    ssim.append(compare_ssim(img_gt, img_pred, data_range=1, win_size=51))
    mae.append(mae_temp)
    print(psnr_temp)
    if np.mod(index, 100) == 0:
        print(
            str(index) + ' images processed',
            "PSNR: %.4f" % round(np.mean(psnr), 4),
            "SSIM: %.4f" % round(np.mean(ssim), 4),
            "MAE: %.4f" % round(np.mean(mae), 4),
        )
    index += 1

np.savez(args.output_path + '/metrics.npz', psnr=psnr, ssim=ssim, mae=mae, names=names)
print(
    "PSNR: %.4f" % round(np.mean(psnr), 4),
    "PSNR Variance: %.4f" % round(np.var(psnr), 4),
    "SSIM: %.4f" % round(np.mean(ssim), 4),
    "SSIM Variance: %.4f" % round(np.var(ssim), 4),
    "MAE: %.4f" % round(np.mean(mae), 4),
    "MAE Variance: %.4f" % round(np.var(mae), 4)
)
