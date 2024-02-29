import pysmile;
import pysmile_license;
import typer;

app = typer.Typer();

def evidence(net, node):
    ids = net.get_outcome_ids(node);
    name = net.get_node_name(node);
    print(f"Introduce el estado del bot en {name}:", ids);
    selection = input();
    if selection in ids:
        net.set_evidence(node, selection);
    return net;

@app.command()
def main():
    net = pysmile.Network();
    net.read_file("assets/ModeladoBot.xdsl");
    net.get_outcome_ids
    nodes = net.get_all_nodes();
    for node in nodes:
        if node != 1:
            net = evidence(net, node);

    net.update_beliefs();
    print(net.get_node_value("future_bot"));

if __name__ == "__main__":
    app();
