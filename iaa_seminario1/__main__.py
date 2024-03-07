import pysmile
import typer
import pandas as pd
import numpy as np
import warnings
from InquirerPy import inquirer

import iaa_seminario1.license  # noqa: 403

app = typer.Typer()


def evidence(net, node):
    ids = net.get_outcome_ids(node)
    name = net.get_node_name(node)
    selection = inquirer.select(
        f'Introduce el estado del bot en "{name}":', choices=ids, default=None
    ).execute()
    if selection in ids:
        net.set_evidence(node, selection)
    return net


def calculate_next_state(net):
    net.update_beliefs()
    future_probability = np.array(net.get_node_value("future_bot"))
    tags = np.array(net.get_outcome_ids("future_bot"))
    dataframe = pd.DataFrame(future_probability, index=tags, columns=["Probability"])
    sample = dataframe.sample(n=1, weights="Probability")
    next_state = sample.index[0]
    return dataframe, next_state


@app.command()
def probabilities():
    """
    Reads the bot model and asks for the evidence of each node
    and then calculates the probability of the next state of the bot
    """
    net = pysmile.Network()
    net.read_file("assets/ModeladoBot.xdsl")
    nodes = net.get_all_nodes()
    for node in nodes:
        if node != 1:
            net = evidence(net, node)

    dataframe, next_state = calculate_next_state(net)
    print(dataframe)
    print(f"Next state of the bot: {next_state}")


@app.command()
def tendencies():
    net = pysmile.Network()
    net.read_file("assets/ModeladoBot.xdsl")
    states = {
        2: "Alta",
        3: "Armado",
        4: "Si",
        5: "Si",
        6: "Si",
        7: "Si",
        8: "Si",
    }
    total_iterations = 0
    repetitions_counter = 0
    previous_state = None
    states[0] = "huir"
    while repetitions_counter < 20:
        for node in states:
            net.set_evidence(node, states[node])
        dataframe, next_state = calculate_next_state(net)
        next_current_state_map = {
            "buscar_armas": "recoger_arma",
            "buscar_energia": "recoger_energía",
        }
        next_state = (
            next_current_state_map[next_state]
            if next_state in next_current_state_map
            else next_state
        )
        print(f"📝 Iteration: {total_iterations}")
        print(f"Current state of the bot: {states[0]}\n")
        print(dataframe)
        print(f"\nNext state of the bot: {next_state}")
        print("----------------------------------------------")
        if previous_state == next_state:
            repetitions_counter += 1
        else:
            repetitions_counter = 0
        previous_state = next_state
        states[0] = next_state
        total_iterations += 1


def main():
    with warnings.catch_warnings():
        # Supress all numpy warnings:
        # pysmile is setting the smallest_subnormal float64 value to 0
        # which is quite dumb, but we can't do anything about it
        warnings.filterwarnings("ignore", module=r"numpy")
        app()


if __name__ == "__main__":
    main()
