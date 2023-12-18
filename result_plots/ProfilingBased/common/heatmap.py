import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import matplotlib.colors as mcolors
from matplotlib import cm
import numpy as np
import os

def plot_heatmap(error_reductions, ytick_labels, xtick_labels, title="Error reduction", isSaveFig = False, output_dir = './test'):
#     ytick_labels = ["caida", "uniform", "zipf"]
#     xtick_labels = ["caida", "uniform", "zipf"]

#     error_reductions = np.array([[55, 59, 62, ],
#                         [-10, 95, 80, ],
#                         [35, 95, 99, ]])

    ### https://matplotlib.org/3.1.0/tutorials/colors/colormap-manipulation.html
    # create color maps
    top = cm.get_cmap('Oranges_r', 128)
    bottom = cm.get_cmap('Blues', 128)
    colors = np.vstack((top(np.linspace(0, 1, 128)),
                           bottom(np.linspace(0, 1, 128))))
    cmp = mcolors.ListedColormap(colors, name='OrangeBlue')

    ### Creating annotated heatmaps
    ### https://matplotlib.org/stable/gallery/images_contours_and_fields/image_annotated_heatmap.html

    fig, ax = plt.subplots(figsize = (10, 6))
    im = ax.imshow(error_reductions, cmap=cmp, vmin=-100, vmax=100)

    # Show all ticks and label them with the respective list entries
    ax.set_xticks(np.arange(len(xtick_labels)), labels=xtick_labels, size=22)
    ax.set_yticks(np.arange(len(ytick_labels)), labels=ytick_labels, size=22)

    # # Rotate the tick labels and set their alignment.
    # plt.setp(ax.get_xticklabels(), rotation=45, ha="right",
    #          rotation_mode="anchor")

    # Loop over data dimensions and create text annotations.
    for i in range(len(ytick_labels)):
        for j in range(len(xtick_labels)):
            text_color = 'white'
            if error_reductions[i, j] < 40 and error_reductions[i, j] > -40:
                text_color = 'black'
            text = ax.text(j, i, f"{error_reductions[i, j]:.2f}",
                           ha="center", va="center", color=text_color, size=20) # 22 for 3x3, 20 for 5x5

    # ax.set_title(f"{title}", size=18)
    ax.set_ylabel("Profiles", size=22) # 24 for 3x3, 22 for 5x5
    ax.set_xlabel("Testing sets", size=22) # 24 for 3x3, 22 for 5x5

    cbar = fig.colorbar(im)
    cbar.ax.tick_params(labelsize=22)
    
    filename = title.split(' ')[0]
    if isSaveFig:
        if not os.path.exists(f'{output_dir}/heatmap/'):
            os.makedirs(f'{output_dir}/heatmap/')
        plt.savefig(f'{output_dir}/heatmap/{filename}.pdf', format='pdf', bbox_inches='tight')

    fig.tight_layout()
    plt.show()


def plot_selection_table(texts, ytick_labels, xtick_labels, title="Algo. select", isSaveFig = False, output_dir = './test'):
    
    zero_vals = np.zeros(texts.shape)

    ### Creating annotated heatmaps
    ### https://matplotlib.org/stable/gallery/images_contours_and_fields/image_annotated_heatmap.html

    fig, ax = plt.subplots(figsize = (10, 6))
    im = ax.imshow(zero_vals, cmap='binary')

    # Show all ticks and label them with the respective list entries
    ax.set_xticks(np.arange(len(xtick_labels)), labels=xtick_labels, size=18)
    ax.set_yticks(np.arange(len(ytick_labels)), labels=ytick_labels, size=18)

    # Loop over data dimensions and create text annotations.
    for i in range(len(ytick_labels)):
        for j in range(len(xtick_labels)):
            text_color = 'black'
            text = ax.text(j, i, f"{texts[i, j]}",
                           ha="center", va="center", color=text_color, size=18)

    ax.set_title(f"{title}", size=18)
    ax.set_ylabel("training sets", size=18)
    ax.set_xlabel("testing sets", size=18)

    fig.tight_layout()
    plt.show()