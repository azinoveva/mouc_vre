import gurobipy as gp
from gurobipy import GRB
import matplotlib.pyplot as plt

# Model parameters
units = 10
time = 24

max_power = [455, 455, 130, 130, 162, 80, 85, 55, 55, 55]
a = [16.19, 17.26, 16.6, 16.5, 19.7, 22.26, 27.74, 25.92, 27.27, 27.79]
b = [0.00048, 0.00031, 0.002, 0.00211, 0.00398, 0.00712, 0.000793, 0.00413, 0.002221, 0.00173]
running_cost = [100, 970, 700, 680, 450, 370, 480, 660, 665, 670]
startup_cost = [9000, 10000, 1100, 1120, 1800, 340, 520, 60, 60, 60]
min_uptime = [8, 8, 5, 5, 6, 3, 3, 1, 1, 1]

demand = [700, 750, 850, 950, 1000, 1100, 1150, 1200, 1300, 1400, 1450, 1500, 1400, 1300, 1200, 1150, 1000, 1100, 1200, 1400, 1300, 1100, 900, 800]

model = gp.Model("UC")
model.setParam(GRB.Param.TimeLimit, 100.0)

# Variables
on = model.addVars(units, time, vtype=GRB.BINARY, name="on")
running = model.addVars(units, time, vtype=GRB.BINARY, name="running")
power = model.addVars(units, time, lb=0, name="power")

# Objective function
model.setObjective(gp.quicksum(
    running_cost[u] * running[u, t] +
    startup_cost[u] * (on[u, t]) +
    (a[u] * power[u, t] + b[u] * power[u, t] ** 2)
    for u in range(units) for t in range(time)), GRB.MINIMIZE)

# Constraints
model.addConstrs((power[u, t] <= max_power[u] * running[u, t] for u in range(units) for t in range(time)), name="power_limit")
model.addConstrs((gp.quicksum(power[u, t] for u in range(units)) >= demand[t] for t in range(time)), name="demand")
model.addConstrs((running[u, t] >= on[u, t] for u in range(units) for t in range(time)), name="running_on")
model.addConstrs((gp.quicksum(running[u, t] for t in range(max(0, t - min_uptime[u] + 1), t + 1)) >= min_uptime[u] * on[u, t] for u in range(units) for t in range(time)), name="min_uptime")

model.optimize()

# Plot load per generator
for u in range(units):
    generator_output = [power[u, t].x for t in range(time)]
    plt.plot(generator_output, label=f"Generator {u+1}")
plt.plot(demand, label="Demand", linestyle="--")
plt.xlabel("Time")
plt.ylabel("Power Output")
plt.title("Generator Power Output")
plt.legend()
plt.show()