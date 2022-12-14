use std::collections::HashSet;

// utility =====================================================================

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct Vec2 {
    pub x: i32,
    pub y: i32
}

impl Vec2 {
    pub fn new(x: i32, y: i32) -> Self {
        Self{x, y}
    }

    pub fn origin() -> Self {
        Self::new(0, 0)
    }
}

impl std::fmt::Display for Vec2 {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>)
        -> Result<(), std::fmt::Error> {
        write!(f, "({}, {})", self.x, self.y)
    }
}

impl std::ops::Add<Self> for Vec2 {
    type Output = Self;

    fn add(self, rhs: Self) -> Self {
        Vec2::new(self.x + rhs.x, self.y + rhs.y)
    }
}

impl std::ops::Sub<Self> for Vec2 {
    type Output = Self;

    fn sub(self, rhs: Self) -> Self {
        Vec2::new(self.x - rhs.x, self.y - rhs.y)
    }
}

// solution ====================================================================

#[derive(Clone, Copy, Debug)]
enum Dir {
    Left,
    Right,
    Up,
    Down
}

impl From<Dir> for Vec2 {
    fn from(dir: Dir) -> Vec2 {
        match dir {
            Dir::Left => Vec2::new(-1, 0),
            Dir::Right => Vec2::new(1, 0),
            Dir::Up => Vec2::new(0, -1),
            Dir::Down => Vec2::new(0, 1)
        }
    }
}

#[derive(Debug)]
struct RopeState {
    knots: Vec<Vec2>,
    // locations that tail has visited
    visited: HashSet<Vec2>,
}

fn clamp(a: i32, x: i32, b: i32) -> i32 {
    assert_eq!(a <= b, true);

    if a > x {
        a
    } else if b < x {
        b
    } else {
        x
    }
}

fn sim_next_knot(fst: Vec2, snd: Vec2) -> Vec2 {
    let diff = fst - snd;
    if std::cmp::max(i32::abs(diff.x), i32::abs(diff.y)) == 1 {
        // tail doesn't need to move
        snd
    } else {
        // move tail
        snd + Vec2 {
            x: clamp(-1, diff.x, 1),
            y: clamp(-1, diff.y, 1)
        }
    }
}

impl RopeState {
    fn new(n: usize) -> Self {
        let mut knots: Vec<Vec2> = Vec::with_capacity(n);
        for _ in 0..n {
            knots.push(Vec2::origin());
        }

        let mut visited = HashSet::new();
        visited.insert(Vec2::origin());

        Self { knots, visited }
    }

    fn move_in_dir(self, dir: Dir) -> Self {
        let next_knots: Vec<Vec2> = self.knots.iter()
                .enumerate()
                .map(|(i, knot)| if i == 0 {
                    *knot + dir.into()
                } else {
                    sim_next_knot(self.knots[i - 1], *knot)
                })
                .collect();

        // append to visited set
        let mut visited = self.visited;
        visited.insert(*next_knots.last().unwrap());

        Self{ knots: next_knots, visited }
    }

    fn perform(self, instructions: &Vec<(Dir, i32)>) -> Self {
        instructions.iter()
                    .fold(self, |state, (dir, n)| {
                        (0..*n).fold(state, |st, _| st.move_in_dir(*dir))
                    })
    }
}

fn part1(instructions: &Vec<(Dir, i32)>) {
    let final_state = RopeState::new(2).perform(instructions);
    let visited = &final_state.visited;

    println!("part 1) tail visited {} locations", visited.len());
}


fn part2(instructions: &Vec<(Dir, i32)>) {
    let final_state = RopeState::new(10).perform(instructions);
    let visited = &final_state.visited;

    println!("part 2) tail visited {} locations", visited.len());
}

// main ========================================================================

fn get_input_file() -> Result<String, String> {
    let args: Vec<String> = std::env::args().collect();
    if args.len() != 2 {
        return Err("usage: soln [input]".to_string());
    }

    let filename = &args[1];
    match std::fs::read_to_string(filename) {
        Ok(s) => Ok(s),
        Err(_) => Err("could not read input file.".to_string())
    }
}

fn parse_instructions(data: &String) -> Vec<(Dir, i32)> {
    data.split_terminator("\n")
        .map(|line| {
            let op: Vec<&str> = line.split_whitespace().collect();
            assert_eq!(op.len(), 2);

            let dir = match op[0] {
                "L" => Dir::Left,
                "R" => Dir::Right,
                "U" => Dir::Up,
                "D" => Dir::Down,
                _ => panic!("failed to parse a dir")
            };
            let n: i32 = match op[1].parse() {
                Ok(n) => n,
                Err(_) => panic!("failed to parse an int")
            };

            (dir, n)
        })
        .collect()
}

fn main() -> Result<(), String> {
    let data = get_input_file()?;
    let instructions = parse_instructions(&data);

    part1(&instructions);
    part2(&instructions);

    Ok(())
}
