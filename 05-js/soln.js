const { readFileSync } = require('fs');

// solution ====================================================================

// returns { state, proc } where state is a list of N stacks of letters, and
// proc is a list of lists of 3 numbers
function interpretInstructions(str) {
    // get lines for the starting state and the instructions
    const lines = str.split('\n');
    const isEmpty = line => line.length == 0;
    const firstEmpty = lines.findIndex(isEmpty);

    const numCrateStacks = [...lines[firstEmpty - 1].matchAll(/\d+/g)].length
    const stateLines = lines.slice(0, firstEmpty - 1);
    const procLines = lines
            .slice(firstEmpty + 1)
            .filter(x => !isEmpty(x));

    // parse state
    const state = new Array(numCrateStacks).fill(0).map(_ => []);

    stateLines.reverse().forEach(line => {
        // get crates for this line
        const crates = []; // array of null | string
        while (line.length >= 3) {
            const crate = line[1];
            crates.push(crate !== ' ' ? crate : null);
            line = line.slice(4);
        }

        // add crates to state
        crates.forEach((crate, i) => {
            if (crate) {
                state[i].push(crate);
            }
        });
    })

    // parse proc
    const proc = procLines.map(s => {
        const arr = [...s.matchAll(/\d+/g)]
                .map(match => parseInt(match[0]));

        // make indices zero-indexed
        --arr[1];
        --arr[2];

        return arr;
    });

    return { state, proc }
}

function copyState(state) {
    return state.map(arr => arr.map(x => x));
}

function topOfStacks(state) {
    return state.map(stk => stk[stk.length - 1]).join("");
}

function printState(state) {
    state.forEach((stack, i) => {
        console.log(`${i + 1}: [${stack}]`);
    });
}

function printInstructions({ state, proc }) {
    console.log("[instructions]");
    console.log("state:");
    printState(state);
    console.log("proc:");
    proc.forEach(([a, b, c]) => {
        console.log(`move ${a} from ${b + 1} to ${c + 1}`);
    });
}

function part1({ state, proc }) {
    state = copyState(state);

    for (const [n, from, to] of proc) {
        for (let i = 0; i < n; ++i) {
            state[to].push(state[from].pop())
        }
    }

    console.log(`part 1) result: ${topOfStacks(state)}`);
    console.log("final state:");
    printState(state);
}

function part2({ state, proc }) {
    state = copyState(state);

    for (const [n, from, to] of proc) {
        state[to] = state[to].concat(state[from].slice(-n));
        state[from] = state[from].slice(0, -n);
    }

    console.log(`part 2) result: ${topOfStacks(state)}`);
    console.log("final state:");
    printState(state);
}

// main ========================================================================

function readFile(filename) {
    try {
        return readFileSync(filename).toString();
    } catch (e) {
        errorExit(e);
    }
}

function errorExit(msg) {
    console.error(msg);
    process.exit(1);
}

function main() {
    // handle args
    if (process.argv.length != 3) {
        errorExit("usage: node soln.js [filename]");
    }

    const filename = process.argv[2];
    const str = readFile(filename);

    // solution
    const crate_procedure = interpretInstructions(str);
    part1(crate_procedure);
    part2(crate_procedure);
}

main()