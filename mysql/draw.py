import re
import argparse
import matplotlib.pyplot as plt
import numpy as np

def extract_floats(filename):
    floats = []
    with open(filename, 'r') as file:
        for line in file:
            if "modified" in line and "about" in line:
                words = line.split()
                if len(words) >= 10:
                    try:
                        floats.append(float(words[9]))
                    except ValueError:
                        continue
    return floats

def remove_outliers(data):
    mean = np.mean(data)
    std_dev = np.std(data)
    filtered_data = [x for x in data if (mean - 3 * std_dev <= x <= mean + 3 * std_dev)]
    return filtered_data

def plot_floats(file1, file2, output_file):
    floats1 = extract_floats(file1)
    floats2 = extract_floats(file2)
    
    floats1 = remove_outliers(floats1)
    floats2 = remove_outliers(floats2)
    
    # floats1 = floats1[1000:]
    # floats2 = floats2[1000:]
    
    # Output the mean and standard deviation of the floats
    print("Mean of floats from new.txt: ", np.mean(floats1))
    print("Standard deviation of floats from new.txt: ", np.std(floats1))
    print("Mean of floats from old.txt: ", np.mean(floats2))
    print("Standard deviation of floats from old.txt: ", np.std(floats2))
    
    plt.scatter(range(len(floats1)), floats1, label='new', s=5)  # s=10 to reduce point size
    plt.scatter(range(len(floats2)), floats2, label='old', s=5)  # s=10 to reduce point size
    
    plt.xlabel('Times')
    plt.ylabel('Latency (us)')
    plt.title('End to End Latency of New Version vs Old Version')
    plt.legend()
    
    plt.savefig(output_file)
    plt.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Plot floats from two log files.')
    parser.add_argument('file1', type=str, help='First log file')
    parser.add_argument('file2', type=str, help='Second log file')
    parser.add_argument('output_file', type=str, help='Output image file')
    
    args = parser.parse_args()
    
    plot_floats(args.file1, args.file2, args.output_file)