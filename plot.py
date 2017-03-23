import matplotlib.pyplot as plt
import pandas as pd
plt.style.use('ggplot')

df = pd.read_csv("./data_derived.csv")
df.sort_values('E')
ax = df.plot(x='E', y='recomp/update', kind='bar', title='Streaming Speedup',
            legend=None, color='#5eabed')
ax.set_xlabel('Number of Edges')
ax.set_ylabel('Time to recompute / Time to update')
plt.tight_layout()
# plt.show()
plt.savefig('speedup.plot.pdf')
plt.savefig('speedup.plot.svg')
plt.savefig('speedup.plot.eps')
plt.savefig('speedup.plot.png')
