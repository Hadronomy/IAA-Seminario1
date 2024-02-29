import pysmile
import pysmile_license

def evidence(net, node):
    ids = net.get_outcome_id(node)
    print("Introduce el estado del bot en ", node, ":", ids)
    selection = input()
    if selection in ids:
        net.set_evidence(selection)
    return net

def hello_smile():
    net = pysmile.Network()
    net.read_file("./bot.xdsl")

    nodes = net.get_all_nodes()
    for node in nodes:
        if node is not "future_bot":
            net = evidence(net, node)

    net.update_beliefs()
    print(net.get_node_value("future_bot"))
    # net.set_evidence("St", "huir")
    # net.update_beliefs()

hello_smile()
