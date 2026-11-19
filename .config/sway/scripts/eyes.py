#!/usr/bin/env python3

import curses
import locale
import random
import time

W, H = 57, 23
CX, CY = W // 2, H // 2
HALF_W = CX - 1
APEX = 10
IRIS_R = 7
PUPIL_R = 3
BLINK_APEX = 1
BLINK_CHANCE = 0.40
FILL = "\u2588"

GAZE = {
    "center": (0, 0),
    "left": (0, -1),
    "right": (0, 1),
    "up": (-1, 0),
    "down": (1, 0),
}

GREEN, WHITE, RED, STAR = 1, 2, 3, 4

STARS = [".", ".", "*", "+", "\u00b7"]


def build_grid(state):
    grid = [[(" ", 0) for _ in range(W)] for _ in range(H)]
    apex = BLINK_APEX if state == "blink" else APEX

    for x in range(1, W - 1):
        h = _half(x, apex)
        for y in range(CY - h + 1, CY + h):
            grid[y][x] = (FILL, WHITE)

    for x in range(1, W - 1):
        h = _half(x, apex)
        if h == 0:
            grid[CY][x] = (".", GREEN)
            continue
        prev = _half(x - 1, apex)
        for y, is_top in ((CY - h, True), (CY + h, False)):
            if h == prev:
                ch = "-"
            elif h > prev:
                ch = "/" if is_top else "\\"
            else:
                ch = "\\" if is_top else "/"
            grid[y][x] = (ch, GREEN)

    if state == "blink":
        for x in range(1, W - 1):
            h = _half(x, apex)
            for y in range(CY - h + 1, CY + h):
                grid[y][x] = (FILL, RED)
        return grid

    gy, gx = GAZE[state]
    _disc(grid, CX + gx * 2, CY + gy * 2, IRIS_R, FILL, RED)
    _disc(grid, CX + gx * 4, CY + gy * 4, PUPIL_R, FILL, WHITE)

    return grid


def _half(x, apex):
    t = (x - CX) / HALF_W
    if abs(t) >= 1:
        return 0
    return round(apex * (1 - t * t))


def _disc(grid, cx, cy, r, ch, colour):
    r2 = r * r
    for y in range(H):
        for x in range(W):
            if (x - cx) ** 2 + (y - cy) ** 2 <= r2:
                grid[y][x] = (ch, colour)


def star_count(h, w):
    return max(18, (h * w) // 110)


def reseed(stars, h, w):
    stars.clear()
    for _ in range(star_count(h, w)):
        stars[(random.randrange(h), random.randrange(w))] = random.choice(STARS)


def twinkle(stars, h, w):
    if random.random() < 0.35:
        if stars:
            stars.pop(random.choice(tuple(stars)))
        stars[(random.randrange(h), random.randrange(w))] = random.choice(STARS)


def draw(stdscr, grid, stars):
    h, w = stdscr.getmaxyx()
    stdscr.erase()

    for (sy, sx), ch in stars.items():
        if 0 <= sy < h and 0 <= sx < w:
            try:
                stdscr.addstr(sy, sx, ch, curses.color_pair(STAR) | curses.A_DIM)
            except curses.error:
                pass

    start_y = max(0, (h - H) // 2)
    start_x = max(0, (w - W) // 2)
    for y in range(H):
        for x in range(W):
            ch, cid = grid[y][x]
            if cid == 0:
                continue
            sy, sx = start_y + y, start_x + x
            if sy >= h or sx >= w:
                continue
            try:
                stdscr.addstr(sy, sx, ch, curses.color_pair(cid) | curses.A_BOLD)
            except curses.error:
                pass

    stdscr.refresh()


def main(stdscr):
    locale.setlocale(locale.LC_ALL, "")
    curses.curs_set(0)
    stdscr.nodelay(True)
    curses.start_color()
    curses.use_default_colors()
    curses.init_pair(GREEN, curses.COLOR_GREEN, -1)
    curses.init_pair(WHITE, curses.COLOR_WHITE, -1)
    curses.init_pair(RED, curses.COLOR_RED, -1)
    curses.init_pair(STAR, curses.COLOR_GREEN, -1)

    h, w = stdscr.getmaxyx()
    stars = {}
    reseed(stars, h, w)

    directions = list(GAZE.keys())
    state = "center"
    next_move = time.time()

    while True:
        if stdscr.getch() != -1:
            break

        now = time.time()
        if now >= next_move:
            if random.random() < BLINK_CHANCE:
                state = "blink"
                next_move = now + 0.15
            else:
                state = random.choice(directions)
                next_move = now + random.uniform(0.6, 2.2)

        twinkle(stars, h, w)
        draw(stdscr, build_grid(state), stars)
        time.sleep(0.05)


if __name__ == "__main__":
    curses.wrapper(main)
