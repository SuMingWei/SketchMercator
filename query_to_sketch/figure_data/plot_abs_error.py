import sys
import json
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

num_ensembles = 6
num_solutions = 5

plt.rcParams.update({'font.size':36})

def get_labels():
    metrics = ['F', 'D', 'H', 'C', 'E']
    order = ['H', 'D', 'E', 'C', 'F']

    labels = []
    for m in metrics:
        label = [o for o in order if o != m]
        label = '-'.join(label)
        labels.append(label)
    labels.append('-'.join(order))
    return labels

def get_solution_names():
    return ['Random-Uniform', 'Random-Proportional', 'Lazy-Uniform', 'Lazy-Proportional', 'SketchMercator']

def get_x_position(num_metric, num_solution):
    ll = []
    for i in range(num_metric):
        padding = i * num_solution + 1
        val = -0.4
        for j in range(num_solution):
            val += 0.6
            ll.append(padding + val)
    return ll

def main(file_name):
    data = json.load(open(file_name))
    colors = ['deeppink', 'darkred', 'royalblue', 'darkblue', 'green']
    colors = colors[:num_solutions]
    colors = colors * num_ensembles
    
    #fig = plt.figure(figsize = (10, 6))
    fig, ax = plt.subplots()
    #ax = fig.add_axes([0, 0, 1, 1])
    ax.set_ylim([0, 105])

    bplot = ax.boxplot(data, patch_artist=True, positions=get_x_position(num_ensembles, num_solutions))

    for p,c in zip(bplot['boxes'], colors):
        p.set_facecolor(c)

    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)

    ax.set_ylabel('Absolute error (%)')
    ax.set_xlabel('Ensembles of metrics')

    offset = 0 if num_solutions % 2 == 0 else 0.4
    ax.set_xticks([offset+num_solutions/2+num_solutions*i for i in range(num_ensembles)], labels=get_labels())
    ax.set_yticks(range(0, 110, 20), labels=range(0, 110, 20))
    legends = [mpatches.Patch(color=c, label=name) for c, name in zip(colors[:num_solutions], get_solution_names())]
    ax.legend(handles=legends, fontsize=24, bbox_to_anchor=(0.95, 1.14), loc='upper right')
    #ax.set_title('Absolute errors of SketchMercator and strawman approaches', fontsize=36)
    plt.grid()
    plt.show()

if __name__ == '__main__':
    file_name = sys.argv[1]
    main(file_name)
