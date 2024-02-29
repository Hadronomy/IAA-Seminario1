import pysmile
import pysmile_license  # noqa: 403
import typer
import pandas as pd
import numpy as np
import warnings
from InquirerPy import inquirer

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


@app.command()
def main():
    """
    Reads the bot model and asks for the evidence of each node
    """
    net = pysmile.Network()
    net.read_file("assets/ModeladoBot.xdsl")
    nodes = net.get_all_nodes()
    for node in nodes:
        if node != 1:
            net = evidence(net, node)

    net.update_beliefs()
    future_probability = np.array(net.get_node_value("future_bot"))
    tags = np.array(net.get_outcome_ids("future_bot"))
    dataframe = pd.DataFrame(future_probability, index=tags, columns=["Probability"])
    sample = dataframe.sample(n=1, weights="Probability")
    next_state = sample.index[0]
    print(f"Next state of the bot: {next_state}")


if __name__ == "__main__":
    with warnings.catch_warnings():
        # Supress all numpy warnings:
        # pysmile is
        warnings.filterwarnings("ignore", module=r"numpy")
        app()
