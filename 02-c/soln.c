#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

// returns owned string
char *readFile(const char *filename) {
    FILE *fp = fopen(filename, "r");
    if (!fp) goto err;

    // find length of str
    if (fseek(fp, 0, SEEK_END)) goto err;
    size_t length = ftell(fp);
    rewind(fp);

    // read file
    char *str = malloc((length + 1) * sizeof(*str));
    fread(str, sizeof(*str), length, fp);
    str[length] = 0;

    if (ferror(fp)) goto err;

    fclose(fp);
    return str;

err:
    fprintf(stderr, "error: could not read file at '%s'\n", filename);
    exit(1);
}

#define CHOICES_X\
    X(ROCK)\
    X(PAPER)\
    X(SCISSORS)

#define X(A) A,
typedef enum Choice { CHOICES_X CHOICE_COUNT} Choice;
#undef X

#define X(A) #A,
const char *CHOICE_NAME[CHOICE_COUNT] = { CHOICES_X };
#undef X

// returns player score for this round
int scoreRound(Choice opponent, Choice player) {
    // score of choice
    int score = player + 1;

    if (player == opponent) {
        // tie
        score += 3;
    } else if (player == (opponent + 1) % 3) {
        // player wins
        score += 6;
    }

    return score;
}

// outputs next round into out vars, modifies string to point to next line
// returns false when game completes
bool nextRound(char **str, char *o_opponent, char *o_player) {
    // check for end of game; iterate
    char *line = *str;
    if (!*line) return false;
    *str += 4;

    // output
    *o_opponent = line[0];
    *o_player = line[2];

    return true;
}

// nextRound() with part 1's assumptions
bool part1NextRound(char **str, Choice *o_opponent, Choice *o_player) {
    char opponent, player;
    bool res = nextRound(str, &opponent, &player);

    if (res) {
        *o_opponent = opponent - 'A';
        *o_player = player - 'X';
    }

    return res;
}

void part1(char *data) {
    int score = 0;
    Choice opponent, player;

    while (part1NextRound(&data, &opponent, &player)) {
        score += scoreRound(opponent, player);
#if 0
        printf("%s vs. %s\n", CHOICE_NAME[opponent], CHOICE_NAME[player]);
        printf("current score: %d\n", score);
#endif
    }

    printf("part 1) final score: %d\n", score);
}

void part2(char *data) {
    int score = 0;
    char a, b;

    while (nextRound(&data, &a, &b)) {
        Choice opponent = a - 'A';

        // strategy decision
        Choice player;
        switch (b) {
        case 'X':
            // lose
            player = (opponent + 2) % 3;
            break;
        case 'Y':
            // draw
            player = opponent;
            break;
        case 'Z':
            // win
            player = (opponent + 1) % 3;
            break;
        }

        score += scoreRound(opponent, player);
    }

    printf("part 2) final score: %d\n", score);
}

int main(int argc, char **argv) {
    char *data = readFile(argv[1]);

    part1(data);
    part2(data);

    free(data);
    return 0;
}