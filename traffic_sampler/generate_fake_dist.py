import os
import numpy as np
import powerlaw

def generate_power_law_data(alpha, xmin, size):
    # Generate flow sizes following a power-law distribution
    flow_sizes = powerlaw.Power_Law(xmin=xmin, parameters=[alpha]).generate_random(size)

    # Convert flow sizes to integers (representing the number of packets in each flow)
    flow_sizes = np.ceil(flow_sizes).astype(int)

    # Calculate the frequency of each flow size
    unique_flow_sizes, counts = np.unique(flow_sizes, return_counts=True)

    # Create a dataset of (flow_size, frequency) pairs
    dataset = list(zip(unique_flow_sizes, counts))

    return dataset

def write_file(flow_sizes, frequencies, fileName):
    print("write flow size distribution to ", fileName)
    with open(fileName, 'w') as file:
        for i in range(len(flow_sizes)):
            file.write(f'{flow_sizes[i]} {frequencies[i]}\n')

if __name__ == "__main__":
    # Parameters for the power-law distribution
    alpha = 2.5  # Power-law exponent
    xmin = 0.5     # Minimum value for flow sizes

    # Generate synthetic dataset
    synthetic_dataset = generate_power_law_data(alpha, xmin, size=1000000)

    # print(synthetic_dataset)
    print("synthetic_total_packets: ", sum(x * y for x,y in synthetic_dataset))

    # Unpack the synthetic dataset into separate lists
    flow_sizes, frequencies = zip(*synthetic_dataset)

    # write file
    output_file = os.getenv("traffic_sampler") + "/fs_dist/fake_dist.txt"
    write_file(flow_sizes, frequencies, output_file)