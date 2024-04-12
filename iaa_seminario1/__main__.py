import os
import pysmile
import typer
import pandas as pd
import numpy as np
import warnings
from enum import Enum
from InquirerPy import inquirer

import iaa_seminario1.license  # noqa: 403

app = typer.Typer()

fullpath = os.path.abspath(__file__)
assets_dir = os.path.join(os.path.dirname(fullpath), "assets")
dataset_path = os.path.join(assets_dir, "dataset.csv")


class BotModel(Enum):
    DEFAULT = "default"
    LEARNING = "learning"


def bot_model_path(value: BotModel):
    if value == BotModel.DEFAULT:
        return os.path.join(assets_dir, "ModeladoBot.xdsl")
    elif value == BotModel.LEARNING:
        return os.path.join(assets_dir, "ModeladoBot-aprendizaje.xdsl")


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
def probabilities(bot_model: BotModel = BotModel.DEFAULT.value):
    """
    Reads the bot model and asks for the evidence of each node
    and then calculates the probability of the next state of the bot
    """
    net = pysmile.Network()
    net.read_file(bot_model_path(bot_model))
    nodes = net.get_all_nodes()
    for node in nodes:
        if node != 1:
            net = evidence(net, node)

    dataframe, next_state = calculate_next_state(net)
    print(dataframe)
    print(f"Next state of the bot: {next_state}")


@app.command()
def tendencies(bot_model: BotModel = BotModel.DEFAULT.value):
    """
    Reads the bot model and calculates the next state of the bot.
    If the next state is the same as the previous state,
    it will count as a repetition, if there are 20 repetitions
    the loop will stop
    """
    net = pysmile.Network()
    net.read_file(bot_model_path(bot_model))
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


@app.command()
def learn(dataset_path: str = dataset_path):
    """
    Reads the dataset and calculates the conditional probabilities
    of the bot model using pandas
    """
    dataset = pd.read_csv(dataset_path)
    sum = dataset.groupby("St").size().sum()
    print(dataset.groupby("St").size() / sum)
    print(dataset.groupby(["St", "st_1"]).size() / dataset.groupby("St").size())
    print(dataset.groupby(["st_1", "H"]).size() / dataset.groupby("st_1").size())
    print(dataset.groupby(["st_1", "HN"]).size() / dataset.groupby("st_1").size())
    print(dataset.groupby(["st_1", "NE"]).size() / dataset.groupby("st_1").size())
    print(dataset.groupby(["st_1", "OW"]).size() / dataset.groupby("st_1").size())
    print(dataset.groupby(["st_1", "PH"]).size() / dataset.groupby("st_1").size())
    print(dataset.groupby(["st_1", "PW"]).size() / dataset.groupby("st_1").size())
    print(dataset.groupby(["st_1", "W"]).size() / dataset.groupby("st_1").size())


def main():
    with warnings.catch_warnings():
        # Supress all numpy warnings:
        # pysmile is setting the smallest_subnormal float64 value to 0
        # which is quite dumb, but we can't do anything about it
        warnings.filterwarnings("ignore", module=r"numpy")
        app()


if __name__ == "__main__":
    main()
