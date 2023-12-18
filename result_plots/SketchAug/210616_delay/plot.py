from statistics import median
import matplotlib.pyplot as plt
import sys
import data
import bulkreset_data

count = 0

template_list = [
"readC1_%d",
"readD_%d",
"readC2_%d",
"read_total_%d",
"resetC1_%d",
"resetD_%d",
"resetC2_%d",
"reset_total_%d",
"dummy",
]

def get_med(template, array_size):
    attr_name = template % (array_size)
    value1 = getattr(data, attr_name)
    return median(value1)

def get_med_bulk(template, array_size):
    attr_name = template % (array_size)
    value1 = getattr(bulkreset_data, attr_name)
    return median(value1)

def read_total(array_size):
    global template_list
    attr_name = template_list[0] % (array_size)
    value1 = getattr(data, attr_name)
    attr_name = template_list[1] % (array_size)
    value2 = getattr(data, attr_name)
    attr_name = template_list[2] % (array_size)
    value3 = getattr(data, attr_name)
    return median(value1) + median(value2) + median(value3)

def reset_total(array_size):
    global template_list
    attr_name = template_list[4] % (array_size)
    value1 = getattr(data, attr_name)
    attr_name = template_list[5] % (array_size)
    value2 = getattr(data, attr_name)
    attr_name = template_list[6] % (array_size)
    value3 = getattr(data, attr_name)
    return median(value1) + median(value2) + median(value3)

def total_total(array_size):
    global template_list
    attr_name = template_list[0] % (array_size)
    value1 = getattr(data, attr_name)
    attr_name = template_list[1] % (array_size)
    value2 = getattr(data, attr_name)
    attr_name = template_list[2] % (array_size)
    value3 = getattr(data, attr_name)
    attr_name = template_list[4] % (array_size)
    value4 = getattr(data, attr_name)
    attr_name = template_list[5] % (array_size)
    value5 = getattr(data, attr_name)
    attr_name = template_list[6] % (array_size)
    value6 = getattr(data, attr_name)
    return median(value1) + median(value2) + median(value3) + median(value4) + median(value5) + median(value6)

def callback(array_size):
    return get_med("callback_timer_%d", array_size)

def D1(array_size):
    return get_med("readC1_%d", array_size)

def D2(array_size):
    return get_med("readD_%d", array_size)

def D3(array_size):
    return read_total(array_size) + get_med("resetC1_%d", array_size)

def D4(array_size):
    return get_med("resetD_%d", array_size)

def D3P(array_size):
    return callback(array_size) + get_med_bulk("resetC1_%d", array_size)

def D4P(array_size):
    return get_med_bulk("resetD_%d", array_size)

baseline = []
defer = []
bulk_reset = []
sol = []
for array_size in [4096, 8192, 16384, 32768, 65536]:
    baseline.append(D3(array_size))
    defer.append(callback(array_size) + get_med("resetC1_%d", array_size))
    bulk_reset.append(read_total(array_size) + get_med_bulk("resetC1_%d", array_size))
    sol.append(callback(array_size) + get_med_bulk("resetC1_%d", array_size))
    # print(D3(array_size))

print(baseline)
print(defer)
print(bulk_reset)
print(sol)

fig_size = (4, 3)
fig, ax = plt.subplots(figsize=fig_size)

counters = [4096, 8192, 16384, 32768, 65536]
label = ["4K", "8K", "16K", "32K", "64K"]


plt.tick_params(labelsize=12)
plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
plt.xticks(counters, label, rotation='vertical')
ax.set_ylabel('D3 (ms)', fontsize=14)
ax.set_xlabel('counter array size', fontsize=14)

# ax.set_ylim([0, 1000])
# from matplotlib.ticker import MultipleLocator
# ax.yaxis.set_major_locator(MultipleLocator(20))

# ax.set_title('Δt1 - read operation delay\n C++', fontsize=15)
ax.set_title('Solution 3 delay reduction', fontsize=15)

ax.plot(counters, baseline, marker='.', label="D3 baseline", color='C0')
ax.plot(counters, defer, marker='x', label="defer", color='C1')
ax.plot(counters, bulk_reset, marker='^', label="bulk reset", color='C2')
ax.plot(counters, sol, marker='*', label="$D3^{\prime}$ defer + bulk reset", color='C3')

plt.legend(loc = "upper left", fontsize=11)

fig.tight_layout()
plt.savefig("/Users/hnamkung/Desktop/sol3_D3.pdf")
plt.show()



baseline = []
sol = []
for array_size in [4096, 8192, 16384, 32768, 65536]:
    baseline.append(D4(array_size))
    sol.append(D4P(array_size))


fig_size = (4, 3)
fig, ax = plt.subplots(figsize=fig_size)

counters = [4096, 8192, 16384, 32768, 65536]
label = ["4K", "8K", "16K", "32K", "64K"]


plt.tick_params(labelsize=12)
plt.grid(color='gray', linestyle='--', linewidth=1, axis='y')
plt.xticks(counters, label, rotation='vertical')
ax.set_ylabel('D4 (ms)', fontsize=14)
ax.set_xlabel('counter array size', fontsize=14)

# ax.set_ylim([0, 1000])
from matplotlib.ticker import MultipleLocator
ax.yaxis.set_major_locator(MultipleLocator(0.3))

# ax.set_title('Δt1 - read operation delay\n C++', fontsize=15)
ax.set_title('Solution 3 delay reduction', fontsize=15)

ax.plot(counters, baseline, marker='.', label="D4 baseline", color='C0')
ax.plot(counters, sol, marker='*', label="$D4^{\prime}$ bulk reset", color='C3')

plt.legend(loc = "upper left", fontsize=13)

fig.tight_layout()
plt.savefig("/Users/hnamkung/Desktop/sol3_D4.pdf")
plt.show()


