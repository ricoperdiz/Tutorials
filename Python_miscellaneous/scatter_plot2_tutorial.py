import numpy as np
import matplotlib.pyplot as plt

# Create data
N = 60
g1 = (0.6 + 0.6 * np.random.rand(N), np.random.rand(N))
g2 = (0.4 + 0.3 * np.random.rand(N), 0.5 * np.random.rand(N))
g3 = (0.3 * np.random.rand(N), 0.3 * np.random.rand(N))

data = (g1, g2, g3)
print(data)
colors = ("red", "green", "blue")
colors
groups = ("coffee", "tea", "water")
groups

# Create plot
fig = plt.figure()
# ax = fig.add_subplot(1, 1, 1, facecolor="1.0")
ax = fig.add_subplot(1, 1, 1, facecolor="green")

for data, color, group in zip(data, colors, groups):
    x, y = data
    ax.scatter(x, y, alpha = 0.8, c = color, edgecolors = 'none', s = 30, label = group)

plt.title('Matplot scatter plot')
plt.legend(loc = "upper left")
plt.show()
