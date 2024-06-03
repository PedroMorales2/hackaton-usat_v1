import pandas as pd
from pulp import LpMaximize, LpProblem, LpVariable, lpSum

# Supongamos que esta es la carga de datos simulada
profesores = pd.DataFrame({
    'id': [1, 2, 3],
    'nombre': ['Prof. A', 'Prof. B', 'Prof. C'],
    'disponibilidad': [10, 8, 12]  # Horas disponibles para sustentaciones
})

# Función para asignar jurados
def asignar_jurados(profesores, horas_necesarias=30):
    # Modelo de optimización
    model = LpProblem("Asignación_de_Jurados", LpMaximize)

    # Variables de decisión: cada profesor puede ser o no ser asignado como jurado
    x_vars = {row['id']: LpVariable(f"x_{row['id']}", cat='Binary') for index, row in profesores.iterrows()}

    # Función objetivo: maximizar el número de profesores asignados, ponderado por disponibilidad
    model += lpSum(x_vars[i] * profesores.loc[i-1, 'disponibilidad'] for i in x_vars), "Maximizar_Disponibilidad"

    # Restricción de horas necesarias
    model += lpSum(x_vars[i] for i in x_vars) >= 3, "Minimo_Jurados"

    # Solucionar el problema
    model.solve()

    # Resultados
    resultados = {profesores.loc[i-1, 'nombre']: x_vars[i].value() for i in x_vars}
    return resultados

# Llamar a la función
resultado_jurados = asignar_jurados(profesores)
print("Asignación de Jurados:", resultado_jurados)

# Supongamos que tenemos horarios y disponibilidades en formato DataFrame
horarios = pd.DataFrame({
    'sesion_id': [1, 2, 3],
    'horas_necesarias': [2, 2, 2]
})

# Función para generar horarios óptimos
def generar_horarios(horarios, profesores):
    model = LpProblem("Generación_de_Horarios", LpMaximize)

    # Variables de decisión: cada sesión puede ser o no ser asignada a un horario
    y_vars = {row['sesion_id']: LpVariable(f"y_{row['sesion_id']}", cat='Binary') for index, row in horarios.iterrows()}

    # Función objetivo: maximizar la asignación de sesiones
    model += lpSum(y_vars[i] * horarios.loc[i-1, 'horas_necesarias'] for i in y_vars), "Maximizar_Horarios"

    # Solucionar el problema
    model.solve()

    # Resultados
    resultados = {horarios.loc[i-1, 'sesion_id']: y_vars[i].value() for i in y_vars}
    return resultados

# Llamar a la función
resultado_horarios = generar_horarios(horarios, profesores)
print("Horarios Asignados:", resultado_horarios)
