#!/usr/bin/env python

# run with input file as first argument.

from sys import argv

def main():
    # read text
    with open(argv[1], 'r') as f:
        text = f.read()

    # format data into `Iterable (Option Int)` where None is newline
    data = map(
        lambda e: int(e) if len(e) else None,
        text.split('\n')
    )

    # collect inventories
    inventories = []
    running = []
    for x in data:
        if x == None:
            inventories.append(running)
            running = []
        else:
            running.append(x)

    if len(running) > 0:
        inventories.append(running)

    inventory_calories = list(map(sum, inventories))
    inventory_calories.sort(reverse=True)

    # display
    print(f"part 1) max calories: {inventory_calories[0]}")
    print(f"part 2) top 3 calories: {sum(inventory_calories[:3])}")

if __name__ == "__main__":
    main()