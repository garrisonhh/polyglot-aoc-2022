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
    head: Vec2,
    tail: Vec2,
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

impl RopeState {
    fn new() -> Self {
        let mut state = Self {
            head: Vec2::origin(),
            tail: Vec2::origin(),
            visited: HashSet::new(),
        };

        state.visited.insert(state.tail);

        state
    }

    fn move_in_dir(self, dir: Dir) -> Self {
        let head = self.head + dir.into();
        let diff = head - self.tail;

        let tail = if std::cmp::max(i32::abs(diff.x), i32::abs(diff.y)) == 1 {
            // tail doesn't need to move
            self.tail
        } else {
            // move tail
            self.tail + Vec2 {
                x: clamp(-1, diff.x, 1),
                y: clamp(-1, diff.y, 1)
            }
        };

        // append to visited set
        let mut visited = self.visited;
        visited.insert(tail);

        Self{ head, tail, visited }
    }

    fn perform(self, instructions: &Vec<(Dir, i32)>) -> Self {
        instructions.iter()
                    .fold(self, |state, (dir, n)| {
                        (0..*n).fold(state, |st, _| st.move_in_dir(*dir))
                    })
    }
}

fn part1(instructions: &Vec<(Dir, i32)>) {
    let final_state = RopeState::new().perform(instructions);
    let visited = &final_state.visited;

    println!("part 1) tail visited {} locations", visited.len());
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

    Ok(())
}
