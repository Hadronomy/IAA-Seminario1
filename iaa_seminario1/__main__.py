import pysmile
import pysmile_license  # noqa: 403
import typer
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
    print(net.get_node_value("future_bot"))


if __name__ == "__main__":
    app()
